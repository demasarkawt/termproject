import 'package:flutter/material.dart';

import 'app_router.dart';
import 'data/favorites_store.dart';
import 'data/favorites_scope.dart';
import 'services/user_session.dart';

final favoritesStore = FavoritesStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.load();
  runApp(const MyApp());
}

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
