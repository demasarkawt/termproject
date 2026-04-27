// lib/theme/kurdish_theme.dart
// ─────────────────────────────────────────────────────────────────────────────
// Kurdish Cultural Design System
// Colors from the Kurdish flag: Green · Red · White · Gold (Şems sun)
// Warmth from Zagros mountains, citadel stone, and Kurdish kilim carpets
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:math' as math;
import 'package:flutter/material.dart';

class KColors {
  KColors._();

  // ── Kurdish flag palette ──────────────────────────────────────────────────
  static const kGreen     = Color(0xFF1A6B3A); // Flag green
  static const kDarkGreen = Color(0xFF0E3D20); // Deep mountain forest
  static const kRed       = Color(0xFFC0161C); // Flag red
  static const kGold      = Color(0xFFF5B800); // Şems sun gold
  static const kGoldLight = Color(0xFFFAD84A); // Light sun shimmer

  // ── Warm cultural tones ───────────────────────────────────────────────────
  static const kCream     = Color(0xFFFDF6E3); // Kurdish parchment/textile
  static const kSand      = Color(0xFFF0E6C8); // Warm sand dune
  static const kStone     = Color(0xFF8B7355); // Erbil citadel stone
  static const kSaffron   = Color(0xFFE8920A); // Spice market saffron
  static const kDarkBrown = Color(0xFF2D1B0E); // Rich dark text

  // ── Utility ───────────────────────────────────────────────────────────────
  static const kWhite     = Color(0xFFFFFDF7); // Warm white (not cold)
  static const kDivider   = Color(0xFFE0D5B8); // Warm divider
}

// ─────────────────────────────────────────────────────────────────────────────
// Kurdish Şems (Sun) Painter — 21-ray sun from the Kurdish flag
// ─────────────────────────────────────────────────────────────────────────────
class KurdishSunPainter extends CustomPainter {
  final Color color;
  final double opacity;
  const KurdishSunPainter({this.color = KColors.kGold, this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r  = size.width / 2;

    final paint = Paint()
      ..color = color.withValues(alpha: opacity)
      ..style = PaintingStyle.fill;

    // Centre circle
    canvas.drawCircle(Offset(cx, cy), r * 0.28, paint);

    // 21 rays
    const rays = 21;
    final angle = (2 * math.pi) / rays;
    final innerR = r * 0.30;
    final outerR = r * 0.95;

    for (int i = 0; i < rays; i++) {
      final a = i * angle - math.pi / 2;

      // Each ray is a thin pointed shape
      final path = Path();
      final tipX = cx + outerR * math.cos(a);
      final tipY = cy + outerR * math.sin(a);
      final leftX = cx + innerR * math.cos(a - angle * 0.18);
      final leftY = cy + innerR * math.sin(a - angle * 0.18);
      final rightX = cx + innerR * math.cos(a + angle * 0.18);
      final rightY = cy + innerR * math.sin(a + angle * 0.18);

      path.moveTo(tipX, tipY);
      path.lineTo(leftX, leftY);
      path.lineTo(rightX, rightY);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant KurdishSunPainter old) =>
      old.color != color || old.opacity != opacity;
}

// ─────────────────────────────────────────────────────────────────────────────
// Kurdish Kilim Border Painter — geometric diamond row pattern
// ─────────────────────────────────────────────────────────────────────────────
class KilimBorderPainter extends CustomPainter {
  final Color color;
  const KilimBorderPainter({this.color = KColors.kGold});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    const diamondW = 14.0;
    const diamondH = 6.0;
    final count = (size.width / diamondW).ceil() + 1;

    for (int i = 0; i < count; i++) {
      final cx = i * diamondW + diamondW / 2;
      final cy = size.height / 2;

      final path = Path()
        ..moveTo(cx, cy - diamondH / 2)
        ..lineTo(cx + diamondW / 2, cy)
        ..lineTo(cx, cy + diamondH / 2)
        ..lineTo(cx - diamondW / 2, cy)
        ..close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant KilimBorderPainter old) => old.color != color;
}

// ─────────────────────────────────────────────────────────────────────────────
// Convenience Widgets
// ─────────────────────────────────────────────────────────────────────────────

/// A row of Kurdish kilim diamond dividers
class KilimDivider extends StatelessWidget {
  final Color color;
  final double height;
  const KilimDivider({
    super.key,
    this.color = KColors.kGold,
    this.height = 12,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: KilimBorderPainter(color: color)),
    );
  }
}

/// A Kurdish Şems sun widget
class KurdishSun extends StatelessWidget {
  final double size;
  final Color color;
  final double opacity;

  const KurdishSun({
    super.key,
    this.size = 80,
    this.color = KColors.kGold,
    this.opacity = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: KurdishSunPainter(color: color, opacity: opacity),
      ),
    );
  }
}

/// Kurdish flag-inspired tri-stripe (Green | White | Red)
class KurdishFlagStripe extends StatelessWidget {
  final double height;
  const KurdishFlagStripe({super.key, this.height = 4});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Row(
        children: [
          Expanded(child: Container(color: KColors.kGreen)),
          Expanded(child: Container(color: Colors.white)),
          Expanded(child: Container(color: KColors.kRed)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kurdish ThemeData
// ─────────────────────────────────────────────────────────────────────────────
ThemeData kurdishTheme() {
  const seed = KColors.kGreen;

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      primary: KColors.kGreen,
      secondary: KColors.kGold,
      tertiary: KColors.kRed,
      surface: KColors.kCream,
      onPrimary: Colors.white,
      onSecondary: KColors.kDarkBrown,
    ),
    scaffoldBackgroundColor: KColors.kCream,
    appBarTheme: const AppBarTheme(
      backgroundColor: KColors.kDarkGreen,
      foregroundColor: KColors.kGold,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w800,
        color: KColors.kGold,
        letterSpacing: 1.2,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: KColors.kGreen,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: KColors.kGreen),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: KColors.kSand,
      selectedColor: KColors.kGold,
      labelStyle: const TextStyle(
        color: KColors.kDarkBrown,
        fontWeight: FontWeight.w600,
      ),
      side: const BorderSide(color: KColors.kDivider),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    cardTheme: CardThemeData(
      color: KColors.kWhite,
      elevation: 2,
      shadowColor: KColors.kGold.withValues(alpha: 0.15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    dividerColor: KColors.kDivider,
  );
}
