import 'package:animations/animations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/music/album.dart';
import 'package:tearmusic/models/storage/cached_item.dart';
import 'package:tearmusic/models/storage/cached_opacity.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/providers/user_provider.dart';
import 'package:tearmusic/ui/mobile/common/profile_button.dart';
import 'package:tearmusic/ui/mobile/common/tiles/search_album_tile.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';
import 'package:tearmusic/ui/mobile/pages/library/track_loading_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    final username = context.select<UserProvider, String>((user) => user.username);

    return Wallpaper(
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0).add(const EdgeInsets.symmetric(horizontal: 24.0)),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Welcome back, $username!",
                        maxLines: 2,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 20.0,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                    const ProfileButton(),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 24.0, top: 32.0, bottom: 8.0),
                child: Text(
                  "New Releases".toUpperCase(),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder(
                  stream: context.read<MusicInfoProvider>().newReleases(),
                  builder: (context, snapshot) {
                    return CachedOpacity(
                      type: snapshot.data?.type,
                      child: PageTransitionSwitcher(
                        transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                          return SharedAxisTransition(
                            fillColor: Colors.transparent,
                            animation: primaryAnimation,
                            secondaryAnimation: secondaryAnimation,
                            transitionType: SharedAxisTransitionType.vertical,
                            child: child,
                          );
                        },
                        child: snapshot.data?.item == null
                            ? const Align(
                                alignment: Alignment.topCenter,
                                child: TrackLoadingTile(itemCount: 8),
                              )
                            : CupertinoScrollbar(
                                child: ListView.builder(
                                  itemCount: snapshot.data!.item!.length + 1,
                                  itemBuilder: (context, index) {
                                    if (index == snapshot.data!.item!.length) {
                                      return const SizedBox(height: 100);
                                    }

                                    return SearchAlbumTile(snapshot.data!.item![index]);
                                  },
                                ),
                              ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
