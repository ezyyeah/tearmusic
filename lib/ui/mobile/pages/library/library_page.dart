import 'dart:async';
import 'dart:developer';

import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/batch.dart';
import 'package:tearmusic/models/library.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/music/artist.dart';
import 'package:tearmusic/models/music/playlist.dart';
import 'package:tearmusic/models/music/track.dart';
import 'package:tearmusic/models/storage/cached_item.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/theme_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/profile_button.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_album_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/artist_artist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/search_playlist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/track_tile.dart';
import 'package:tearmusic/ui/mobile/common/views/content_items.dart';
import 'package:tearmusic/ui/mobile/common/views/content_list_view.dart';
import 'package:tearmusic/ui/mobile/common/views/user_library_content_page.dart';
import 'package:tearmusic/ui/mobile/common/views/user_library_selector.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';

import 'package:tearmusic/ui/mobile/pages/library/album_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/artist_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/playlist_loading_tile.dart';
import 'package:tearmusic/ui/mobile/pages/library/scroll_appbar.dart';
import 'package:tearmusic/ui/mobile/pages/library/track_loading_tile.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({Key? key}) : super(key: key);

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Wallpaper(
      child: CupertinoScrollbar(
        controller: _scrollController,
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            ScrollAppBar(
              scrollController: _scrollController,
              text: "Your Library",
              actions: const [
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(right: 14.0),
                    child: ProfileButton(),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.memories, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Liked Tracks",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return UserLibraryContentPage(
                                        title: "Liked Tracks",
                                        child: ContentItems<MusicTrack, UserProvider>(
                                          itemLimit: 50,
                                          selectorRetriever: (user) => user.library?.liked_tracks,
                                          emptyText: "You have no liked tracks",
                                          contentItemStream: context.read<MusicInfoProvider>().libraryLikedTracks,
                                          loadingTile: const TrackLoadingTile(),
                                          contentItemBuilder: (item) => TrackTile(item),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text("Show all"),
                            ),
                          ],
                        ),
                      ),
                      ContentItems<MusicTrack, UserProvider>(
                        selectorRetriever: (user) => user.library?.liked_tracks,
                        contentItemStream: context.read<MusicInfoProvider>().libraryLikedTracks,
                        emptyText: "You have no liked tracks",
                        loadingTile: const TrackLoadingTile(),
                        contentItemBuilder: (item) => TrackTile(item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.memories, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Liked Playlists",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return UserLibraryContentPage(
                                        title: "Liked Playlists",
                                        child: ContentItems<MusicPlaylist, UserProvider>(
                                          itemLimit: 50,
                                          selectorRetriever: (user) => user.library?.liked_playlists,
                                          emptyText: "You have no liked playlists",
                                          contentItemStream: context.read<MusicInfoProvider>().libraryLikedPlaylists,
                                          loadingTile: const PlaylistLoadingTile(),
                                          contentItemBuilder: (item) => SearchPlaylistTile(item),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text("Show all"),
                            ),
                          ],
                        ),
                      ),
                      ContentItems<MusicPlaylist, UserProvider>(
                        selectorRetriever: (user) => user.library?.liked_playlists,
                        contentItemStream: context.read<MusicInfoProvider>().libraryLikedPlaylists,
                        emptyText: "You have no liked playlists",
                        loadingTile: const PlaylistLoadingTile(),
                        contentItemBuilder: (item) => SearchPlaylistTile(item),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 26.0, right: 8.0),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(CupertinoIcons.person, size: 20.0),
                          ),
                          Text(
                            "Followed Artists",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    ContentItems<MusicArtist, UserProvider>(
                      selectorRetriever: (user) => user.library?.liked_artists,
                      contentItemStream: context.read<MusicInfoProvider>().libraryLikedArtists,
                      loadingTile: const ArtistLoadingTile(),
                      emptyText: "You have no followed artsits",
                      boxHeight: 150,
                      addPadding: true,
                      direction: Axis.horizontal,
                      contentItemBuilder: (item) => Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ArtistArtistTile(
                          item,
                          then: () => context.read<ThemeProvider>().resetTheme(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 16.0, left: 26.0, right: 8.0),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(CupertinoIcons.person, size: 20.0),
                          ),
                          Text(
                            "Liked Albums",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    ContentItems<MusicAlbum, UserProvider>(
                      selectorRetriever: (user) => user.library?.liked_albums,
                      contentItemStream: context.read<MusicInfoProvider>().libraryLikedAlbums,
                      loadingTile: const ArtistLoadingTile(),
                      emptyText: "You have no liked albums",
                      boxHeight: 150,
                      addPadding: true,
                      direction: Axis.horizontal,
                      contentItemBuilder: (item) => Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: ArtistAlbumTile.small(
                          item,
                          then: () => context.read<ThemeProvider>().resetTheme(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            /*SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 28.0, right: 8.0),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(CupertinoIcons.person, size: 20.0),
                          ),
                          Text(
                            "Followed Artists",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    Selector<UserProvider, List<String>>(
                      selector: (_, user) => user.library?.liked_artists ?? [],
                      shouldRebuild: (previous, next) {
                        final value = !listEquals(previous, next);
                        if (value) {
                          _likedArtistsNeedsRefresh = true;
                        }
                        return value;
                      },
                      builder: ((context, value, child) {
                        if (value.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                            child: Center(
                              child: Text("You have no followed artists"),
                            ),
                          );
                        }

                        return FutureBuilder<List<MusicArtist>>(
                          future: readLikedArtists(),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 150, child: ArtistLoadingTile());
                            }

                            return SizedBox(
                              height: 150,
                              child: AutomaticAnimatedList(
                                scrollDirection: Axis.horizontal,
                                items: snapshot.data!,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicArtist item, Animation<double> animation) {
                                  List<Widget> resRow = [];

                                  resRow.add(Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: ArtistArtistTile(
                                      item,
                                      then: () => context.read<ThemeProvider>().resetTheme(),
                                    ),
                                  ));

                                  if (snapshot.data!.first == item) {
                                    resRow = [const SizedBox(width: 24), ...resRow];
                                  } else if (snapshot.data!.last == item) {
                                    resRow = [...resRow, const SizedBox(width: 24)];
                                  }

                                  return FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: Row(
                                        children: resRow,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),*/
            /*SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.memories, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Liked Playlists",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return Selector<UserProvider, List<String>>(
                                        selector: (_, p) => p.library?.liked_playlists ?? [],
                                        shouldRebuild: (previous, next) {
                                          return !listEquals(previous, next);
                                        },
                                        builder: (context, data, _) => ContentListView<MusicPlaylist>(
                                          itemBuilder: (context, item) => SearchPlaylistTile(item),
                                          retriever: context.read<MusicInfoProvider>().libraryLikedPlaylists(limit: 50),
                                          loadingWidget: const PlaylistLoadingTile(itemCount: 8),
                                          title: const Text(
                                            "Liked Playlists",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text("Show all"),
                            ),
                          ],
                        ),
                      ),
                      Selector<UserProvider, List<String>>(
                        selector: (_, user) => user.library?.liked_playlists ?? [],
                        shouldRebuild: (previous, next) {
                          return !listEquals(previous, next);
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("You have no liked playlists"),
                              ),
                            );
                          }

                          return StreamBuilder<CachedItem<List<MusicPlaylist>>>(
                            stream: context.read<MusicInfoProvider>().libraryLikedPlaylists(limit: 5),
                            builder: (context, snapshot) {
                              if (snapshot.data?.item == null || !snapshot.hasData) {
                                return const TrackLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!.item,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicPlaylist item, Animation<double> animation) {
                                  return FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: SearchPlaylistTile(item),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.memories, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Recently played",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return Selector<UserProvider, List<UserTrackHistory>>(
                                        selector: (_, p) => p.library?.track_history ?? [],
                                        builder: (context, data, _) => ContentListView<MusicTrack>(
                                          itemBuilder: (context, item) => TrackTile(item),
                                          retriever: context.read<MusicInfoProvider>().libraryLikedTracks(limit: 50),
                                          loadingWidget: const TrackLoadingTile(itemCount: 8),
                                          title: const Text(
                                            "Liked Tracks",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text("Show all"),
                            ),
                          ],
                        ),
                      ),
                      Selector<UserProvider, List<UserTrackHistory>>(
                        selector: (_, user) => user.library?.track_history ?? [],
                        shouldRebuild: (previous, next) {
                          return !listEquals(previous, next);
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("You have no liked tracks"),
                              ),
                            );
                          }

                          return StreamBuilder<CachedItem<List<MusicTrack>>>(
                            stream: context.read<MusicInfoProvider>().libraryLikedTracks(limit: 5),
                            builder: (context, snapshot) {
                              if (snapshot.data?.item == null || !snapshot.hasData) {
                                return const TrackLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!.item,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicTrack item, Animation<double> animation) {
                                  return FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: TrackTile(item),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.memories, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Recently played",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) {
                                      return Selector<UserProvider, List<UserTrackHistory>>(
                                        selector: (_, p) => p.library?.track_history ?? [],
                                        builder: (context, data, _) => ContentListView<MusicTrack>(
                                          itemBuilder: (context, item) => TrackTile(item),
                                          retriever: context.read<MusicInfoProvider>().libraryLikedTracks(limit: 50),
                                          loadingWidget: const TrackLoadingTile(itemCount: 8),
                                          title: const Text(
                                            "Liked Tracks",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                              child: const Text("Show all"),
                            ),
                          ],
                        ),
                      ),
                      Selector<UserProvider, List<UserTrackHistory>>(
                        selector: (_, user) => user.library?.track_history ?? [],
                        shouldRebuild: (previous, next) {
                          return !listEquals(previous, next);
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("You have no liked tracks"),
                              ),
                            );
                          }

                          return StreamBuilder<CachedItem<List<MusicTrack>>>(
                            stream: context.read<MusicInfoProvider>().libraryLikedTracks(limit: 5),
                            builder: (context, snapshot) {
                              if (snapshot.data?.item == null || !snapshot.hasData) {
                                return const TrackLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!.item,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicTrack item, Animation<double> animation) {
                                  return FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: TrackTile(item),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            */ /*
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.music_note_2, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Liked Songs",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ContentListView<MusicTrack>(
                                    builder: (builder) => Selector<UserProvider, List<String>>(
                                      selector: (_, p) => p.library?.liked_tracks ?? [],
                                      builder: builder,
                                    ),
                                    itemBuilder: (context, item) => TrackTile(item),
                                    retriever: () async {
                                      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_tracks, limit: 50);
                                      return items.tracks;
                                    },
                                    loadingWidget: const TrackLoadingTile(itemCount: 8),
                                    title: const Text(
                                      "Liked Songs",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ));
                              },
                              child: const Text("Show All"),
                            ),
                          ],
                        ),
                      ),
                      Selector<UserProvider, List<String>>(
                        selector: (_, user) => user.library?.liked_tracks ?? [],
                        shouldRebuild: (previous, next) {
                          final value = !listEquals(previous, next);
                          if (value) {
                            _likedSongsNeedsRefresh = true;
                          }
                          return value;
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("You have no liked songs"),
                              ),
                            );
                          }

                          return FutureBuilder<List<MusicTrack>>(
                            future: readLikedTracks(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return const TrackLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicTrack item, Animation<double> animation) {
                                  return FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: TrackTile(item),
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Card(
                  elevation: 2.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 12.0, right: 8.0),
                        child: Row(
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(right: 8.0),
                              child: Icon(CupertinoIcons.music_note_list, size: 20.0),
                            ),
                            const Expanded(
                              child: Text(
                                "Liked Playlists",
                                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(CupertinoPageRoute(
                                  builder: (context) => ContentListView<MusicPlaylist>(
                                    itemBuilder: (context, item) => SearchPlaylistTile(item),
                                    retriever: () async {
                                      final items = await context.read<MusicInfoProvider>().libraryBatch(LibraryType.liked_playlists, limit: 50);
                                      return items.playlists;
                                    },
                                    loadingWidget: const PlaylistLoadingTile(itemCount: 8),
                                    title: const Text(
                                      "Liked Playlists",
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ));
                              },
                              child: const Text("Show All"),
                            )
                          ],
                        ),
                      ),
                      Selector<UserProvider, List<String>>(
                        selector: (_, user) => user.library?.liked_playlists ?? [],
                        shouldRebuild: (previous, next) {
                          final value = !listEquals(previous, next);
                          if (value) {
                            _likedPlaylistsNeedsRefresh = true;
                          }
                          return value;
                        },
                        builder: ((context, value, child) {
                          if (value.isEmpty) {
                            return const Padding(
                              padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                              child: Center(
                                child: Text("You have no liked playlists"),
                              ),
                            );
                          }

                          return FutureBuilder<List<MusicPlaylist>>(
                            future: readLikedPlaylists(),
                            builder: ((context, snapshot) {
                              if (!snapshot.hasData) {
                                return const PlaylistLoadingTile();
                              }

                              return AutomaticAnimatedList(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                items: snapshot.data!,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicPlaylist item, Animation<double> animation) {
                                  return FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 12.0),
                                        child: SearchPlaylistTile(
                                          item,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12.0, bottom: 12.0, left: 28.0, right: 8.0),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(CupertinoIcons.person, size: 20.0),
                          ),
                          Text(
                            "Followed Artists",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    Selector<UserProvider, List<String>>(
                      selector: (_, user) => user.library?.liked_artists ?? [],
                      shouldRebuild: (previous, next) {
                        final value = !listEquals(previous, next);
                        if (value) {
                          _likedArtistsNeedsRefresh = true;
                        }
                        return value;
                      },
                      builder: ((context, value, child) {
                        if (value.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                            child: Center(
                              child: Text("You have no followed artists"),
                            ),
                          );
                        }

                        return FutureBuilder<List<MusicArtist>>(
                          future: readLikedArtists(),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 150, child: ArtistLoadingTile());
                            }

                            return SizedBox(
                              height: 150,
                              child: AutomaticAnimatedList(
                                scrollDirection: Axis.horizontal,
                                items: snapshot.data!,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicArtist item, Animation<double> animation) {
                                  List<Widget> resRow = [];

                                  resRow.add(Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: ArtistArtistTile(
                                      item,
                                      then: () => context.read<ThemeProvider>().resetTheme(),
                                    ),
                                  ));

                                  if (snapshot.data!.first == item) {
                                    resRow = [const SizedBox(width: 24), ...resRow];
                                  } else if (snapshot.data!.last == item) {
                                    resRow = [...resRow, const SizedBox(width: 24)];
                                  }

                                  return FadeTransition(
                                    key: Key(item.id),
                                    opacity: animation,
                                    child: SizeTransition(
                                      sizeFactor: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                        reverseCurve: Curves.easeIn,
                                      ),
                                      child: Row(
                                        children: resRow,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0, bottom: 16.0, left: 28.0, right: 8.0),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(CupertinoIcons.music_albums, size: 20.0),
                          ),
                          Text(
                            "Liked Albums",
                            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ),
                    Selector<UserProvider, List<String>>(
                      selector: (_, user) => user.library?.liked_albums ?? [],
                      shouldRebuild: (previous, next) {
                        final value = !listEquals(previous, next);
                        if (value) {
                          _likedAlbumsNeedsRefresh = true;
                        }
                        return value;
                      },
                      builder: ((context, value, child) {
                        if (value.isEmpty) {
                          return const Padding(
                            padding: EdgeInsets.only(top: 6.0, bottom: 24.0),
                            child: Center(
                              child: Text("You have no liked albums"),
                            ),
                          );
                        }

                        return FutureBuilder<List<MusicAlbum>>(
                          future: readLikedAlbums(),
                          builder: ((context, snapshot) {
                            if (!snapshot.hasData) {
                              return const SizedBox(height: 200, child: AlbumLoadingTile());
                            }

                            return SizedBox(
                              height: 200,
                              child: AutomaticAnimatedList(
                                scrollDirection: Axis.horizontal,
                                items: snapshot.data!,
                                keyingFunction: (item) => Key(item.id),
                                itemBuilder: (BuildContext context, MusicAlbum item, Animation<double> animation) {
                                  List<Widget> resRow = [];

                                  resRow.add(Padding(
                                    padding: const EdgeInsets.only(right: 12.0),
                                    child: ArtistAlbumTile.small(
                                      item,
                                      then: () => context.read<ThemeProvider>().resetTheme(),
                                    ),
                                  ));

                                  if (snapshot.data!.first == item) {
                                    resRow = [const SizedBox(width: 26), ...resRow];
                                  } else if (snapshot.data!.last == item) {
                                    resRow = [...resRow, const SizedBox(width: 26)];
                                  }

                                  return Align(
                                    alignment: Alignment.topCenter,
                                    child: FadeTransition(
                                      key: Key(item.id),
                                      opacity: animation,
                                      child: SizeTransition(
                                        sizeFactor: CurvedAnimation(
                                          parent: animation,
                                          curve: Curves.easeOut,
                                          reverseCurve: Curves.easeIn,
                                        ),
                                        child: Row(
                                          children: resRow,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),*/
            const SliverToBoxAdapter(
              child: SafeArea(
                top: false,
                child: SizedBox(
                  height: 100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
