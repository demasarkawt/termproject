import 'dart:ui';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/theme_service.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  double _scrollOffset = 0.0;
  int _currentIndex = 0;

  late AnimationController _bgCtrl;
  late AnimationController _envCtrl;
  late AnimationController _particleCtrl;
  late AnimationController _textCtrl;

  final List<Map<String, String>> _pages = [
    {
      'image': 'assets/images/place_citadel.png',
      'title': 'The Cradle of History',
      'subtitle': 'Explore the Erbil Citadel, one of the oldest continuously inhabited settlements on Earth.',
      'type': 'city',
    },
    {
      'image': 'assets/images/hd_mountains.jpg',
      'title': 'Breathtaking Peaks',
      'subtitle': 'Witness the majesty of the Zagros mountains, where ancient history meets modern beauty.',
      'type': 'nature_clouds',
    },
    {
      'image': 'assets/images/place_bekhal.png',
      'title': 'Hidden Paradises',
      'subtitle': 'Discover the stunning waterfalls and lush emerald valleys hidden within our land.',
      'type': 'nature_waterfall',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 30))..repeat();
    _envCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat();
    _particleCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat();
    _textCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _pageController.addListener(() {
      setState(() {
        _scrollOffset = _pageController.page ?? 0.0;
        _currentIndex = _scrollOffset.round();
      });
    });

    _textCtrl.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _bgCtrl.dispose();
    _envCtrl.dispose();
    _particleCtrl.dispose();
    _textCtrl.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(duration: const Duration(milliseconds: 800), curve: Curves.easeInOutCubic);
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
          // ── 1. Parallax Background System ────────────────────────────
          // We use the scroll offset to cross-fade between background images
          ..._buildParallaxBackgrounds(),

          // ── 2. Cinematic Environmental Effects ────────────────────────
          _buildEnvironmentalLayers(),

          // ── 3. Gold Particle Overlay ──────────────────────────────────
          AnimatedBuilder(
            animation: _particleCtrl,
            builder: (_, __) => CustomPaint(
              painter: ParticlePainter(_particleCtrl.value),
            ),
          ),

          // ── 4. Depth Overlays ──────────────────────────────────────────
          _buildOverlays(),

          // ── 5. PageView for Scrolling/Swiping ─────────────────────────
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return _buildContentPage(_pages[index], index);
            },
          ),

          // ── 6. Fixed Bottom Navigation ────────────────────────────────
          _buildBottomNav(),
        ],
      ),
    );
  }

  List<Widget> _buildParallaxBackgrounds() {
    return List.generate(_pages.length, (index) {
      // Calculate opacity based on scroll position for smooth cross-fade
      double opacity = 0.0;
      if (index == _currentIndex) {
        opacity = 1.0 - (_scrollOffset - index).abs();
      } else if (index == _currentIndex + 1 || index == _currentIndex - 1) {
        opacity = (_scrollOffset - index).abs().clamp(0.0, 1.0);
        opacity = 1.0 - opacity;
      }

      return Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: AnimatedBuilder(
          animation: _bgCtrl,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.0 + (_bgCtrl.value * 0.12),
              child: Image.asset(_pages[index]['image']!, fit: BoxFit.cover, width: double.infinity, height: double.infinity),
            );
          },
        ),
      );
    });
  }

  Widget _buildEnvironmentalLayers() {
    final page = _pages[_currentIndex];
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: page['type'] == 'nature_clouds' 
        ? _buildMovingClouds() 
        : page['type'] == 'nature_waterfall' 
          ? _buildMovingWaterfall() 
          : const SizedBox.shrink(),
    );
  }

  Widget _buildMovingClouds() {
    return AnimatedBuilder(
      animation: _envCtrl,
      builder: (context, child) {
        return Stack(
          children: List.generate(4, (i) {
            final drift = (_envCtrl.value + (i * 0.25)) % 1.0;
            return Positioned(
              top: 40.0 + (i * 50),
              left: (MediaQuery.of(context).size.width * 1.4 * drift) - 200,
              child: Opacity(
                opacity: 0.12,
                child: Container(
                  width: 400,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(color: Colors.white, blurRadius: 100, spreadRadius: 50)
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildMovingWaterfall() {
    return AnimatedBuilder(
      animation: _envCtrl,
      builder: (context, child) {
        return CustomPaint(
          painter: WaterfallPainter(progress: _envCtrl.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildOverlays() {
    return Positioned.fill(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.3),
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
            stops: const [0.0, 0.45, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildContentPage(Map<String, String> page, int index) {
    // Parallax effect for text
    final relativeScroll = (_scrollOffset - index);
    
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Spacer(),
            Transform.translate(
              offset: Offset(-relativeScroll * 50, 0),
              child: Opacity(
                opacity: (1 - relativeScroll.abs()).clamp(0.0, 1.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 30, height: 1.5, color: KurdishHeritageColors.zer),
                        const SizedBox(width: 12),
                        const Text(
                          'DISCOVER KURDISTAN',
                          style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      page['title']!.toUpperCase(),
                      style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w900, color: Colors.white, height: 1.05, letterSpacing: -1),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      page['subtitle']!,
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.6), height: 1.6, fontWeight: FontWeight.w500, fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 160), // Room for bottom nav
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    return Positioned(
      bottom: 60,
      left: 40,
      right: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildDots(),
          _buildNextBtn(),
        ],
      ),
    );
  }

  Widget _buildGlassBtn(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10, letterSpacing: 3)),
          ),
        ),
      ),
    );
  }

  Widget _buildDots() {
    return Row(
      children: List.generate(_pages.length, (i) {
        final active = i == _currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          margin: const EdgeInsets.only(right: 12),
          width: active ? 45 : 12,
          height: 3,
          decoration: BoxDecoration(
            color: active ? KurdishHeritageColors.zer : Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }

  Widget _buildNextBtn() {
    return GestureDetector(
      onTap: _nextPage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(color: KurdishHeritageColors.zer, width: 1.5),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Text(
          _currentIndex == _pages.length - 1 ? 'GET STARTED' : 'CONTINUE',
          style: const TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 4),
        ),
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

    for (int i = 0; i < 25; i++) {
      final x = rng.nextDouble() * size.width;
      final baseY = rng.nextDouble() * size.height;
      final speed = rng.nextDouble() * 0.2 + 0.05;
      final radius = rng.nextDouble() * 1.5 + 0.5;
      final baseOpacity = rng.nextDouble() * 0.25 + 0.08;

      final y = (baseY - progress * speed * size.height) % size.height;
      final opacity = baseOpacity * math.sin(progress * math.pi * 2 + i).abs();

      paint.color = KurdishHeritageColors.zer.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant ParticlePainter old) => old.progress != progress;
}

class WaterfallPainter extends CustomPainter {
  final double progress;
  WaterfallPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.25)
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round;

    final random = math.Random(42);
    final waterfallX = size.width * 0.62;
    final waterfallW = size.width * 0.15;
    final waterfallT = size.height * 0.25;
    final waterfallB = size.height * 0.75;

    for (int i = 0; i < 35; i++) {
      final x = waterfallX + random.nextDouble() * waterfallW;
      final yStart = waterfallT + ((progress + random.nextDouble()) % 1.0) * (waterfallB - waterfallT);
      final len = 15.0 + random.nextDouble() * 35.0;
      canvas.drawLine(Offset(x, yStart), Offset(x, yStart + len), paint);
    }
  }

  @override
  bool shouldRepaint(WaterfallPainter oldDelegate) => true;
}
