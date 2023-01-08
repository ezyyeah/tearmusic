import 'package:automatic_animated_list/automatic_animated_list.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/models/storage/cached_item.dart';
import 'package:tearmusic/models/storage/cached_opacity.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';

typedef ContentListViewBuilder = Widget? Function(ValueWidgetBuilder)?;
typedef ContentListViewItemBuilder<T> = Widget? Function(BuildContext, T);
typedef ContentListViewRetriever<T> = Stream<CachedItem<List<T>>>;

class ContentListView<T extends Model> extends StatelessWidget {
  const ContentListView({
    Key? key,
    this.title,
    this.emptyTitle,
    required this.loadingWidget,
    required this.viewItemBuilder,
    required this.retriever,
    this.builder,
  }) : super(key: key);

  final Widget? title;
  final Widget? emptyTitle;
  final Widget loadingWidget;
  final ContentListViewItemBuilder<T> viewItemBuilder;
  final ContentListViewRetriever<T> retriever;
  final ContentListViewBuilder builder;

  Widget itemBuilder<U>(BuildContext context, U? value, Widget? child) {
    if ((value as List?)?.isEmpty ?? false) {
      return Padding(
        padding: const EdgeInsets.only(top: 6.0, bottom: 24.0),
        child: Center(
          child: emptyTitle,
        ),
      );
    }

    return StreamBuilder<CachedItem<List<T>>>(
      stream: retriever,
      builder: ((context, snapshot) {
        if (snapshot.data?.item == null) {
          return loadingWidget;
        }

        final List<T> items = snapshot.data!.item;

        return CachedOpacity(
          type: snapshot.data?.type,
          child: AutomaticAnimatedList<T>(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            items: items,
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
                  child: viewItemBuilder(context, item),
                ),
              );
            },
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Wallpaper(
        gradient: false,
        child: CupertinoScrollbar(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                floating: false,
                pinned: true,
                snap: false,
                title: title,
              ),
              SliverToBoxAdapter(
                child: builder != null ? builder!(itemBuilder) : itemBuilder(context, null, null),
              ),
              const SliverToBoxAdapter(
                child: SafeArea(
                  top: false,
                  child: SizedBox(height: 100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
