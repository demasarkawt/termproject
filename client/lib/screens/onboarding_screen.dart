// Polished cinematic onboarding.
// - Drop into: lib/screens/onboarding_screen.dart
// - Requires: ../widgets/cinematic.dart and the existing theme_service.dart
//
// The hero `tag: 'onb-bg'` allows the active background image to morph into
// the home screen's hero header on "GET STARTED".
 
import 'dart:math' as math;
import 'dart:ui';
 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../services/theme_service.dart';
import '../widgets/cinematic.dart';
 
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
 
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}
 
class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _pc = PageController();
  double _t = 0; // current scroll position (page index space)
  int _index = 0;
 
  late final AnimationController _ambient;
 
  static const _pages = <_Slide>[
    _Slide(
      image: 'assets/images/place_citadel.png',
      kicker: 'CHAPTER ONE',
      title: 'The Cradle of\nHistory',
      subtitle:
          'Erbil Citadel, one of the oldest continuously\ninhabited settlements on Earth.',
    ),
    _Slide(
      image: 'assets/images/hd_mountains.jpg',
      kicker: 'CHAPTER TWO',
      title: 'Mountains\nThat Breathe',
      subtitle:
          'The Zagros range, where ancient legends\nand modern beauty meet at altitude.',
    ),
    _Slide(
      image: 'assets/images/place_bekhal.png',
      kicker: 'CHAPTER THREE',
      title: 'Hidden\nParadises',
      subtitle:
          'Waterfalls, emerald valleys, and quiet villages\nyou won’t find on any postcard.',
    ),
  ];
 
  @override
  void initState() {
    super.initState();
    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _pc.addListener(() {
      final p = _pc.page ?? 0.0;
      setState(() {
        _t = p;
        _index = p.round();
      });
    });
  }
 
  @override
  void dispose() {
    _pc.dispose();
    _ambient.dispose();
    super.dispose();
  }
 
  void _next() {
    if (_index < _pages.length - 1) {
      _pc.nextPage(duration: Motion.lg, curve: Motion.between);
    } else {
      context.go('/signin');
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Cross-fading + slowly drifting backgrounds.
          ..._buildBackgrounds(),
 
          // 2. Vignette to keep text legible.
          _buildVignette(),
 
          // 3. Ambient particles.
          _AmbientParticles(_ambient),
 
          // 4. Page content.
          PageView.builder(
            controller: _pc,
            itemCount: _pages.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (_, i) => _SlideContent(
              slide: _pages[i],
              parallaxT: (_t - i),
            ),
          ),
 
          // 5. Bottom navigation: dots + morphing CTA + skip pill.
          Positioned(left: 24, right: 24, bottom: 36, child: _buildBottomBar()),
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            right: 16,
            child: _buildSkipPill(),
          ),
        ],
      ),
    );
  }
 
  // ---- BG layer ----
  List<Widget> _buildBackgrounds() {
    return List.generate(_pages.length, (i) {
      final dist = (_t - i).abs();
      final opacity = (1 - dist).clamp(0.0, 1.0);
      final scale = 1.04 + 0.06 * (1 - opacity);
      final dx = (_t - i) * -40;
      return IgnorePointer(
        child: Opacity(
          opacity: opacity,
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Transform.scale(
              scale: scale,
              child: Hero(
                tag: i == _index ? 'onb-bg' : 'onb-bg-$i',
                child: Image.asset(
                  _pages[i].image,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
 
  Widget _buildVignette() {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0x55000000),
            Color(0x00000000),
            Color(0xCC000000),
          ],
          stops: [0, 0.45, 1],
        ),
      ),
    );
  }
 
  // ---- Bottom bar ----
  Widget _buildBottomBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _Dots(active: _index, count: _pages.length),
        _buildCta(),
      ],
    );
  }
 
  Widget _buildCta() {
    final last = _index == _pages.length - 1;
    final label = last ? 'GET STARTED' : 'CONTINUE';
    return PressScale(
      onTap: _next,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(
            color: KurdishHeritageColors.zer.withOpacity(0.9),
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: Motion.sm,
              switchInCurve: Motion.arrive,
              switchOutCurve: Motion.arrive,
              child: Text(
                label,
                key: ValueKey(label),
                style: const TextStyle(
                  color: KurdishHeritageColors.zer,
                  fontWeight: FontWeight.w900,
                  fontSize: 11,
                  letterSpacing: 4,
                ),
              ),
            ),
            const SizedBox(height: 4),
            if (last) const ShimmerLine(width: 60, height: 1.2),
          ],
        ),
      ),
    );
  }
 
  Widget _buildSkipPill() {
    return PressScale(
      onTap: () => context.go('/signin'),
      child: Glass(
        radius: 999,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: const Text(
          'Skip',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
          ),
        ),
      ),
    );
  }
}
 
