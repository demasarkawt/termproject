import 'package:flutter/material.dart';

import 'app_router.dart'; // <-- CHANGE to your router file name
import 'data/favorites_store.dart';
import 'data/favorites_scope.dart';

final favoritesStore = FavoritesStore();

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FavoritesScope(
      notifier: favoritesStore,
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        routerConfig: appRouter,
      ),
    );
  }
}
