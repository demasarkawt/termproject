import 'dart:ui';
import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  final Widget child;

  /// Corner radius (used when borderRadius is null)
  final double radius;

  /// Backdrop blur strength
  final double blur;

  /// Inner padding
  final EdgeInsets padding;

  /// Optional custom border radius
  final BorderRadius? borderRadius;

  /// Base tint color for the glass
  final Color tint;

  /// NEW name (preferred)
  final double tintOpacity;

  /// OLD name (backwards compatible)
  /// If provided, it overrides tintOpacity.
  final double? opacity;

  /// Optional border
  final bool showBorder;
  final Color borderColor;
  final double borderWidth;

  /// Optional shadow (null = none)
  final List<BoxShadow>? boxShadow;

  /// Optional highlight sheen (iOS-like)
  final bool sheen;

  const Glass({
    super.key,
    required this.child,
    this.radius = 22,
    this.blur = 16,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius,

    this.tint = Colors.white,

    // Keep your old defaults close to what you had
    this.tintOpacity = 0.18,
    this.opacity,

    this.showBorder = true,
    this.borderColor = const Color(0x66FFFFFF),
    this.borderWidth = 1,

    this.boxShadow,
    this.sheen = true,
  });

  @override
  Widget build(BuildContext context) {
    final br = borderRadius ?? BorderRadius.circular(radius);

    // ✅ If old `opacity:` is used in your screens, it still works.
    final effectiveOpacity = opacity ?? tintOpacity;

    return ClipRRect(
      borderRadius: br,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: br,
            color: tint.withOpacity(effectiveOpacity),
            border: showBorder
                ? Border.all(
              color: borderColor,
              width: borderWidth,
            )
                : null,
            boxShadow: boxShadow,
          ),
          child: Stack(
            children: [
              if (sheen)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: br,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withOpacity(0.20),
                            Colors.white.withOpacity(0.08),
                            Colors.transparent,
                          ],
                          stops: const [0.0, 0.35, 1.0],
                        ),
                      ),
                    ),
                  ),
                ),
              Padding(
                padding: padding,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
