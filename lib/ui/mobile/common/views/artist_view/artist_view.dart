import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/storage/cached_item.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/navigator_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/knob.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_album_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_artist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_track_tile.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/view_menu_button.dart';
import 'package:tearmusic/ui/mobile/common/views/artist_view/latest_release.dart';
import 'package:tearmusic/ui/mobile/common/views/artist_view/artist_header_button.dart';
import 'package:tearmusic/ui/mobile/common/views/content_list_view.dart';
import 'package:tearmusic/ui/mobile/pages/library/track_loading_tile.dart';

class ArtistView extends StatefulWidget {
  const ArtistView(this.artist, {Key? key}) : super(key: key);

  final MusicArtist artist;

  static Future<void> view(MusicArtist value, {required BuildContext context}) {
    final nav = context.read<NavigatorProvider>();
    final theme = context.read<ThemeProvider>();
    return nav.pushModal(builder: (context) => ArtistView(value), uri: value.uri).then((value) {
      theme.resetTheme();
      return value;
    });
  }

  @override
  State<ArtistView> createState() => _ArtistViewState();
}

class _ArtistViewState extends State<ArtistView> {
  /*Future<ArtistDetails> artistDetails(MusicInfoProvider musicInfo) async {
    final details = await musicInfo.artistDetails(widget.artist);
    if (image == null) {
      image = CachedImage(details.artist.images);
      getTheme(image!).then((value) {
        if (value != null) {
          if (mounted) context.read<ThemeProvider>().tempNavTheme(value);
          theme.complete(value);
        }
      });
    }
    return details;
  }*/

  Future<ThemeData?> getTheme(CachedImage image) async {
    final bytes = await image.getImage(const Size.square(350));

    if (bytes != null) {
      final colors = generateColorPalette(bytes);
      return ThemeProvider.coloredTheme(colors[1]);
    }
    return null;
  }

  late CachedImage image;
  final theme = Completer<ThemeData>();

  CachedItem<ArtistDetails?>? artistResult;

