import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:tearmusic/ui/mobile/common/wallpaper.dart';

class UserLibraryContentPage extends StatelessWidget {
  const UserLibraryContentPage({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

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
                title: Text(title),
              ),
              SliverToBoxAdapter(
                child: child,
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
