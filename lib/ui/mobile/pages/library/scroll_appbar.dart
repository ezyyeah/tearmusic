import 'dart:async';

import 'package:flutter/material.dart';

class ScrollAppBar extends StatefulWidget {
  const ScrollAppBar({super.key, required this.scrollController, required this.text, required this.actions});

  final ScrollController scrollController;
  final String text;
  final List<Widget> actions;

  @override
  State<ScrollAppBar> createState() => _ScrollAppBarState();
}

class _ScrollAppBarState extends State<ScrollAppBar> {
  bool viewScrolled = false;
  bool viewScrolledTitle = false;
  bool viewScrolledShadow = false;
  Timer viewScrolledAgent = Timer(Duration.zero, () {});

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(appBarBackground);
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(appBarBackground);
    super.dispose();
  }

  void appBarBackground() {
    if (widget.scrollController.positions.isEmpty) return;
    final value = widget.scrollController.position.pixels > 0;
    if (viewScrolled != value) {
      viewScrolled = value;
      if (value) viewScrolledTitle = value;
      viewScrolledShadow = value;
      setState(() {});
      if (viewScrolledAgent.isActive) viewScrolledAgent.cancel();
      viewScrolledAgent = Timer(const Duration(milliseconds: 100), () => mounted ? setState(() => viewScrolledTitle = value) : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      snap: false,
      floating: false,
      centerTitle: false,
      backgroundColor: viewScrolledTitle
          ? ElevationOverlay.applySurfaceTint(Theme.of(context).colorScheme.surface, Theme.of(context).colorScheme.surfaceTint, 2.0)
          : Colors.transparent,
      surfaceTintColor: Colors.transparent,
      shadowColor: viewScrolledShadow ? Colors.black : Colors.transparent,
      forceElevated: viewScrolledTitle,
      elevation: 0,
      title: Text(
        widget.text,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      actions: widget.actions,
    );
  }
}
