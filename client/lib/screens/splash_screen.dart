import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_session.dart';
import '../services/theme_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _shimmerController;

  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<double> _bgScale;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _buttonFade;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _blur;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2500));
    _scaleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 10000));
    _slideController = AnimationController(vsync: this, duration: const Duration(milliseconds: 2800));
    _shimmerController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);

    _bgScale = Tween<double>(begin: 1.0, end: 1.25).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _blur = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.2, 0.6, curve: Curves.easeOut)),
    );

    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.4, 0.8, curve: Curves.easeOut)),
    );

    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: const Interval(0.4, 0.9, curve: Curves.easeOutCubic)),
    );

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: const Interval(0.7, 1.0, curve: Curves.easeOut)),
    );

    _buttonSlide = Tween<Offset>(begin: const Offset(0, 0.8), end: Offset.zero).animate(
      CurvedAnimation(parent: _slideController, curve: const Interval(0.7, 1.0, curve: Curves.easeOutCubic)),
    );

    _scaleController.forward();
    _fadeController.forward();
    _slideController.forward();
  }

  void _navigateToNext() {
    if (UserSession.isLoggedIn) {
      context.go('/home');
    } else {
      context.go('/onboarding1');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    _slideController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. Background (Ken Burns) ───────────────────────────────
          AnimatedBuilder(
            animation: _bgScale,
            builder: (context, child) => Transform.scale(
              scale: _bgScale.value,
              alignment: const Alignment(0.0, -0.1),
              child: child,
            ),
            child: Image.asset('assets/images/place_citadel.png', fit: BoxFit.cover),
          ),

          // ── 2. Focal Reveal Blur ────────────────────────────────────
          AnimatedBuilder(
            animation: _blur,
            builder: (context, child) {
              return BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blur.value, sigmaY: _blur.value),
                child: Container(color: Colors.black.withOpacity(0.3)),
              );
            },
          ),

          // ── 3. Atmospheric Gradient ─────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x55000000),
                  Color(0x11000000),
                  Color(0xAA000000),
                  Color(0xEE000000),
                ],
                stops: [0.0, 0.4, 0.7, 1.0],
              ),
            ),
          ),

          // ── 4. Gold Particles ───────────────────────────────────────
          const ParticleOverlay(),

          // ── 5. Main Content ──────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 3),

                // Branding
                FadeTransition(
                  opacity: _logoFade,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(width: 40, height: 1, color: KurdishHeritageColors.zer),
                          const SizedBox(width: 14),
                          const Text(
                            'DISCOVER',
                            style: TextStyle(
                              color: KurdishHeritageColors.zer,
                              fontSize: 10,
                              letterSpacing: 6,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Container(width: 40, height: 1, color: KurdishHeritageColors.zer),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'KURDISTAN',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 10,
                          height: 1.0,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Region of Iraq',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.4),
                          fontSize: 15,
                          letterSpacing: 4,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Tagline
                SlideTransition(
                  position: _taglineSlide,
                  child: FadeTransition(
                    opacity: _taglineFade,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Where ancient mountains meet\nmodern adventure',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xCCFFFFFF),
                          fontSize: 17,
                          height: 1.8,
                          fontStyle: FontStyle.italic,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                // Action Button (Technology Matched)
                SlideTransition(
                  position: _buttonSlide,
                  child: FadeTransition(
                    opacity: _buttonFade,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: _navigateToNext,
                            child: AnimatedBuilder(
                              animation: _shimmerController,
                              builder: (context, child) {
                                return Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: KurdishHeritageColors.zer.withOpacity(0.4 + (_shimmerController.value * 0.6)),
                                      width: 1.5,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                    boxShadow: [
                                      BoxShadow(
                                        color: KurdishHeritageColors.zer.withOpacity(0.1 * _shimmerController.value),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      )
                                    ],
                                  ),
                                  child: Text(
                                    'BEGIN YOUR JOURNEY',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: KurdishHeritageColors.zer,
                                      fontSize: 12,
                                      letterSpacing: 5,
                                      fontWeight: FontWeight.w900,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          offset: const Offset(0, 2),
                                          blurRadius: 4,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Click to enter',
                            style: TextStyle(color: Color(0x66FFFFFF), fontSize: 10, letterSpacing: 3),
                          ),
                          const SizedBox(height: 12),
                          const _ScrollIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 44),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ParticleOverlay extends StatefulWidget {
  const ParticleOverlay({super.key});

  @override
  State<ParticleOverlay> createState() => _ParticleOverlayState();
}

class _ParticleOverlayState extends State<ParticleOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
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
      builder: (_, __) => CustomPaint(
        painter: ParticlePainter(_ctrl.value),
      ),
    );
  }
}

class ParticlePainter extends CustomPainter {
  final double progress;
  ParticlePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(42);
    final paint = Paint()..style = PaintingStyle.fill;

    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.2 + 0.05;
      final radius = rng.nextDouble() * 1.5 + 0.5;
      final baseOpacity = rng.nextDouble() * 0.3 + 0.1;

      final y = (baseY - progress * speed * size.height) % size.height;
      final opacity = baseOpacity * math.sin(progress * math.pi * 2 + i).abs();

      paint.color = KurdishHeritageColors.zer.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) => old.progress != progress;
}

class _ScrollIndicator extends StatefulWidget {
  const _ScrollIndicator();

  @override
  State<_ScrollIndicator> createState() => _ScrollIndicatorState();
}

class _ScrollIndicatorState extends State<_ScrollIndicator> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _anim = Tween<double>(begin: -0.5, end: 0.5).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Container(
        width: 24,
        height: 38,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: Alignment(0, _anim.value),
          child: Container(
            width: 4,
            height: 7,
            decoration: BoxDecoration(
              color: KurdishHeritageColors.zer,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
