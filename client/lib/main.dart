import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app_router.dart';
import 'config/api_config.dart';
import 'data/favorites_store.dart';
import 'data/favorites_scope.dart';
import 'data/live_data.dart';
import 'services/user_session.dart';
import 'services/theme_service.dart';

final favoritesStore = FavoritesStore();
// themeService moved to services/theme_service.dart

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kDebugMode) {
    debugPrint('[Kurdistan Go] API base URL → $kBaseUrl');
  }
  await UserSession.load();
  // Warm the live-data cache from the FastAPI backend in the background.
  // The bundled seed data is used until this completes (or if it fails).
  unawaited(LiveData.refresh());
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        return ValueListenableBuilder<int>(
          valueListenable: LiveData.version,
          builder: (context, _, __) {
            return FavoritesScope(
              notifier: favoritesStore,
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                title: 'Travelo',
                theme: themeService.lightTheme,
                darkTheme: themeService.darkTheme,
                themeMode: themeService.themeMode,
                routerConfig: appRouter,
              ),
            );
          },
        );
      },
    );
  }
}