  @override
  void initState() {
    super.initState();

    context.read<MusicInfoProvider>().artistDetails(widget.artist).listen((value) {
      artistResult = value;
      if (mounted) setState(() {});
    });

    if (widget.artist.images != null) {
      image = CachedImage(widget.artist.images);
      getTheme(image).then((value) {
        if (value != null) {
          if (mounted) context.read<ThemeProvider>().tempNavTheme(value);
          theme.complete(value);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //final musicInfo = context.read<MusicInfoProvider>();

    return FutureBuilder<ThemeData>(
      future: theme.future,
      builder: (context, snapshot) {
        if (artistResult?.item == null) {
          return Scaffold(
            body: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
                size: 64.0,
              ),
            ),
          );
        }

        final theme = snapshot.data!;

        return Theme(
          data: theme,
          child: Stack(
            children: [
              Scaffold(
                body: CupertinoScrollbar(
                  controller: ModalScrollController.of(context),
                  child: CustomScrollView(
                    controller: ModalScrollController.of(context),
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        snap: false,
                        floating: false,
                        backgroundColor: theme.scaffoldBackgroundColor,
                        // leading: const TMBackButton(),
                        automaticallyImplyLeading: false,
                        expandedHeight: 300,
                        collapsedHeight: 82,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Text(
                            widget.artist.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          centerTitle: true,
                          expandedTitleScale: 1.7,
                          background: Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              LayoutBuilder(builder: (context, size) {
                                return CachedImage(
                                  artistResult!.item!.artist.images!,
                                  size: size.biggest,
                                );
                              }),
                              Positioned.fill(
                                child: Transform.scale(
                                  scaleY: 1.001,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        stops: const [.5, 1],
                                        colors: [
                                          theme.scaffoldBackgroundColor.withOpacity(0),
                                          theme.scaffoldBackgroundColor,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                  "${NumberFormat.compact().format(widget.artist.followers > 0 ? widget.artist.followers : artistResult!.item!.artist.followers)} followers"),
                            ],
                          ),
                        ),
                      ),
                      // if (snapshot.hasData)
                      //   SliverToBoxAdapter(
                      //     child: Row(
                      //       children: [
                      //         ElevatedButton(
                      //           onPressed: () {},
                      //           child: Text("Follow"),
                      //         ),
                      //         ElevatedButton(
                      //           onPressed: () {},
                      //           child: Text("Shuffle"),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      if (artistResult!.item!.albums.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0),
                          sliver: SliverToBoxAdapter(
                            child: Row(
                              children: [
                                Selector<UserProvider, List<String>>(
                                  selector: (_, p) => p.library?.liked_artists ?? [],
                                  shouldRebuild: (previous, next) {
                                    final albumid = widget.artist.id;
                                    return previous.any((e) => e == albumid) != next.any((e) => e == albumid);
                                  },
                                  builder: (context, data, _) {
                                    final isLiked = data.contains(widget.artist.id);

                                    return Expanded(
                                      child: ArtistHeaderButton(
                                        onPressed: () {
                                          if (!isLiked) {
                                            context.read<UserProvider>().putLibrary(widget.artist, LibraryType.liked_artists);
                                          } else {
                                            context.read<UserProvider>().removeFromLibrary(widget.artist, LibraryType.liked_artists);
                                          }
                                          print("done");
                                        },
                                        icon: isLiked
                                            ? const Icon(CupertinoIcons.heart_fill)
                                            : const Icon(
                                                CupertinoIcons.heart,
                                              ),
                                        child: Text("Follow".toUpperCase()),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 12.0),
                                Expanded(
                                  child: ArtistHeaderButton(
                                    onPressed: () {},
                                    icon: const Icon(CupertinoIcons.shuffle),
                                    child: Text("Shuffle".toUpperCase()),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (artistResult!.item!.albums.isNotEmpty)
                        SliverPadding(
                          padding: const EdgeInsets.all(12.0),
                          sliver: SliverToBoxAdapter(
                            child: LatestRelease(
                              artistResult!.item!.albums.first,
                              then: () {
                                context.read<ThemeProvider>().tempNavTheme(theme);
                              },
                            ),
                          ),
                        ),
                      if (artistResult!.item!.tracks.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0, left: 16.0, right: 8.0),
                                    child: Row(
                                      children: [
                                        const Expanded(
                                          child: Text(
                                            "Top Songs",
                                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                          ),
                                        ),
                                        // TextButton(
                                        //   onPressed: () {
                                        //     Navigator.of(context).push(CupertinoPageRoute(
                                        //       builder: (context) => Theme(
                                        //         data: theme,
                                        //         child: ContentListView<MusicTrack>(
                                        //           itemBuilder: (context, item) => ArtistTrackTile(item),
                                        //           retriever: () => [],
                                        //           loadingWidget: const TrackLoadingTile(itemCount: 8),
                                        //           title: Text(
                                        //             "Top Songs by ${widget.artist.name}",
                                        //             style: const TextStyle(
                                        //               fontWeight: FontWeight.w500,
                                        //             ),
                                        //           ),
                                        //         ),
                                        //       ),
                                        //     ));
                                        //   },
                                        //   child: const Text("Show All"),
                                        // ),
                                      ],
                                    ),
                                  ),
                                  ...artistResult!.item!.tracks
                                      .sublist(0, math.min(artistResult!.item!.tracks.length, 5))
                                      .map((e) => ArtistTrackTile(e)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (artistResult!.item!.albums.any((e) => e.albumType != AlbumType.single))
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Albums",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 200,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...artistResult!.item!.albums.where((e) => e.albumType != AlbumType.single).map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistAlbumTile(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (artistResult!.item!.albums.any((e) => e.albumType == AlbumType.single))
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Singles",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 180,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...artistResult!.item!.albums.where((e) => e.albumType == AlbumType.single).map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistAlbumTile.small(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (artistResult!.item!.related.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Similar Artists",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 150,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...artistResult!.item!.related.map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistArtistTile(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (artistResult!.item!.appearsOn.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 12.0, bottom: 8.0, left: 16.0, right: 8.0),
                                child: Text(
                                  "Appears On",
                                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                                ),
                              ),
                              SizedBox(
                                height: 180,
                                child: ListView(
                                  scrollDirection: Axis.horizontal,
                                  children: [
                                    const SizedBox(width: 16.0),
                                    ...artistResult!.item!.appearsOn.map((e) => Padding(
                                          padding: const EdgeInsets.only(right: 12.0),
                                          child: ArtistAlbumTile.small(e, then: () => context.read<ThemeProvider>().tempNavTheme(theme)),
                                        )),
                                    const SizedBox(width: 16.0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),
              ),
              const Knob(),
              Padding(
                padding: const EdgeInsets.only(top: 12.0, right: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    ViewMenuButton(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
