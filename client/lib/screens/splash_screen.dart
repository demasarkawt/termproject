// Polished cinematic splash screen.
// - Drop into: lib/screens/splash_screen.dart
// - Requires: lib/widgets/cinematic.dart (in ui_v2/) and the existing
//   user_session + theme_service + image asset(s).
//
// Motion language follows ANIMATION_PLAN.md.
 
import 'dart:math' as math;
import 'dart:ui';
 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../services/user_session.dart';
import '../services/theme_service.dart';
import '../widgets/cinematic.dart';
 
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
 
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}
 
class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _enter;
  late final AnimationController _kenBurns;
  bool _wiping = false;
 
  @override
  void initState() {
    super.initState();
    _enter = AnimationController(vsync: this, duration: Motion.epic)..forward();
    _kenBurns = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat(reverse: true);
  }
 
  @override
  void dispose() {
    _enter.dispose();
    _kenBurns.dispose();
    super.dispose();
  }
 
  void _navigate() {
    if (_wiping) return;
    setState(() => _wiping = true);
  }
 
  void _afterWipe() {
    if (UserSession.isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/onboarding1');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildKenBurnsBackground(),
          _buildBlurReveal(),
          _buildVignette(),
          const _ParticleField(),
          SafeArea(child: _buildContent()),
          if (_wiping) IrisWipe(onCompleted: _afterWipe),
        ],
      ),
    );
  }
 
  Widget _buildKenBurnsBackground() {
    return AnimatedBuilder(
      animation: _kenBurns,
      builder: (context, child) {
        final s = 1.0 + 0.18 * Motion.between.transform(_kenBurns.value);
        return Transform.scale(
          scale: s,
          alignment: const Alignment(0, -0.05),
          child: child,
        );
      },
      child: Image.asset(
        'assets/images/place_citadel.png',
        fit: BoxFit.cover,
      ),
    );
  }
 
  Widget _buildBlurReveal() {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final t = Motion.arrive.transform(_enter.value.clamp(0.0, 0.4) / 0.4);
        final blur = 18 * (1 - t);
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(color: Colors.black.withOpacity(0.30 * (1 - t * 0.3))),
        );
      },
    );
  }
 
  Widget _buildVignette() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x55000000),
            Color(0x11000000),
            Color(0xAA000000),
            Color(0xEE000000),
          ],
          stops: [0, 0.4, 0.7, 1],
        ),
      ),
    );
  }
 
  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          const Spacer(flex: 3),
          _buildBrand(),
          const SizedBox(height: 28),
          _buildTagline(),
          const Spacer(flex: 2),
          _buildBeginButton(),
          const SizedBox(height: 18),
          _buildFooter(),
          const SizedBox(height: 36),
        ],
      ),
    );
  }
 
  Widget _buildBrand() {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        // Brand fades+scales in over 0.2-0.6 of the controller.
        final raw = ((_enter.value - 0.2) / 0.4).clamp(0.0, 1.0);
        final t = Motion.arrive.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.scale(
            scale: 0.92 + 0.08 * t,
            child: GoldRingSweep(
              size: 130, // Increased size to feel more premium and fit text
              thickness: 2.0,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                children: [
                  _miniRule(),
                  const SizedBox(height: 18),
                    const Text(
                      'TRAVELO',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 10,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'DISCOVER KURDISTAN',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        );
      },
    );
  }
 
  Widget _miniRule() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(width: 40, height: 1, child: ColoredBox(color: KurdishHeritageColors.zer)),
        SizedBox(width: 12),
        Text(
          'DISCOVER',
          style: TextStyle(
            color: KurdishHeritageColors.zer,
            fontSize: 10,
            letterSpacing: 6,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(width: 12),
        SizedBox(width: 40, height: 1, child: ColoredBox(color: KurdishHeritageColors.zer)),
      ],
    );
  }
 
  Widget _buildTagline() {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final raw = ((_enter.value - 0.4) / 0.4).clamp(0.0, 1.0);
        final t = Motion.arrive.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - t)),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Where ancient mountains meet\nmodern adventure',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xCCFFFFFF),
                  fontSize: 16,
                  height: 1.7,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
 
  Widget _buildBeginButton() {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final raw = ((_enter.value - 0.7) / 0.3).clamp(0.0, 1.0);
        final t = Motion.arrive.transform(raw);
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, 24 * (1 - t)),
            child: PressScale(
              onTap: _navigate,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: KurdishHeritageColors.zer.withOpacity(0.85),
                    width: 1.4,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: const [
                    Text(
                      'BEGIN YOUR JOURNEY',
                      style: TextStyle(
                        color: KurdishHeritageColors.zer,
                        fontSize: 12,
                        letterSpacing: 5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
 
  Widget _buildFooter() {
    return AnimatedBuilder(
      animation: _enter,
      builder: (context, _) {
        final raw = ((_enter.value - 0.8) / 0.2).clamp(0.0, 1.0);
        final t = Motion.arrive.transform(raw);
        return Opacity(
          opacity: t,
          child: Column(
            children: const [
              Text(
                'Tap to enter',
                style: TextStyle(
                  color: Color(0x66FFFFFF),
                  fontSize: 10,
                  letterSpacing: 3,
                ),
              ),
              SizedBox(height: 12),
              _ScrollHint(),
            ],
          ),
        );
      },
    );
  }
}
 
// ─────────── Particle field ───────────
 
class _ParticleField extends StatefulWidget {
  const _ParticleField();
 
  @override
  State<_ParticleField> createState() => _ParticleFieldState();
}
 
class _ParticleFieldState extends State<_ParticleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..repeat();
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
      builder: (_, __) => CustomPaint(painter: _ParticlePainter(_ctrl.value)),
    );
  }
}
 
class _ParticlePainter extends CustomPainter {
  final double progress;
  _ParticlePainter(this.progress);
 
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(27);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 28; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.18 + 0.04;
      final radius = rng.nextDouble() * 1.4 + 0.4;
      final baseOpacity = rng.nextDouble() * 0.28 + 0.08;
      final y = (baseY - progress * speed * size.height) % size.height;
      final twinkle =
          baseOpacity * math.sin(progress * math.pi * 2 + i).abs();
      paint.color = KurdishHeritageColors.zer.withOpacity(twinkle);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
 
  @override
  bool shouldRepaint(covariant _ParticlePainter old) =>
      old.progress != progress;
}
 
// ─────────── Scroll hint ───────────
 
class _ScrollHint extends StatefulWidget {
  const _ScrollHint();
 
  @override
  State<_ScrollHint> createState() => _ScrollHintState();
}
 
class _ScrollHintState extends State<_ScrollHint>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
 
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
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
      builder: (_, __) {
        final t = Motion.between.transform(_ctrl.value);
        return Container(
          width: 22,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.4),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment(0, -0.5 + t),
          child: Container(
            width: 4,
            height: 7,
            decoration: BoxDecoration(
              color: KurdishHeritageColors.zer,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}
