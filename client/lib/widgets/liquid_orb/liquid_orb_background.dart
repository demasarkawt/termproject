import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../theme/liquid_orb.dart';

/// Deep gradient + overlapping radial “orbs”.
///
/// Use [fillBehindCard] true for splash and full-screen auth stacks; false keeps
/// orb math relative to [heroHeightFraction] of height (narrower band — optional).
class LiquidOrbBackground extends StatefulWidget {
  const LiquidOrbBackground({
    super.key,
    this.heroHeightFraction = 0.41,
    this.fillBehindCard = false,
  });

  /// When [fillBehindCard] is false, orb anchors use this fraction of viewport height.
  final double heroHeightFraction;

  /// If true, orbs distribute across full viewport height (e.g. behind a bottom card).
  final bool fillBehindCard;

  @override
  State<LiquidOrbBackground> createState() => _LiquidOrbBackgroundState();
}

class _LiquidOrbBackgroundState extends State<LiquidOrbBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  static const List<_OrbDef> _orbs = [
    _OrbDef(0.12, 0.08, 0.72, 0.88, LiquidOrb.sky, LiquidOrb.pearl),
    _OrbDef(0.58, 0.05, 0.58, 0.76, LiquidOrb.indigoOrb, LiquidOrb.sky),
    _OrbDef(0.04, 0.28, 0.74, 0.52, Colors.white, LiquidOrb.periwinkle),
    _OrbDef(0.76, 0.14, 0.52, 0.82, LiquidOrb.pearl, LiquidOrb.sky),
    _OrbDef(0.38, 0.18, 0.68, 0.62, LiquidOrb.sky, LiquidOrb.midnight),
    _OrbDef(0.90, 0.22, 0.42, 0.70, LiquidOrb.indigoOrb, LiquidOrb.pearl),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final orbBandH =
        widget.fillBehindCard ? size.height : size.height * widget.heroHeightFraction;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final phase = _controller.value * 2 * math.pi;
        return SizedBox.expand(
          child: ClipRect(
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(gradient: LiquidOrb.heroGradient),
                ),
                for (var i = 0; i < _orbs.length; i++)
                  _buildOrb(size, orbBandH, _orbs[i], phase + i * 0.85),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrb(Size size, double orbBandH, _OrbDef o, double phase) {
    final w = size.width;
    final anchorH = widget.fillBehindCard ? size.height : orbBandH;
    final float = math.sin(phase) * 8;
    final d = (widget.fillBehindCard ? size.shortestSide : orbBandH) * o.relDiameter;

    return Positioned(
      left: w * o.cx - d / 2,
      top: anchorH * o.cy - d / 2 + float,
      child: Opacity(
        opacity: o.layerOpacity.clamp(0.35, 0.92),
        child: Container(
          width: d,
          height: d,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                o.light.withOpacity(0.95),
                o.dark.withOpacity(0.92),
              ],
              stops: const [0.12, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: o.dark.withOpacity(0.28),
                blurRadius: 36,
                spreadRadius: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrbDef {
  const _OrbDef(
    this.cx,
    this.cy,
    this.relDiameter,
    this.layerOpacity,
    this.light,
    this.dark,
  );

  /// 0–1 anchor X/Y within width / [anchorH].
  final double cx;
  final double cy;

  /// Diameter factor relative to [shortestSide] or orb band height.
  final double relDiameter;

  /// 0–1-ish; clamped when painting.
  final double layerOpacity;
  final Color light;
  final Color dark;
}