// ─────────── Slide model ───────────
 
class _Slide {
  final String image;
  final String kicker;
  final String title;
  final String subtitle;
  const _Slide({
    required this.image,
    required this.kicker,
    required this.title,
    required this.subtitle,
  });
}
 
// ─────────── Slide content ───────────
 
class _SlideContent extends StatelessWidget {
  final _Slide slide;
  final double parallaxT; // negative when next page, positive when previous
 
  const _SlideContent({required this.slide, required this.parallaxT});
 
  @override
  Widget build(BuildContext context) {
    final clamped = parallaxT.clamp(-1.0, 1.0);
    final opacity = (1 - clamped.abs()).clamp(0.0, 1.0);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 0, 28, 140),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Transform.translate(
              offset: Offset(-clamped * 60, 0),
              child: Opacity(
                opacity: opacity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Container(
                            width: 28,
                            height: 1.5,
                            color: KurdishHeritageColors.zer),
                        const SizedBox(width: 12),
                        Text(
                          slide.kicker,
                          style: const TextStyle(
                            color: KurdishHeritageColors.zer,
                            letterSpacing: 4,
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    RevealText(
                      slide.title.toUpperCase(),
                      duration: Motion.lg,
                      style: const TextStyle(
                        fontSize: 40,
                        height: 1.05,
                        letterSpacing: -1.2,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      slide.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
 
// ─────────── Dots ───────────
 
class _Dots extends StatelessWidget {
  final int active;
  final int count;
  const _Dots({required this.active, required this.count});
 
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: Motion.lg,
          curve: Motion.between,
          margin: const EdgeInsets.only(right: 10),
          width: isActive ? 42 : 10,
          height: 3,
          decoration: BoxDecoration(
            color: isActive
                ? KurdishHeritageColors.zer
                : Colors.white.withOpacity(0.22),
            borderRadius: BorderRadius.circular(2),
          ),
        );
      }),
    );
  }
}
 
// ─────────── Ambient particles ───────────
 
class _AmbientParticles extends StatelessWidget {
  final Animation<double> progress;
  const _AmbientParticles(this.progress);
 
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progress,
      builder: (_, __) =>
          CustomPaint(painter: _AmbientPainter(progress.value), size: Size.infinite),
    );
  }
}
 
class _AmbientPainter extends CustomPainter {
  final double t;
  _AmbientPainter(this.t);
 
  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(11);
    final paint = Paint()..style = PaintingStyle.fill;
    for (int i = 0; i < 22; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.16 + 0.04;
      final radius = rng.nextDouble() * 1.3 + 0.3;
      final baseOpacity = rng.nextDouble() * 0.22 + 0.05;
      final y = (baseY - t * speed * size.height) % size.height;
      paint.color = KurdishHeritageColors.zer
          .withOpacity(baseOpacity * math.sin(t * math.pi * 2 + i).abs());
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }
 
  @override
  bool shouldRepaint(covariant _AmbientPainter old) => old.t != t;
}
