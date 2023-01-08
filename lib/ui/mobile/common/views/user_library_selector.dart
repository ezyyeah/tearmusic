import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tearmusic/models/model.dart';
import 'package:tearmusic/providers/user_provider.dart';

typedef LibrarySelectorRetriever = List<String>? Function(UserProvider);

class UserLibrarySelector<T> extends StatelessWidget {
  const UserLibrarySelector({super.key, required this.child, required this.librarySelectorRetriever, required this.emptyText});

  final Widget child;
  final LibrarySelectorRetriever librarySelectorRetriever;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return Selector<UserProvider, List<String>>(
      selector: (_, user) => librarySelectorRetriever(user) ?? [],
      shouldRebuild: (previous, next) {
        return !listEquals(previous, next);
      },
      builder: ((context, value, _) {
        if (value.isEmpty) {
          return Padding(
            padding: const EdgeInsets.only(top: 6.0, bottom: 24.0),
            child: Center(
              child: Text(emptyText),
            ),
          );
        }

        return child;
      }),
    );
  }
}
