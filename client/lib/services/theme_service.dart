import 'package:flutter/material.dart';

/// Kurdish heritage palette - mirrored verbatim in
/// `dashboard/src/index.css` so the dashboard and Flutter app speak the
/// same color language.
class KurdishHeritageColors {
  static const Color sor = Color(0xFF7A1F1F);   // Crimson
  static const Color kesk = Color(0xFF3F4A2A);  // Olive green
  static const Color zer = Color(0xFFB8862F);   // Aged gold
  static const Color spi = Color(0xFFF5EFE2);   // Bone paper
  static const Color xweli = Color(0xFF5A3A22); // Earth umber
  static const Color res = Color(0xFF1A1410);   // Ink

  // Surface tokens – light
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surface2Light = Color(0xFFF5EFE2);
  static const Color surface3Light = Color(0xFFEDE6D6);
  static const Color borderLight = Color(0xFFE7E0CF);
  static const Color textMutedLight = Color(0xFF6B6157);
  static const Color textSubtleLight = Color(0xFF948A7E);

  // Surface tokens – dark
  static const Color surfaceDark = Color(0xFF14110D);
  static const Color surface2Dark = Color(0xFF1A1410);
  static const Color surface3Dark = Color(0xFF221C16);
  static const Color cardDark = Color(0xFF1F1A14);
  static const Color borderDark = Color(0xFF3A322B);
  static const Color textMutedDark = Color(0xFFC8BFAF);
  static const Color textSubtleDark = Color(0xFF948A7E);
}

/// Shared corner radii – also mirrored in the dashboard tokens.
class KurdishHeritageRadii {
  static const double card = 20;
  static const double cardLarge = 28;
  static const double pill = 999;
  static const double chip = 12;
}

/// Shared typography scale.
class KurdishHeritageTypography {
  static TextStyle h1(BuildContext ctx) => TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface,
        fontSize: 32,
        fontWeight: FontWeight.w900,
        letterSpacing: -1,
      );
  static TextStyle h2(BuildContext ctx) => TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.4,
      );
  static TextStyle body(BuildContext ctx) => TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface,
        fontSize: 14,
      );
  static TextStyle caption(BuildContext ctx) => TextStyle(
        color: Theme.of(ctx).colorScheme.onSurface.withValues(alpha: 0.6),
        fontSize: 12,
      );
}

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  // Default to light to match the dashboard.
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: KurdishHeritageColors.zer,
      brightness: Brightness.light,
      primary: KurdishHeritageColors.zer,
      secondary: KurdishHeritageColors.kesk,
      tertiary: KurdishHeritageColors.sor,
      surface: KurdishHeritageColors.surfaceLight,
      onSurface: KurdishHeritageColors.res,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: KurdishHeritageColors.surface2Light,
      colorScheme: scheme,
      cardColor: KurdishHeritageColors.surfaceLight,
      dividerColor: KurdishHeritageColors.borderLight,
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          color: KurdishHeritageColors.res,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(color: KurdishHeritageColors.res),
        bodyMedium: const TextStyle(color: KurdishHeritageColors.res),
        labelLarge: TextStyle(color: KurdishHeritageColors.res.withValues(alpha: 0.8)),
      ),
      iconTheme: const IconThemeData(color: KurdishHeritageColors.res),
      cardTheme: CardThemeData(
        color: KurdishHeritageColors.surfaceLight,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KurdishHeritageRadii.card),
          side: const BorderSide(color: KurdishHeritageColors.borderLight),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KurdishHeritageColors.surfaceLight,
        hintStyle: const TextStyle(
          color: KurdishHeritageColors.textSubtleLight,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KurdishHeritageRadii.card),
          borderSide: const BorderSide(color: KurdishHeritageColors.borderLight),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KurdishHeritageRadii.card),
          borderSide: const BorderSide(color: KurdishHeritageColors.borderLight),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(KurdishHeritageRadii.card),
          borderSide: const BorderSide(color: KurdishHeritageColors.zer, width: 2),
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: KurdishHeritageColors.surface2Light,
        foregroundColor: KurdishHeritageColors.res,
        elevation: 0,
      ),
    );
  }

  ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: KurdishHeritageColors.zer,
      brightness: Brightness.dark,
      primary: KurdishHeritageColors.zer,
      secondary: KurdishHeritageColors.kesk,
      tertiary: KurdishHeritageColors.sor,
      surface: KurdishHeritageColors.surfaceDark,
      onSurface: KurdishHeritageColors.spi,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KurdishHeritageColors.surfaceDark,
      colorScheme: scheme,
      cardColor: KurdishHeritageColors.cardDark,
      dividerColor: KurdishHeritageColors.borderDark,
      textTheme: TextTheme(
        headlineLarge: const TextStyle(
          color: KurdishHeritageColors.spi,
          fontWeight: FontWeight.bold,
        ),
        bodyLarge: const TextStyle(color: KurdishHeritageColors.spi),
        bodyMedium: const TextStyle(color: KurdishHeritageColors.spi),
        labelLarge: TextStyle(color: KurdishHeritageColors.spi.withValues(alpha: 0.8)),
      ),
      iconTheme: const IconThemeData(color: KurdishHeritageColors.spi),
      appBarTheme: const AppBarTheme(
        backgroundColor: KurdishHeritageColors.surfaceDark,
        foregroundColor: KurdishHeritageColors.spi,
        elevation: 0,
      ),
    );
  }
}

final themeService = ThemeService();
