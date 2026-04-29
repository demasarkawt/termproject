import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:termproject/constants/app_branding.dart';
import 'package:termproject/services/user_session.dart';
import '../../services/weather_service.dart';
import '../../services/theme_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;
  Map<String, CityWeather> _weatherMap = {};
  
  final Color accentColor = KurdishHeritageColors.zer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final list = await WeatherService.fetchAll();
      if (mounted) {
        setState(() {
          _weatherMap = {for (final w in list) w.city: w};
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final isDark = ThemeService().isDark;
        final screenH = MediaQuery.of(context).size.height;

        return Scaffold(
          backgroundColor: isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi,
          body: Stack(
            children: [
              // ── 1. Parallax Hero Header (Technology Matched) ────────────────
              Positioned(
                top: -_scrollOffset * 0.45,
                left: 0, right: 0,
                height: screenH * 0.7,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset('assets/images/place_citadel.png', fit: BoxFit.cover),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            const Color(0x66000000),
                            const Color(0x11000000),
                            isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi,
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),
                    // Hero Title Overlay
                    Opacity(
                      opacity: (1.0 - _scrollOffset / 350).clamp(0.0, 1.0),
                      child: Transform.translate(
                        offset: Offset(0, -_scrollOffset * 0.15),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(AppBranding.homeHeroEyebrow, style: TextStyle(color: Color(0xCCD4AF37), fontSize: 13, letterSpacing: 12, fontWeight: FontWeight.w900)),
                            const SizedBox(height: 12),
                            Text(AppBranding.appName, style: const TextStyle(color: Colors.white, fontSize: 54, fontWeight: FontWeight.w900, letterSpacing: 6)),
                            const SizedBox(height: 14),
                            Text('Welcome ${UserSession.userName ?? "traveler"}, plan tours & visits for your next escape', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14, fontStyle: FontStyle.italic, letterSpacing: 1)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Header Bar (Frosted Toggle & Map) ──────────────────────────
              Positioned(
                top: 0, left: 0, right: 0,
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.4), Colors.transparent],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox.shrink(),
                          const SizedBox.shrink(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),


              // ── 2. Scrollable Content ──────────────────────────────────────
              CustomScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // Hero Spacer
                  SliverToBoxAdapter(child: SizedBox(height: screenH * 0.55)),

                  // ── Header Block (Technology Matched) ────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(32, 40, 32, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(width: 28, height: 1.5, color: accentColor),
                            const SizedBox(width: 12),
                            Text('EXPLORE REGIONS', style: TextStyle(color: accentColor, fontSize: 10, letterSpacing: 5, fontWeight: FontWeight.w900)),
                          ]),
                          const SizedBox(height: 14),
                          Text(AppBranding.homeDiscoverTitle, style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontSize: 42, fontWeight: FontWeight.w900, height: 1.1)),
                          const SizedBox(height: 12),
                          Text(AppBranding.homeDiscoverBody, style: TextStyle(color: isDark ? Colors.white54 : KurdishHeritageColors.xweli, fontSize: 14, height: 1.7)),
                        ],
                      ),
                    ),
                  ),

                  // ── 3. Cities Quick Selector ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Row(
                            children: [
                              Container(width: 28, height: 1.5, color: accentColor),
                              const SizedBox(width: 12),
                              Text('REGIONS', style: TextStyle(color: accentColor, fontSize: 10, letterSpacing: 5, fontWeight: FontWeight.w900)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 120,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            physics: const BouncingScrollPhysics(),
                            children: [
                              _buildCityNavCard(context, 'Erbil', 'assets/images/qallat.jpeg'),
                              _buildCityNavCard(context, 'Sulaymaniyah', 'assets/images/place_dukan_lake.jpg'),
                              _buildCityNavCard(context, 'Duhok', 'assets/images/place_amedi.jpg'),
                              _buildCityNavCard(context, 'Halabja', 'assets/images/place_hawraman.jpg'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),

                  // ── Top Destinations Header ──────────────────────────────────
                  SliverToBoxAdapter(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(width: 28, height: 1.5, color: accentColor),
                            const SizedBox(width: 12),
                            Text('MUST VISIT', style: TextStyle(color: accentColor, fontSize: 10, letterSpacing: 5, fontWeight: FontWeight.w900)),
                          ]),
                          const SizedBox(height: 14),
                          Text('Top Picks\nFor You', style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontSize: 42, fontWeight: FontWeight.w900, height: 1.1)),
                        ],
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 20)),



                  // ── Parallax Cards (Technology Matched) ─────────────────────
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(32, 20, 32, 20),
                      child: Row(
                        children: [
                          Container(width: 28, height: 1.5, color: accentColor),
                          const SizedBox(width: 12),
                          Text('FEATURED DESTINATIONS', style: TextStyle(color: accentColor, fontSize: 10, letterSpacing: 5, fontWeight: FontWeight.w900)),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      _buildParallaxCard(
                        context,
                        index: 0,
                        title: 'Erbil Citadel',
                        subtitle: 'UNESCO Heritage Site',
                        desc: 'One of the oldest continuously inhabited settlements on Earth, rising above the city for over 6,000 years.',
                        img: 'assets/images/place_citadel.png',
                        icon: Icons.account_balance,
                        screenH: screenH,
                        city: 'Erbil',
                        onTap: () => context.go('/city/erbil'),
                      ),
                      _buildParallaxCard(
                        context,
                        index: 1,
                        title: 'Suli Bazaar',
                        subtitle: 'Cultural Heartbeat',
                        desc: 'The vibrant soul of Sulaymaniyah, where history and modern commerce blend seamlessly.',
                        img: 'assets/images/place_sulaymaniyah_bazaar.jpg',
                        icon: Icons.storefront_rounded,
                        screenH: screenH,
                        city: 'Sulaymaniyah',
                        onTap: () => context.go('/city/sulaymaniyah'),
                      ),
                      _buildParallaxCard(
                        context,
                        index: 2,
                        title: 'Amedi Citadel',
                        subtitle: 'City in the Clouds',
                        desc: 'An ancient fortress city perched on a mountaintop, overlooking spectacular valleys.',
                        img: 'assets/images/place_amedi.jpg',
                        icon: Icons.fort_rounded,
                        screenH: screenH,
                        city: 'Duhok',
                        onTap: () => context.go('/city/duhok'),
                      ),
                      _buildParallaxCard(
                        context,
                        index: 3,
                        title: 'Hawraman',
                        subtitle: 'Terraced Beauty',
                        desc: 'Unique stone architecture and ancient traditions in the heart of the mountains.',
                        img: 'assets/images/place_hawraman.jpg',
                        icon: Icons.terrain_rounded,
                        screenH: screenH,
                        city: 'Halabja',
                        onTap: () => context.go('/city/halabja'),
                      ),
                    ]),
                  ),



                  // Footer Spacer
                  SliverToBoxAdapter(child: const SizedBox(height: 100)),
                ],
              ),
            ],
          ),
        );
      },
    );

  }

  Widget _buildParallaxCard(BuildContext context, {
    required int index,
    required String title,
    required String subtitle,
    required String desc,
    required String img,
    required IconData icon,
    required double screenH,
    required VoidCallback onTap,
    String? city,
  }) {

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardStart = screenH * 0.55 + (index * 350.0);
    final rel = (_scrollOffset - cardStart + 500).clamp(-500.0, 500.0);
    final parallaxOffset = rel * 0.25;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 350,
        margin: const EdgeInsets.only(bottom: 4),
        child: ClipRect(
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Parallax Image Layer
            Positioned(
              top: parallaxOffset - 60,
              left: 0, right: 0, bottom: -60,
              child: Image.asset(img, fit: BoxFit.cover),
            ),
            
            // Weather Badge
            if (city != null && _weatherMap.containsKey(city))
              Positioned(
                top: 24,
                right: 24,
                child: _buildWeatherBadge(_weatherMap[city]!),
              ),

            // Gradient Overlay (Matching Snippet)

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerRight,
                  end: Alignment.centerLeft,
                  colors: [Colors.transparent, Color(0x88000000), Color(0xDD000000)],
                  stops: [0.0, 0.4, 1.0],
                ),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xCC000000)],
                  stops: [0.4, 1.0],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(icon, color: accentColor, size: 28),
                  const SizedBox(height: 12),
                  Text(subtitle.toUpperCase(), style: TextStyle(color: accentColor, fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Text(title, style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900, height: 1.1)),
                  const SizedBox(height: 8),
                  Text(desc, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 14, height: 1.6)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Text('EXPLORE', style: TextStyle(color: KurdishHeritageColors.zer, fontSize: 11, letterSpacing: 4, fontWeight: FontWeight.w900)),
                      const SizedBox(width: 12),
                      Container(width: 40, height: 1.5, color: accentColor),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildGlassActionBtn(IconData icon, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
        child: Icon(icon, color: isDark ? Colors.white : KurdishHeritageColors.res, size: 22),
      ),
    );
  }

  Widget _buildWeatherBadge(CityWeather w) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(WeatherService.iconFromCode(w.weatherCode), color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                '${w.tempC.toStringAsFixed(1)}°C',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCityNavCard(BuildContext context, String name, String img) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => context.go('/city/${name.toLowerCase()}'),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10, offset: const Offset(0, 5)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 0, sigmaY: 0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Container(width: 20, height: 2, color: KurdishHeritageColors.zer),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}


