import 'dart:async';

import 'package:figma_squircle/figma_squircle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/navigator_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/common/image_color.dart';
import 'package:tearmusic/ui/mobile/common/tiles/album_track_tile.dart';
import 'package:tearmusic/ui/mobile/common/cached_image.dart';
import 'package:tearmusic/ui/mobile/common/tm_back_button.dart';

class AlbumView extends StatefulWidget {
  const AlbumView(this.album, {Key? key}) : super(key: key);

  final MusicAlbum album;

  static Future<void> view(MusicAlbum value, {required BuildContext context}) => context.read<NavigatorProvider>().push(
        CupertinoPageRoute(
          builder: (context) => AlbumView(value),
        ),
        uri: value.uri,
      );

  @override
  State<AlbumView> createState() => _AlbumViewState();
}

class _AlbumViewState extends State<AlbumView> {
  late ScrollController _scrollController;

  bool showTitle = false;

  Future<ThemeData> getTheme(CachedImage image) async {
    final bytes = await image.getImage(const Size.square(imageSize));

    final colors = generateColorPalette(bytes);
    return ThemeProvider.coloredTheme(colors[1]);
  }

  late CachedImage image;
  static const double imageSize = 250;
  final theme = Completer<ThemeData>();

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 300.0) {
        if (!showTitle) setState(() => showTitle = true);
      } else {
        if (showTitle) setState(() => showTitle = false);
      }
    });

    image = CachedImage(widget.album.images!);

    getTheme(image).then((value) {
      if (mounted) context.read<ThemeProvider>().tempNavTheme(value);
      theme.complete(value);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ThemeData>(
      future: theme.future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container();
        }

        final theme = snapshot.data!;

        return FutureBuilder<List<MusicTrack>>(
          future: context.read<MusicInfoProvider>().albumTracks(widget.album),
          builder: (context, snapshot) {
            return Theme(
              data: theme,
              child: Scaffold(
                body: CupertinoScrollbar(
                  controller: _scrollController,
                  child: CustomScrollView(
                    controller: _scrollController,
                    slivers: [
                      SliverAppBar(
                        pinned: true,
                        snap: false,
                        floating: false,
                        centerTitle: false,
                        title: AnimatedOpacity(
                          opacity: showTitle ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Text(
                            widget.album.name,
                            style: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.w500),
                          ),
                        ),
                        backgroundColor: theme.scaffoldBackgroundColor,
                        leading: const TMBackButton(),
                        actions: [
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(Icons.more_vert),
                          )
                        ],
                        expandedHeight: 300,
                        flexibleSpace: FlexibleSpaceBar(
                          background: SafeArea(
                            child: Padding(
                              padding: const EdgeInsets.only(top: 42.0),
                              child: Center(
                                child: SizedBox(
                                  width: imageSize,
                                  height: imageSize,
                                  child: ClipSmoothRect(
                                    radius: SmoothBorderRadius(cornerRadius: 32.0, cornerSmoothing: 1.0),
                                    child: image,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 18.0, left: 24.0, right: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      widget.album.name,
                                      maxLines: 2,
                                      softWrap: true,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 26.0,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 12.0),
                                      child: Text(
                                        widget.album.artistsLabel,
                                        maxLines: 1,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: theme.colorScheme.secondary.withOpacity(.7),
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "${widget.album.title} • ${widget.album.releaseDate.year}",
                                      style: TextStyle(
                                        fontSize: 16.0,
                                        color: theme.colorScheme.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Column(
                                children: [
                                  Theme(
                                    data: theme.copyWith(
                                      floatingActionButtonTheme: FloatingActionButtonThemeData(
                                        sizeConstraints: BoxConstraints.tight(const Size.square(72.0)),
                                        iconSize: 46.0,
                                      ),
                                    ),
                                    child: FloatingActionButton(
                                      child: const Icon(Icons.play_arrow),
                                      onPressed: () {},
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        onPressed: () {},
                                        icon: Icon(
                                          Icons.cloud_download_outlined,
                                          color: theme.colorScheme.onSecondaryContainer,
                                          size: 26.0,
                                        ),
                                      ),
                                      FutureBuilder(
                                          future: context.read<UserProvider>().getLibrary(),
                                          builder: (context, snapshot) {
                                            return LikeButton(
                                              bubblesColor: BubblesColor(
                                                dotPrimaryColor: theme.colorScheme.primary,
                                                dotSecondaryColor: theme.colorScheme.primaryContainer,
                                              ),
                                              circleColor: CircleColor(
                                                start: theme.colorScheme.tertiary,
                                                end: theme.colorScheme.tertiary,
                                              ),
                                              isLiked: snapshot.hasData ? snapshot.data!.liked_albums.contains(widget.album.id) : false,
                                              onTap: (isLiked) async {
                                                if (!isLiked) {
                                                  context.read<UserProvider>().putLibrary(widget.album, LibraryType.liked_albums);
                                                } else {
                                                  context.read<UserProvider>().deleteLibrary(widget.album, LibraryType.liked_albums);
                                                }

                                                return !isLiked;
                                              },
                                              likeBuilder: (value) => value
                                                  ? Icon(
                                                      Icons.favorite,
                                                      color: theme.colorScheme.primary,
                                                      size: 26.0,
                                                    )
                                                  : Icon(
                                                      Icons.favorite_border_outlined,
                                                      color: theme.colorScheme.onSecondaryContainer,
                                                      size: 26.0,
                                                    ),
                                            );
                                          }),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (!snapshot.hasData)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 32.0),
                            child: Align(
                              alignment: Alignment.topCenter,
                              child: LoadingAnimationWidget.staggeredDotsWave(
                                color: theme.colorScheme.secondary.withOpacity(.2),
                                size: 64.0,
                              ),
                            ),
                          ),
                        ),
                      if (snapshot.hasData)
                        SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (BuildContext context, int index) => AlbumTrackTile(snapshot.data![index]),
                            childCount: snapshot.data!.length,
                          ),
                        ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 200),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
