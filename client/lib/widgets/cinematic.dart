// Everything in this file follows the timing/curve rules from
// ANIMATION_PLAN.md. Don't add helpers that break those rules.
//
// Drop this file into your project at: lib/widgets/cinematic.dart
 
import 'dart:math' as math;
import 'dart:ui';
 
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
 
// ─────────────────────────── Motion tokens ──────────────────────────────────
 
class Motion {
  static const xs = Duration(milliseconds: 120);
  static const sm = Duration(milliseconds: 220);
  static const md = Duration(milliseconds: 380);
  static const lg = Duration(milliseconds: 600);
  static const xl = Duration(milliseconds: 900);
  static const epic = Duration(milliseconds: 1400);
 
  // Approved curves only.
  static const arrive = Curves.easeOutCubic;
  static const between = Curves.easeInOutCubic;
  static const hero = Curves.easeOutQuint;
  static const page = Curves.fastOutSlowIn;
  static const pop = Curves.elasticOut;
}
 
// ─────────────────────────── PressScale ─────────────────────────────────────
// Wrap any tappable surface in this. Scales to 0.97 on press.
 
class PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;
  final HitTestBehavior behavior;
 
  const PressScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.97,
    this.behavior = HitTestBehavior.opaque,
  });
 
  @override
  State<PressScale> createState() => _PressScaleState();
}
 
class _PressScaleState extends State<PressScale> {
  bool _down = false;
 
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: (_) => setState(() => _down = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _down ? widget.pressedScale : 1.0,
        duration: _down ? Motion.xs : Motion.sm,
        curve: Motion.arrive,
        child: widget.child,
      ),
    );
  }
}
 
// ─────────────────────────── Glass ──────────────────────────────────────────
// Use only for: top bars, bottom nav, floating chips, sheets.
 
class Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final double opacity;
  final double borderOpacity;
  final EdgeInsets padding;
 
  const Glass({
    super.key,
    required this.child,
    this.radius = 20,
    this.blur = 18,
    this.opacity = 0.06,
    this.borderOpacity = 0.10,
    this.padding = const EdgeInsets.all(0),
  });
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tint = isDark ? Colors.white : Colors.black;
    final cappedBlur = blur.clamp(0.0, 20.0);
 
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: cappedBlur, sigmaY: cappedBlur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: tint.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: tint.withOpacity(borderOpacity),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
 
// ─────────────────────────── StaggerEnter ───────────────────────────────────
// Animate a list of children in with 40ms stagger, capped at 8.
 
class StaggerEnter extends StatefulWidget {
  final List<Widget> children;
  final Axis axis;
  final double offset;
  final Duration delay;
 
  const StaggerEnter({
    super.key,
    required this.children,
    this.axis = Axis.vertical,
    this.offset = 18,
    this.delay = Duration.zero,
  });
 
  @override
  State<StaggerEnter> createState() => _StaggerEnterState();
}
 
class _StaggerEnterState extends State<StaggerEnter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    final total = Motion.md.inMilliseconds + 40 * 8;
    _ctrl = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: total),
    );
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    final children = widget.children;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: List.generate(children.length, (i) {
            final stepIndex = math.min(i, 8);
            final start = (stepIndex * 40) / _ctrl.duration!.inMilliseconds;
            final end =
                (stepIndex * 40 + Motion.md.inMilliseconds) /
                    _ctrl.duration!.inMilliseconds;
            final t = CurvedAnimation(
              parent: _ctrl,
              curve: Interval(start, end.clamp(0, 1), curve: Motion.arrive),
            );
            return AnimatedBuilder(
              animation: t,
              builder: (context, child) {
                final v = t.value;
                final dy = widget.axis == Axis.vertical
                    ? widget.offset * (1 - v)
                    : 0.0;
                final dx = widget.axis == Axis.horizontal
                    ? widget.offset * (1 - v)
                    : 0.0;
                return Opacity(
                  opacity: v,
                  child: Transform.translate(
                    offset: Offset(dx, dy),
                    child: child,
                  ),
                );
              },
              child: children[i],
            );
          }),
        );
      },
    );
  }
}
 
