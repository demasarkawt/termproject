import 'package:flutter/material.dart';

class KurdishHeritageColors {
  static const Color sor = Color(0xFF7A1F1F);   // Crimson
  static const Color kesk = Color(0xFF3F4A2A);  // Olive
  static const Color zer = Color(0xFFB8862F);   // Aged gold
  static const Color spi = Color(0xFFF5EFE2);   // Bone paper
  static const Color xweli = Color(0xFF5A3A22); // Earth umber
  static const Color res = Color(0xFF1A1410);   // Ink
}

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();
  factory ThemeService() => _instance;
  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
  }

  ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: KurdishHeritageColors.spi,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KurdishHeritageColors.zer,
        brightness: Brightness.light,
        primary: KurdishHeritageColors.zer,
        secondary: KurdishHeritageColors.xweli,
        background: KurdishHeritageColors.spi,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: KurdishHeritageColors.res, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: KurdishHeritageColors.res),
      ),
    );
  }

  ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: KurdishHeritageColors.res,
      colorScheme: ColorScheme.fromSeed(
        seedColor: KurdishHeritageColors.zer,
        brightness: Brightness.dark,
        primary: KurdishHeritageColors.zer,
        secondary: KurdishHeritageColors.xweli,
        background: KurdishHeritageColors.res,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(color: KurdishHeritageColors.spi, fontWeight: FontWeight.bold),
        bodyLarge: TextStyle(color: KurdishHeritageColors.spi),
      ),
    );
  }
}
