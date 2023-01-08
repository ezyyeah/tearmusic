import 'package:flutter/material.dart';
import 'package:tearmusic/models/storage/cached_item.dart';

class CachedOpacity extends StatelessWidget {
  const CachedOpacity({super.key, required this.type, required this.child});

  final Widget child;
  final CacheType? type;

  @override
  Widget build(BuildContext context) {
    // return AnimatedOpacity(
    //   duration: const Duration(milliseconds: 300),
    //   curve: Curves.easeInOutCubic,
    //   opacity: type == CacheType.local ? 0.75 : 1.0,
    //   child: child,
    // );
    return child;
  }
}
