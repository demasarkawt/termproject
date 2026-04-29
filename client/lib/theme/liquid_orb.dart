import 'package:flutter/material.dart';

/// "Liquid Orb" mobile auth palette — navy / periwinkle / vivid blue.
abstract final class LiquidOrb {
  static const Color navy = Color(0xFF0d1b4b);
  static const Color periwinkle = Color(0xFF6b7fd4);
  static const Color sky = Color(0xFF5ba4f5);
  static const Color pearl = Color(0xFFe8f0fe);
  static const Color indigoOrb = Color(0xFF3a3f9e);
  static const Color midnight = Color(0xFF0a1240);

  static const Color cardWhite = Color(0xFFFFFFFF);
  static const Color outlineField = Color(0xFFdde3f0);
  static const Color textHeading = Color(0xFF1a2980);
  static const Color textLabel = Color(0xFF6b7280);
  static const Color textMuted = Color(0xFF8899bb);
  static const Color textSoftBlue = Color(0xFFa8c0f0);
  static const Color placeholder = Color(0xFFb0bcd0);
  static const Color accent = Color(0xFF3B5BDB);
  static const Color accentEnd = Color(0xFF5B7FFF);
  static const Color snackBarError = Color(0xFFC62828);
  static const Color socialOutline = Color(0xFFe0e7f0);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navy, periwinkle, midnight],
    stops: [0.0, 0.55, 1.0],
  );

  static const LinearGradient primaryButtonGradient = LinearGradient(
    colors: [accent, accentEnd],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const TextStyle heading = TextStyle(
    color: textHeading,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.2,
  );

  static const TextStyle subtitleCaps = TextStyle(
    color: textMuted,
    fontSize: 11,
    letterSpacing: 0.55,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle labelSmall = TextStyle(
    color: textLabel,
    fontSize: 13,
    fontWeight: FontWeight.w500,
  );

  static const BoxDecoration cardDecoration = BoxDecoration(
    color: cardWhite,
    borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    boxShadow: [
      BoxShadow(
        color: Color(0x1F000000),
        blurRadius: 40,
        offset: Offset(0, -8),
      ),
    ],
  );

  static InputDecoration orbInputDecoration({
    required String hint,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: placeholder, fontSize: 14),
      suffixIcon: suffix,
      filled: true,
      fillColor: cardWhite,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: outlineField),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: accent, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: snackBarError),
      ),
    );
  }
}
