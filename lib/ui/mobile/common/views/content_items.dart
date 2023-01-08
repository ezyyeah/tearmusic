import 'dart:developer';

import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/storage/cached_item.dart';
import 'package:tearmusic/models/storage/cached_opacity.dart';
import 'package:tearmusic/providers/music_info_provider.dart';

typedef ContentItemBuilder<T> = Widget? Function(T);
typedef ContentItemStream<T> = Stream<CachedItem<List<T>>> Function({int limit, int offset});
typedef LibraryCustomItemBuilder<T> = Widget Function(BuildContext, AsyncSnapshot<CachedItem<List<T>>>);
typedef SelectorRetriever<E> = List<String>? Function(E);

class ContentItems<T extends Model, E> extends StatefulWidget {
  const ContentItems(
      {super.key,
      required this.contentItemStream,
      required this.loadingTile,
      required this.contentItemBuilder,
      required this.selectorRetriever,
      required this.emptyText,
      this.itemLimit = 3,
      this.addPadding = false,
      this.boxHeight,
      this.direction = Axis.vertical});

  final ContentItemStream<T> contentItemStream;
  final ContentItemBuilder<T> contentItemBuilder;
  final SelectorRetriever<E> selectorRetriever;
  final Widget loadingTile;
  final bool addPadding;
  final double? boxHeight;
  final Axis direction;
  final int itemLimit;
  final String emptyText;

  @override
  State<ContentItems<T, E>> createState() => _ContentItemsState<T, E>();
}

class _ContentItemsState<T extends Model, E> extends State<ContentItems<T, E>> {
  CachedItem<List<T>>? streamedItem;
  bool useLocalData = false;
  bool streamFinished = false;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  void refresh() {
    widget.contentItemStream(limit: widget.itemLimit).listen((event) {
      streamedItem = event;
      if (mounted) setState(() {});
    }).onDone(() {
      streamFinished = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (streamedItem?.item == null) return widget.loadingTile;

    return Selector<E, List<String>>(
      selector: (_, user) => widget.selectorRetriever(user) ?? [],
      shouldRebuild: (previous, next) {
        return !listEquals(previous, next) && streamFinished;
      },
      builder: (context, value, child) {
        if (value.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 24.0),
            child: Center(
              child: Text(widget.emptyText),
            ),
          );
        }

        return FutureBuilder<List<T>>(
          future: () async {
            return (await widget.contentItemStream(limit: widget.itemLimit).first).item;
          }(),
          builder: (context, snapshot) {
            final useItems = streamFinished && snapshot.hasData ? snapshot.data! : streamedItem!.item;

            return SizedBox(
              height: widget.boxHeight,
              child: CachedOpacity(
                type: streamedItem!.type,
                child: AutomaticAnimatedList(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: widget.direction,
                  items: useItems,
                  keyingFunction: (item) => Key(item.id),
                  itemBuilder: (BuildContext context, T item, Animation<double> animation) {
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
                            padding: EdgeInsets.only(
                                left: widget.addPadding && useItems.first == item ? 24.0 : 0.0,
                                right: widget.addPadding && useItems.last == item ? 24.0 : 0.0),
                            child: widget.contentItemBuilder(item)),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}
