import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_router.dart';
import 'data/favorites_store.dart';
import 'data/favorites_scope.dart';
import 'services/user_session.dart';
import 'theme/kurdish_theme.dart';

final favoritesStore = FavoritesStore();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UserSession.load();

  // Kurdish cultural status bar: dark green bar with gold icons
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: KColors.kDarkGreen,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: KColors.kDarkGreen,
    systemNavigationBarIconBrightness: Brightness.light,
  ));

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
        title: 'Kurdistan Go',
        theme: kurdishTheme(),
        routerConfig: appRouter,
      ),
    );
  }
}
