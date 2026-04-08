import 'package:flutter/material.dart';
import 'favorites_store.dart';

class FavoritesScope extends InheritedNotifier<FavoritesStore> {
  const FavoritesScope({
    super.key,
    required FavoritesStore notifier,
    required Widget child,
  }) : super(notifier: notifier, child: child);

  static FavoritesStore of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<FavoritesScope>();
    assert(scope != null, 'FavoritesScope not found. Wrap MaterialApp with FavoritesScope.');
    return scope!.notifier!;
  }
}