// ─────────────────────────── RevealText ─────────────────────────────────────
// Headline that wipes in with a left-to-right shader mask.
 
class RevealText extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final TextAlign textAlign;
  final Duration duration;
  final Duration delay;
  final int? maxLines;
 
  const RevealText(
    this.text, {
    super.key,
    this.style,
    this.textAlign = TextAlign.start,
    this.duration = Motion.lg,
    this.delay = Duration.zero,
    this.maxLines,
  });
 
  @override
  State<RevealText> createState() => _RevealTextState();
}
 
class _RevealTextState extends State<RevealText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    Future.delayed(widget.delay, () {
      if (mounted) _ctrl.forward();
    });
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Motion.arrive.transform(_ctrl.value);
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [Colors.white, Colors.white, Colors.transparent],
              stops: [0, t, t.clamp(0, 1)],
            ).createShader(bounds);
          },
          blendMode: BlendMode.dstIn,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: Text(
              widget.text,
              style: widget.style,
              textAlign: widget.textAlign,
              maxLines: widget.maxLines,
              overflow: widget.maxLines == null ? null : TextOverflow.ellipsis,
            ),
          ),
        );
      },
    );
  }
}
 
// ─────────────────────────── CountUp ────────────────────────────────────────
// Animates an integer 0 → value over Motion.xl with easeOutCubic.
 
class CountUp extends StatelessWidget {
  final int value;
  final TextStyle? style;
  final String suffix;
 
  const CountUp(
    this.value, {
    super.key,
    this.style,
    this.suffix = '',
  });
 
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: Motion.xl,
      curve: Motion.arrive,
      builder: (context, v, _) =>
          Text('${v.toInt()}$suffix', style: style),
    );
  }
}
 
// ─────────────────────────── GoldRingSweep ──────────────────────────────────
// Rotating gradient ring used in splash + profile avatar.
 
class GoldRingSweep extends StatefulWidget {
  final double size;
  final double thickness;
  final Color color;
  final Widget child;
  final Duration duration;
 
  const GoldRingSweep({
    super.key,
    required this.child,
    this.size = 130,
    this.thickness = 2,
    this.color = const Color(0xFFB8862F),
    this.duration = const Duration(seconds: 5),
  });
 
  @override
  State<GoldRingSweep> createState() => _GoldRingSweepState();
}
 
class _GoldRingSweepState extends State<GoldRingSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.rotate(
              angle: _ctrl.value * 2 * math.pi,
              child: CustomPaint(
                size: Size.square(widget.size),
                painter: _RingPainter(
                  color: widget.color,
                  thickness: widget.thickness,
                ),
              ),
            ),
          ),
          widget.child,
        ],
      ),
    );
  }
}
 
class _RingPainter extends CustomPainter {
  final Color color;
  final double thickness;
  _RingPainter({required this.color, required this.thickness});
 
  @override
  void paint(Canvas canvas, Size size) {
    final r = math.min(size.width, size.height) / 2 - thickness;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: r);
    final shader = SweepGradient(
      startAngle: 0,
      endAngle: 2 * math.pi,
      colors: [
        color.withOpacity(0.0),
        color.withOpacity(0.0),
        color.withOpacity(0.7),
        color,
        color.withOpacity(0.0),
      ],
      stops: const [0.0, 0.55, 0.75, 0.85, 1.0],
    ).createShader(rect);
 
    canvas.drawArc(
      rect,
      0,
      2 * math.pi,
      false,
      Paint()
        ..shader = shader
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = thickness,
    );
  }
 
  @override
  bool shouldRepaint(covariant _RingPainter old) => false;
}
 
// ─────────────────────────── IrisWipe ───────────────────────────────────────
// Full-screen white circle wipe; use as a hand-off effect on big nav.
 
class IrisWipe extends StatefulWidget {
  final VoidCallback onCompleted;
  final Color color;
  const IrisWipe({super.key, required this.onCompleted, this.color = Colors.white});
 
  @override
  State<IrisWipe> createState() => _IrisWipeState();
}
 
