// Polished cinematic home screen.
// - Drop into: lib/screens/home/home_screen.dart
// - Requires: ../widgets/cinematic.dart, weather_service.dart, theme_service.dart
// - Same routes preserved: /city/:cityId for taps.
//
// Hero tags:
//   onb-bg            — incoming from onboarding
//   place-citadel     — handed off to /city/erbil
//   place-suli-bazaar — handed off to /city/sulaymaniyah
//   place-amedi       — handed off to /city/duhok
//   place-hawraman    — handed off to /city/halabja
 
import 'dart:ui';
 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../../services/user_session.dart';
import '../../services/weather_service.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
 
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}
 
class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  final _scroll = ScrollController();
  double _offset = 0;
  Map<String, CityWeather> _weather = {};
 
  static const _accent = KurdishHeritageColors.zer;
 
  static const _featured = <_Featured>[
    _Featured(
      heroTag: 'place-citadel',
      title: 'Erbil Citadel',
      subtitle: 'UNESCO Historical Site',
      desc:
          'One of the oldest continuously inhabited settlements on Earth — rising above the city for over 6,000 years.',
      img: 'assets/images/place_citadel_premium.jpg',
      icon: Icons.account_balance_rounded,
      city: 'Erbil',
      route: '/city/erbil',
    ),
    _Featured(
      heroTag: 'place-suli-bazaar',
      title: 'Suli Bazaar',
      subtitle: 'Cultural Heartbeat',
      desc:
          'The vibrant soul of Sulaymaniyah, where history and modern commerce blend seamlessly.',
      img: 'assets/images/place_suli_bazaar_premium.jpg',
      icon: Icons.storefront_rounded,
      city: 'Sulaymaniyah',
      route: '/city/sulaymaniyah',
    ),
    _Featured(
      heroTag: 'place-amedi',
      title: 'Amedi Citadel',
      subtitle: 'City in the Clouds',
      desc:
          'An ancient fortress city perched on a mountaintop, overlooking spectacular valleys.',
      img: 'assets/images/place_amedi_premium.jpg',
      icon: Icons.fort_rounded,
      city: 'Duhok',
      route: '/city/duhok',
    ),
    _Featured(
      heroTag: 'place-hawraman',
      title: 'Hawraman',
      subtitle: 'Terraced Beauty',
      desc:
          'Stone-stepped villages and ancient traditions in the heart of the mountains.',
      img: 'assets/images/place_hawraman_premium.jpg',
      icon: Icons.terrain_rounded,
      city: 'Halabja',
      route: '/city/halabja',
    ),
  ];
 
  static const _cities = <_CityNav>[
    _CityNav('Erbil', 'assets/images/qallat.jpeg'),
    _CityNav('Sulaymaniyah', 'assets/images/place_dukan_lake.jpg'),
    _CityNav('Duhok', 'assets/images/place_amedi.jpg'),
    _CityNav('Halabja', 'assets/images/place_hawraman.jpg'),
  ];
 
  @override
  void initState() {
    super.initState();
    _scroll.addListener(() => setState(() => _offset = _scroll.offset));
    _loadWeather();
  }
 
  Future<void> _loadWeather() async {
    try {
      final list = await WeatherService.fetchAll();
      if (mounted) {
        setState(() => _weather = {for (final w in list) w.city: w});
      }
    } catch (_) {}
  }
 
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }
 
  Future<void> _onRefresh() async {
    await _loadWeather();
  }
 
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final scrH = MediaQuery.of(context).size.height;
        final bg =
            isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              _buildHeroHeader(scrH, bg),
              RefreshIndicator(
                color: _accent,
                onRefresh: _onRefresh,
                child: CustomScrollView(
                  controller: _scroll,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(child: SizedBox(height: scrH * 0.55)),
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        kicker: 'JOURNEY BEYOND',
                        title: 'Travelo\nExplorer',
                        subtitle:
                            'Explore curated regions of ancient beauty and modern wonder.',
                        ink: ink,
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildCityRail()),
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        kicker: 'MUST VISIT',
                        title: 'Top Picks\nFor You',
                        ink: ink,
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 12)),
                    SliverList.builder(
                      itemCount: _featured.length,
                      itemBuilder: (context, i) =>
                          _buildFeaturedCard(_featured[i], i, scrH),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 
  // ─────────── Hero header ───────────
 
  Widget _buildHeroHeader(double scrH, Color bg) {
    final headerH = scrH * 0.7;
    final p30 = parallax(_offset, 0.30);
    final p45 = parallax(_offset, 0.45);
    final p60 = parallax(_offset, 0.60);
 
    final fadeOut = (1 - _offset / 360).clamp(0.0, 1.0);
    final scaleOut = 1 - (1 - 0.92) * (1 - fadeOut);
 
    return Positioned(
      top: -p30,
      left: 0,
      right: 0,
      height: headerH,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background image with hero hand-off from onboarding.
          Hero(
            tag: 'onb-bg',
            child: Image.asset(
              'assets/images/place_citadel.png',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient (mid-speed parallax).
          Transform.translate(
            offset: Offset(0, -p45 * 0.15),
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0x66000000),
                    const Color(0x11000000),
                    bg,
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
          // Title (foreground parallax + fade out).
          Center(
            child: Transform.translate(
              offset: Offset(0, -p60 * 0.18),
              child: Opacity(
                opacity: fadeOut,
                child: Transform.scale(
                  scale: scaleOut,
                  alignment: Alignment.topCenter,
                  child: const _HeroTitleBlock(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
  // ─────────── City rail ───────────
 
  Widget _buildCityRail() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
        physics: const BouncingScrollPhysics(),
        itemCount: _cities.length,
        itemBuilder: (context, i) {
          // Centered tilt: cards on the edges tilt slightly toward center.
          final tilt = (i - (_cities.length - 1) / 2).toDouble() /
              ((_cities.length - 1) / 2);
          final weather = _weather[_cities[i].name];
          return _CityNavCard(item: _cities[i], tilt: tilt, weather: weather);
        },
      ),
    );
  }

  // ─────────── Featured card ───────────

  Widget _buildFeaturedCard(_Featured f, int index, double scrH) {
    final cardStart = scrH * 0.55 + index * 380.0;
    final rel = (_offset - cardStart + 600).clamp(-600.0, 600.0);
    final imgOffset = rel * 0.28; 
    final w = _weather[f.city];

    return ScrollReveal(
      duration: Motion.md,
      offset: 40,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: PressScale(
          onTap: () => context.push(f.route),
          child: Container(
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(32),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image with deeper parallax
                  Positioned.fill(
                    child: Hero(
                      tag: f.heroTag,
                      child: Transform.translate(
                        offset: Offset(0, imgOffset - 40),
                        child: Transform.scale(
                          scale: 1.25,
                          child: Image.asset(
                            f.img, 
                            fit: BoxFit.cover,
                            alignment: const Alignment(0, -0.2), 
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Premium Gradient Overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0x22000000),
                          Colors.transparent,
                          Color(0xCC000000),
                        ],
                        stops: [0, 0.4, 1],
                      ),
                    ),
                  ),

                  // Integrated Weather inside card (Top Right)
                  if (w != null)
                    Positioned(
                      top: 20,
                      right: 20,
                      child: _WeatherChip(w: w),
                    ),

                  // Category Badge (Top Left)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: Glass(
                      radius: 999,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      opacity: 0.1,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(f.icon, color: _accent, size: 14),
                          const SizedBox(width: 8),
                          Text(
                            f.city.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Content Area
                  Positioned(
                    left: 28,
                    right: 28,
                    bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const ShimmerLine(width: 40, height: 2),
                        const SizedBox(height: 16),
                        Text(
                          f.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            height: 1.1,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          f.desc,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                            height: 1.6,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Text(
                              'EXPLORE JOURNEY',
                              style: TextStyle(
                                color: _accent,
                                fontSize: 11,
                                letterSpacing: 3,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              width: 40,
                              height: 1.5,
                              color: _accent.withOpacity(0.8),
                            ),
                          ],
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
 
// ─────────── Hero title block ───────────
 
class _HeroTitleBlock extends StatelessWidget {
  const _HeroTitleBlock();
 
  @override
  Widget build(BuildContext context) {
    final name = UserSession.userName ?? 'Traveler';
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Premium Glass Badge for Welcome
        Glass(
          radius: 999,
          opacity: 0.1,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.stars_rounded, color: KurdishHeritageColors.zer, size: 14),
              const SizedBox(width: 8),
              Text(
                'WELCOME BACK, ${name.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        const Text(
          'T R A V E L O',
          style: TextStyle(
            color: KurdishHeritageColors.zer,
            fontSize: 14,
            letterSpacing: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        const RevealText(
          'ADVENTURE',
          duration: Motion.lg,
          style: TextStyle(
            color: Colors.white,
            fontSize: 64,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            height: 1,
          ),
        ),
        const SizedBox(height: 16),
        const ShimmerLine(width: 60, height: 2.5),
      ],
    );
  }
}
 
// ─────────── Section header ───────────
 
class _SectionHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final String? subtitle;
  final Color ink;
 
  const _SectionHeader({
    required this.kicker,
    required this.title,
    required this.ink,
    this.subtitle,
  });
 
  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28, 36, 28, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ShimmerLine(width: 30, height: 1.5),
                const SizedBox(width: 12),
                Text(
                  kicker,
                  style: const TextStyle(
                    color: KurdishHeritageColors.zer,
                    fontSize: 10,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            RevealText(
              title,
              style: TextStyle(
                color: ink,
                fontSize: 38,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 10),
              Text(
                subtitle!,
                style: TextStyle(
                  color: ink.withOpacity(0.6),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
 
// ─────────── City nav card ───────────
 
class _CityNav {
  final String name;
  final String img;
  const _CityNav(this.name, this.img);
}
 
class _CityNavCard extends StatelessWidget {
  final _CityNav item;
  final double tilt;
  final CityWeather? weather;

  const _CityNavCard({
    required this.item,
    required this.tilt,
    this.weather,
  });
 
  @override
  Widget build(BuildContext context) {
    return PressScale(
      onTap: () => context.push('/city/${item.name.toLowerCase()}'),
      child: Tilt3D(
        t: tilt,
        child: Container(
          width: 150,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            image: DecorationImage(
              image: AssetImage(item.img),
              fit: BoxFit.cover,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Stack(
              fit: StackFit.expand,
              children: [
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [Color(0xCC000000), Colors.transparent],
                    ),
                  ),
                ),
                // Weather Overlay (Top Right)
                if (weather != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Glass(
                      radius: 8,
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      opacity: 0.15,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            WeatherService.iconFromCode(weather!.weatherCode),
                            color: Colors.white,
                            size: 10,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '${weather!.tempC.toStringAsFixed(0)}°',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const ShimmerLine(width: 20, height: 1.2),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
 
// ─────────── Weather chip (glass) ───────────
 
class _WeatherChip extends StatelessWidget {
  final CityWeather w;
  const _WeatherChip({required this.w});
 
  @override
  Widget build(BuildContext context) {
    return Glass(
      radius: 14,
      blur: 14,
      opacity: 0.18,
      borderOpacity: 0.20,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            WeatherService.iconFromCode(w.weatherCode),
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            '${w.tempC.toStringAsFixed(1)}°C',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w900,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
 
// ─────────── Featured model ───────────
 
class _Featured {
  final String heroTag;
  final String title;
  final String subtitle;
  final String desc;
  final String img;
  final IconData icon;
  final String city;
  final String route;
  const _Featured({
    required this.heroTag,
    required this.title,
    required this.subtitle,
    required this.desc,
    required this.img,
    required this.icon,
    required this.city,
    required this.route,
  });
}
