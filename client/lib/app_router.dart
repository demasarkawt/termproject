import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

// Shell
import 'screens/shell/app_shell.dart';

// Screens (no bottom bar)
import 'screens/splash_screen.dart';
import 'screens/onboarding_1.dart';
import 'screens/onboarding_2.dart';
import 'screens/onboarding_3.dart';
import 'screens/auth/signin_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/code_sent_screen.dart';

// Screens (with bottom bar)
import 'screens/home/home_screen.dart';
import 'screens/cities/city_screen.dart';
import 'screens/places/places_list_screen.dart';
import 'screens/places/place_detail_screen.dart';

// Map
import 'screens/map/map_tab_screen.dart';
import 'screens/map/place_map_screen.dart';

// Tabs
import 'screens/profile/profile_screen.dart';
import 'screens/explore/explore_screen.dart';
import 'screens/activities/activities_screen.dart';
import 'screens/events/events_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

Page<T> _cupertinoPage<T>({
  required GoRouterState state,
  required Widget child,
}) {
  return CupertinoPage<T>(key: state.pageKey, child: child);
}

final appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  routes: [
    // ---------- NO BOTTOM BAR ----------
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: const SplashScreen(),
      ),
    ),
    GoRoute(
      path: '/onboarding1',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: const Onboarding1(),
      ),
    ),
    GoRoute(
      path: '/onboarding2',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: const Onboarding2(),
      ),
    ),
    GoRoute(
      path: '/onboarding3',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: const Onboarding3(),
      ),
    ),
    GoRoute(
      path: '/signin',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: const SignInScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: const SignUpScreen(),
      ),
    ),
    GoRoute(
      path: '/forgot',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: const ForgotPasswordScreen(),
      ),
    ),
    GoRoute(
      path: '/code-sent',
      pageBuilder: (context, state) => _cupertinoPage(
        state: state,
        child: CodeSentScreen(
          email: state.uri.queryParameters['email'] ?? '',
        ),
      ),
    ),

    // ---------- WITH BOTTOM BAR ----------
    ShellRoute(
      navigatorKey: _shellKey,
      builder: (context, state, child) => AppShell(child: child),
      routes: [
        // Tabs (inside shell)
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: const HomeScreen(),
          ),
        ),
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: const ExploreScreen(),
          ),
        ),
        GoRoute(
          path: '/activities',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: const ActivitiesScreen(),
          ),
        ),
        GoRoute(
          path: '/events',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: const EventsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: const ProfileScreen(),
          ),
        ),

        // Flow screens (inside shell)
        GoRoute(
          path: '/city/:cityId',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: CityScreen(
              cityId: state.pathParameters['cityId']!,
            ),
          ),
        ),
        GoRoute(
          path: '/city/:cityId/category/:categoryId',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: PlacesListScreen(
              cityId: state.pathParameters['cityId']!,
              categoryId: state.pathParameters['categoryId']!,
            ),
          ),
        ),
        GoRoute(
          path: '/place/:placeId',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: PlaceDetailScreen(
              placeId: state.pathParameters['placeId']!,
            ),
          ),
        ),
        GoRoute(
          path: '/place-map',
          pageBuilder: (context, state) => _cupertinoPage(
            state: state,
            child: PlaceMapScreen(
              title: state.uri.queryParameters['title'] ?? 'Directions',
              lat: double.tryParse(state.uri.queryParameters['lat'] ?? '') ?? 0,
              lng: double.tryParse(state.uri.queryParameters['lng'] ?? '') ?? 0,
            ),
          ),
        ),
      ],
    ),
  ],
);