class _IrisWipeState extends State<IrisWipe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: Motion.lg)
      ..addStatusListener((s) {
        if (s == AnimationStatus.completed) widget.onCompleted();
      })
      ..forward();
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final t = Motion.hero.transform(_ctrl.value);
        return IgnorePointer(
          ignoring: _ctrl.value < 1,
          child: CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _IrisPainter(t: t, color: widget.color),
          ),
        );
      },
    );
  }
}
 
class _IrisPainter extends CustomPainter {
  final double t;
  final Color color;
  _IrisPainter({required this.t, required this.color});
 
  @override
  void paint(Canvas canvas, Size size) {
    final maxR = math.sqrt(size.width * size.width + size.height * size.height);
    final r = maxR * t;
    canvas.drawCircle(size.center(Offset.zero), r,
        Paint()..color = color);
  }
 
  @override
  bool shouldRepaint(covariant _IrisPainter old) => old.t != t;
}
 
// ─────────────────────────── Parallax helpers ───────────────────────────────
 
/// Multiply scroll offset by [speed] for a layer that should lag scroll.
/// Recommended speeds: 0.30, 0.45, 0.60.
double parallax(double offset, double speed) => offset * speed;
 
// ─────────────────────────── Floating bob ───────────────────────────────────
 
class FloatingBob extends StatefulWidget {
  final Widget child;
  final double amount;
  final Duration duration;
 
  const FloatingBob({
    super.key,
    required this.child,
    this.amount = 6,
    this.duration = const Duration(seconds: 2),
  });
 
  @override
  State<FloatingBob> createState() => _FloatingBobState();
}
 
class _FloatingBobState extends State<FloatingBob>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final t = Motion.between.transform(_ctrl.value);
        return Transform.translate(
          offset: Offset(0, -widget.amount * t),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}
 
// ─────────────────────────── ShimmerLine ────────────────────────────────────
// Simple gold underline that sweeps left→right; use sparingly.
 
class ShimmerLine extends StatefulWidget {
  final double width;
  final double height;
  final Color color;
  final Duration duration;
 
  const ShimmerLine({
    super.key,
    this.width = 60,
    this.height = 1.5,
    this.color = const Color(0xFFB8862F),
    this.duration = const Duration(milliseconds: 1800),
  });
 
  @override
  State<ShimmerLine> createState() => _ShimmerLineState();
}
 
class _ShimmerLineState extends State<ShimmerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final t = _ctrl.value;
          return ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Colors.transparent,
                  widget.color,
                  Colors.transparent,
                ],
                stops: [
                  (t - 0.3).clamp(0, 1),
                  t.clamp(0, 1),
                  (t + 0.3).clamp(0, 1),
                ],
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Container(color: widget.color),
          );
        },
      ),
    );
  }
}
 
// ─────────────────────────── Tilt3D ─────────────────────────────────────────
// 3D rotateY based on a normalized [-1, 1] position in a horizontal list.
 
class Tilt3D extends StatelessWidget {
  final double t; // -1 (left edge) to 1 (right edge), 0 = center
  final Widget child;
  final double maxAngle;
 
  const Tilt3D({
    super.key,
    required this.t,
    required this.child,
    this.maxAngle = 0.18,
  });
 
  @override
  Widget build(BuildContext context) {
    final angle = -t.clamp(-1.0, 1.0) * maxAngle;
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.0012) // perspective
        ..rotateY(angle),
      child: child,
    );
  }
}
 
// ─────────────────────────── ScrollReveal ───────────────────────────────────
// Fires a one-shot enter animation when the widget first appears in viewport.
 
class ScrollReveal extends StatefulWidget {
  final Widget child;
  final double offset;
  final Duration duration;
 
  const ScrollReveal({
    super.key,
    required this.child,
    this.offset = 18,
    this.duration = Motion.md,
  });
 
  @override
  State<ScrollReveal> createState() => _ScrollRevealState();
}
 
class _ScrollRevealState extends State<ScrollReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: widget.duration);
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctrl.forward();
    });
  }
 
  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final v = Motion.arrive.transform(_ctrl.value);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, widget.offset * (1 - v)),
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}
