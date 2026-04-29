import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import '../../constants/app_branding.dart';
import '../../theme/liquid_orb.dart';
import 'liquid_orb_background.dart';

/// Full-screen backdrop (optional travel photo + soft orbs) + optional [heroChild] in the top band, white card below.
class LiquidOrbAuthLayout extends StatelessWidget {
  const LiquidOrbAuthLayout({
    super.key,
    required this.cardChild,
    this.heroChild,
    this.onBack,
    this.heroFlex = 38,
    this.cardFlex = 62,
    /// When set, shows a full-bleed travel image with gradient and soft liquid orbs on top (matches splash/welcome).
    this.travelHeroAsset,
  });

  final Widget cardChild;
  final Widget? heroChild;
  final VoidCallback? onBack;
  final int heroFlex;
  final int cardFlex;
  final String? travelHeroAsset;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        _AuthBackdrop(travelHeroAsset: travelHeroAsset),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (onBack != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, right: 8, top: 4),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: onBack,
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      child: const Text(
                        '‹ Back',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      flex: heroFlex,
                      child: heroChild ??
                          (travelHeroAsset != null
                              ? const _TravelHeroCopyBand()
                              : const SizedBox.shrink()),
                    ),
                    Expanded(
                      flex: cardFlex,
                      child: Container(
                        decoration: LiquidOrb.cardDecoration,
                        clipBehavior: Clip.hardEdge,
                        child: Material(
                          color: LiquidOrb.cardWhite,
                          child: cardChild,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop({this.travelHeroAsset});

  final String? travelHeroAsset;

  @override
  Widget build(BuildContext context) {
    if (travelHeroAsset == null) {
      return const LiquidOrbBackground(fillBehindCard: true);
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: Image.asset(travelHeroAsset!, fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.18),
                  Colors.black.withValues(alpha: 0.42),
                  Colors.black.withValues(alpha: 0.78),
                ],
                stops: const [0.0, 0.42, 1.0],
              ),
            ),
          ),
        ),
        const Positioned.fill(
          child: IgnorePointer(
            child: Opacity(
              opacity: 0.42,
              child: LiquidOrbBackground(fillBehindCard: true),
            ),
          ),
        ),
      ],
    );
  }
}

/// Single branded banner above sign-in/sign-up sheet (photo hero).
class _TravelHeroCopyBand extends StatelessWidget {
  const _TravelHeroCopyBand();

  static const Color _gold = Color(0xFFD4AF37);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.32),
                  ],
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [_gold.withValues(alpha: 0.92), _gold.withValues(alpha: 0.72)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _gold.withValues(alpha: 0.35),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.explore_rounded, color: Color(0xFF1A1410), size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppBranding.appName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            height: 1.05,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppBranding.authHeroTagline,
                          style: TextStyle(
                            fontSize: 13.5,
                            height: 1.42,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.86),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          AppBranding.splashWordmarkCaps,
                          style: TextStyle(
                            color: _gold.withValues(alpha: 0.88),
                            fontSize: 10.5,
                            letterSpacing: 2.8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Four circular social stubs (OAuth can be wired later).
class LiquidOrbSocialRow extends StatelessWidget {
  const LiquidOrbSocialRow({super.key, this.onTap});

  /// Optional index 0 FB, 1 X, 2 Google, 3 Apple
  final void Function(int index)? onTap;

  static const Color _facebook = Color(0xFF1877F2);
  static const Color _x = Color(0xFF0F1419);
  static const Color _gBlue = Color(0xFF4285F4);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _wrap(
          0,
          Icon(Icons.facebook, color: _facebook, size: 22),
        ),
        _wrap(
          1,
          Text(
            '𝕏',
            style: TextStyle(color: _x, fontSize: 20, fontWeight: FontWeight.w700),
          ),
        ),
        _wrap(
          2,
          Text(
            'G',
            style: TextStyle(color: _gBlue, fontSize: 20, fontWeight: FontWeight.w800),
          ),
        ),
        _wrap(
          3,
          const Icon(Icons.apple, color: Colors.black, size: 22),
        ),
      ],
    );
  }

  Widget _wrap(int i, Widget icon) {
    return Material(
      color: LiquidOrb.cardWhite,
      shape: const CircleBorder(
        side: BorderSide(color: LiquidOrb.socialOutline),
      ),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap == null ? null : () => onTap!(i),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(child: icon),
        ),
      ),
    );
  }
}

class LiquidOrbPrimaryButton extends StatefulWidget {
  const LiquidOrbPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<LiquidOrbPrimaryButton> createState() => _LiquidOrbPrimaryButtonState();
}

class _LiquidOrbPrimaryButtonState extends State<LiquidOrbPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          width: double.infinity,
          height: 52,
          decoration: BoxDecoration(
            gradient: LiquidOrb.primaryButtonGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: LiquidOrb.accent.withOpacity(0.35),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: widget.loading ? null : widget.onPressed,
              child: Center(
                child: widget.loading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Spec-style square checkbox with blue fill when checked.
class LiquidOrbCheckboxTile extends StatelessWidget {
  const LiquidOrbCheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: Material(
                color: value ? LiquidOrb.accent : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                  side: BorderSide(
                    color: value ? LiquidOrb.accent : LiquidOrb.outlineField,
                    width: 1.5,
                  ),
                ),
                child: InkWell(
                  onTap: () => onChanged(!value),
                  child: value
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : const SizedBox.expand(),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: DefaultTextStyle.merge(
                style: LiquidOrb.labelSmall,
                child: label,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
