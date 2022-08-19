import 'dart:async';
import 'dart:math';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:fuzzy/data/result.dart';
import 'package:fuzzy/fuzzy.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/search.dart';
import 'package:tearmusic/providers/music_info_provider.dart';
import 'package:tearmusic/ui/mobile/common/filter_bar.dart';
import 'package:tearmusic/ui/mobile/common/tiles/search_album_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/search_artist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/search_playlist_tile.dart';
import 'package:tearmusic/ui/mobile/common/tiles/search_track_tile.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';
import 'package:tearmusic/ui/mobile/pages/search/top_result_container.dart';

enum SearchResult { prepare, empty, loading, done }

// Part of the filter code were stolen from https://github.com/filc/naplo

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final _searchInputController = TextEditingController();
  final _searchInputFocus = FocusNode();
  late TabController _tabController;
  late PageController _pageController;

  final List<Widget> tabs = const [
    Tab(text: "Top"),
    Tab(text: "Songs"),
    Tab(text: "Albums"),
    Tab(text: "Playlists"),
    Tab(text: "Artists"),
  ];
  late List<String> listOrder;

  SearchResults? results;
  List<SearchSuggestion> suggestions = [];
  List<Result<String>> suggestionResults = [];
  SearchResult result = SearchResult.prepare;

  String lastTerm = "";
  Timer searchDebounce = Timer(Duration.zero, () {});
  Timer suggestionDebounce = Timer(Duration.zero, () {});
  static const Duration serdd = Duration(milliseconds: 500); // search debounce timeout
  static const Duration sugdd = Duration(milliseconds: 300); // suggestion debounce timeout

  @override
  void initState() {
    super.initState();

    listOrder = List.generate(tabs.length, (i) => "$i");
    _tabController = TabController(length: tabs.length, vsync: this);
    _pageController = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchInputFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchInputController.dispose();
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void onHandlerChanged(value, {bool force = false}) {
    if (value == "") {
      suggestions = [];
      setState(() => result = SearchResult.prepare);
      lastTerm = "";
      return;
    }
    if (lastTerm == value) return;
    lastTerm = value;

    if (!force) {
      if (suggestions.isNotEmpty) {
        final fuzzy = Fuzzy(suggestions.map((e) => e.raw).toList());
        setState(() {
          suggestionResults = fuzzy.search(value);
        });
      }

      suggest(value);
    } else {
      setState(() {
        results = null;
        result = SearchResult.loading;
      });

      searchResults(value).then((_) {
        setState(() {
          if (results?.isEmpty ?? true) {
            result = SearchResult.empty;
          } else {
            result = SearchResult.done;
          }
        });
      });
    }
  }

  Future<void> suggest(String value) async {
    final res = await context.read<MusicInfoProvider>().searchSuggest(value);
    if (lastTerm != value) return;
    setState(() {
      if (res.isEmpty) {
        suggestions = [];
      } else {
        suggestions = res;
        final fuzzy = Fuzzy(suggestions.map((e) => e.raw).toList());
        suggestionResults = fuzzy.search(value);
        result = SearchResult.prepare;

        suggestionDebounce = Timer(sugdd, () {
          lastTerm = suggestionResults[0].item;
          searchResults(suggestionResults[0].item);
        });
      }
    });
  }

  Future<void> searchResults(String value) async {
    final res = await context.read<MusicInfoProvider>().search(value);
    if (lastTerm != value) return;
    setState(() {
      results = res;
    });
  }

  @override
  Widget build(BuildContext context) {
    final noResultsWidget = Padding(
      padding: const EdgeInsets.only(bottom: 200.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "🫥",
              style: TextStyle(fontSize: 64.0),
            ),
            Text(
              "No results...",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );

    return Wallpaper(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 24.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0, left: 12.0),
                        child: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
                      ),
                      Expanded(
                        child: TextField(
                          focusNode: _searchInputFocus,
                          autocorrect: false,
                          autofocus: false,
                          onChanged: onHandlerChanged,
                          onSubmitted: (value) => onHandlerChanged(value, force: true),
                          controller: _searchInputController,
                          textInputAction: TextInputAction.search,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            hintText: "Search...",
                            hintStyle: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500),
                            border: UnderlineInputBorder(
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchInputController.text = "";
                          if (searchDebounce.isActive) searchDebounce.cancel();
                          setState(() {
                            suggestions = [];
                            if (results == null) result = SearchResult.prepare;
                          });
                          _searchInputFocus.requestFocus();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: FilterBar(
                  items: tabs,
                  controller: _tabController,
                  onTap: (index) {
                    if (_pageController.positions.isEmpty) return;

                    FocusScope.of(context).requestFocus(FocusNode());

                    int selectedPage = _pageController.page!.round();

                    if (index == selectedPage) return;
                    if (_pageController.page?.roundToDouble() != _pageController.page) {
                      _pageController.animateToPage(index, curve: Curves.easeIn, duration: kTabScrollDuration);
                      return;
                    }

                    // swap current page with target page
                    setState(() {
                      _pageController.jumpToPage(index);
                      String currentList = listOrder[selectedPage];
                      listOrder[selectedPage] = listOrder[index];
                      listOrder[index] = currentList;
                    });
                  },
                ),
              ),
              Expanded(
                child: PageTransitionSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, primaryAnimation, secondaryAnimation) {
                    return SharedAxisTransition(
                      fillColor: Colors.transparent,
                      animation: primaryAnimation,
                      secondaryAnimation: secondaryAnimation,
                      transitionType: SharedAxisTransitionType.vertical,
                      child: child,
                    );
                  },
                  child: () {
                    switch (result) {
                      case SearchResult.prepare:
                        if (suggestions.isNotEmpty) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: ListView.builder(
                                    itemCount: suggestionResults.length,
                                    itemBuilder: (context, index) {
                                      List<InlineSpan> renderSuggestion(Result<String> result) {
                                        if (result.matches.isEmpty) return [];

                                        List<InlineSpan> parts = [];
                                        final match = result.matches.first;
                                        final matches = result.matches.first.matchedIndices;

                                        final secStyle = TextStyle(
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context).colorScheme.secondary,
                                        );

                                        final primStyle = TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        );

                                        for (int i = 0; i < matches.length; i++) {
                                          if (i == 0) {
                                            parts.add(TextSpan(
                                              text: match.value.substring(i == 0 ? 0 : matches[i - 1].end + 1, matches[i].start),
                                              style: secStyle,
                                            ));
                                          }
                                          parts.add(TextSpan(
                                            text: match.value.substring(matches[i].start, matches[i].end + 1),
                                            style: primStyle,
                                          ));
                                          parts.add(TextSpan(
                                            text: match.value.substring(matches[i].end + 1, (i == matches.length - 1) ? null : matches[i + 1].start),
                                            style: secStyle,
                                          ));
                                        }

                                        return parts;
                                      }

                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                        child: InkWell(
                                          onTap: () {
                                            _searchInputFocus.unfocus();

                                            if (index == 0 && results != null && lastTerm == suggestionResults[0].item) {
                                              setState(() {
                                                _searchInputController.text = suggestionResults[0].item;
                                                result = SearchResult.done;
                                              });
                                            } else {
                                              setState(() {
                                                _searchInputController.text = suggestionResults[index].item;
                                                result = SearchResult.loading;
                                              });
                                              onHandlerChanged(suggestionResults[index].item, force: true);
                                            }
                                          },
                                          borderRadius: BorderRadius.circular(8.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
                                            width: double.infinity,
                                            child: Row(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(right: 12.0),
                                                  child: Icon(
                                                    Icons.music_note,
                                                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Text.rich(
                                                    TextSpan(children: renderSuggestion(suggestionResults[index])),
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(
                                                      fontSize: 16.0,
                                                      fontFamily: Theme.of(context).textTheme.bodyText2!.fontFamily,
                                                    ),
                                                  ),
                                                ),
                                                AnimatedOpacity(
                                                  duration: const Duration(milliseconds: 300),
                                                  opacity: index == 0 && results != null && lastTerm == suggestionResults[0].item ? 1 : 0,
                                                  child: const Icon(Icons.arrow_forward),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 200.0),
                          child: Center(
                            child: Transform.rotate(
                              angle: pi / 14.0,
                              child: Icon(
                                Icons.music_note,
                                size: 82.0,
                                color: Theme.of(context).colorScheme.secondaryContainer,
                              ),
                            ),
                          ),
                        );
                      case SearchResult.empty:
                        return noResultsWidget;
                      case SearchResult.loading:
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 200.0),
                          child: Center(
                            child: LoadingAnimationWidget.staggeredDotsWave(
                              color: Theme.of(context).colorScheme.secondary.withOpacity(.2),
                              size: 64.0,
                            ),
                          ),
                        );
                      case SearchResult.done:
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_pageController.positions.isNotEmpty) {
                            _pageController.jumpToPage(_tabController.index);
                          } else {
                            _tabController.animateTo(0);
                          }
                        });
                        if (results == null) return const SizedBox();
                        return NotificationListener<ScrollNotification>(
                          onNotification: (notification) {
                            // from flutter source
                            if (notification is ScrollUpdateNotification && !_tabController.indexIsChanging) {
                              if ((_pageController.page! - _tabController.index).abs() > 1.0) {
                                _tabController.index = _pageController.page!.floor();
                              }
                              _tabController.offset = (_pageController.page! - _tabController.index).clamp(-1.0, 1.0);
                            } else if (notification is ScrollEndNotification) {
                              _tabController.index = _pageController.page!.round();
                              if (!_tabController.indexIsChanging) {
                                _tabController.offset = (_pageController.page! - _tabController.index).clamp(-1.0, 1.0);
                              }
                            }
                            return false;
                          },
                          child: PageView.custom(
                            controller: _pageController,
                            childrenDelegate: SliverChildBuilderDelegate(
                              (BuildContext context, int pageIndex) {
                                if (pageIndex == 0) {
                                  return ListView.builder(
                                    itemCount: 5,
                                    itemBuilder: (context, index) {
                                      if (index == 4) {
                                        return const SizedBox(height: 200);
                                      }

                                      const topShowCount = 3;

                                      switch (index) {
                                        case 0:
                                          return TopResultContainer(
                                            kind: "Songs",
                                            results: results!.tracks
                                                .sublist(0, min(results!.tracks.length, topShowCount))
                                                .map((e) => SearchTrackTile(e))
                                                .toList(),
                                            index: 1,
                                            pageController: _pageController,
                                            tabController: _tabController,
                                          );

                                        case 1:
                                          return TopResultContainer(
                                            kind: "Albums",
                                            results: results!.albums
                                                .sublist(0, min(results!.albums.length, topShowCount))
                                                .map((e) => SearchAlbumTile(e))
                                                .toList(),
                                            index: 2,
                                            pageController: _pageController,
                                            tabController: _tabController,
                                          );

                                        case 2:
                                          return TopResultContainer(
                                            kind: "Playlists",
                                            results: results!.playlists
                                                .sublist(0, min(results!.playlists.length, topShowCount))
                                                .map((e) => SearchPlaylistTile(e))
                                                .toList(),
                                            index: 3,
                                            pageController: _pageController,
                                            tabController: _tabController,
                                          );

                                        case 3:
                                          return TopResultContainer(
                                            kind: "Artists",
                                            results: results!.artists
                                                .sublist(0, min(results!.artists.length, topShowCount))
                                                .map((e) => SearchArtistTile(e))
                                                .toList(),
                                            index: 4,
                                            pageController: _pageController,
                                            tabController: _tabController,
                                          );
                                      }

                                      return const SizedBox();
                                    },
                                  );
                                } else {
                                  switch (pageIndex) {
                                    case 1:
                                      return ListView.builder(
                                        itemCount: (results?.tracks.length ?? 0).clamp(1, 50) + 1,
                                        itemBuilder: (context, index) {
                                          if (index == results!.tracks.length) {
                                            return const SizedBox(height: 200);
                                          }

                                          if (results?.tracks.isEmpty ?? true) {
                                            return noResultsWidget;
                                          }

                                          return SearchTrackTile(results!.tracks[index]);
                                        },
                                      );
                                    case 2:
                                      return ListView.builder(
                                        itemCount: (results?.albums.length ?? 0).clamp(1, 50) + 1,
                                        itemBuilder: (context, index) {
                                          if (index == results!.albums.length) {
                                            return const SizedBox(height: 200);
                                          }

                                          if (results?.albums.isEmpty ?? true) {
                                            return noResultsWidget;
                                          }

                                          return SearchAlbumTile(results!.albums[index]);
                                        },
                                      );
                                    case 3:
                                      return ListView.builder(
                                        itemCount: (results?.playlists.length ?? 0).clamp(1, 50) + 1,
                                        itemBuilder: (context, index) {
                                          if (index == results!.playlists.length) {
                                            return const SizedBox(height: 200);
                                          }

                                          if (results?.playlists.isEmpty ?? true) {
                                            return noResultsWidget;
                                          }

                                          return SearchPlaylistTile(results!.playlists[index]);
                                        },
                                      );
                                    case 4:
                                      return ListView.builder(
                                        itemCount: (results?.artists.length ?? 0).clamp(1, 50) + 1,
                                        itemBuilder: (context, index) {
                                          if (index == results!.artists.length) {
                                            return const SizedBox(height: 200);
                                          }

                                          if (results?.artists.isEmpty ?? true) {
                                            return noResultsWidget;
                                          }

                                          return SearchArtistTile(results!.artists[index]);
                                        },
                                      );
                                  }
                                }

                                return null;
                              },
                              childCount: 5,
                              findChildIndexCallback: (Key key) {
                                final ValueKey<String> valueKey = key as ValueKey<String>;
                                final String data = valueKey.value;
                                return listOrder.indexOf(data);
                              },
                            ),
                            physics: const PageScrollPhysics().applyTo(const BouncingScrollPhysics()),
                          ),
                        );
                    }
                  }(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
