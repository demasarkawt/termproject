import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:termproject/services/user_session.dart';

import '../../models/map_spot_memory.dart';
import '../../services/map_spot_memory_store.dart';
import '../../services/theme_service.dart';
import '../../theme/trip_planner_theme.dart';
import '../../widgets/immersive_city_card.dart';
import '../../services/weather_service.dart';

/// Regions strip — immersive city cards (photo + overlay + fonts).
const List<ImmersiveCityCardData> _kHomeCityCards = [
  ImmersiveCityCardData(
    cityName: 'Erbil',
    cityRouteId: 'erbil',
    priceDisplay: r'$299',
    shortDescription:
        'Citadel ridges, silk bazaars, and rooftop dinners—classic long-weekend vibes.',
    tags: ['Luxury Stay', '5 Day Trip', 'Top Rated'],
    ctaLabel: 'View City',
    imageAssetPath: 'assets/images/qallat.jpeg',
    activeDotIndex: 0,
  ),
  ImmersiveCityCardData(
    cityName: 'Sulaymaniyah',
    cityRouteId: 'sulaymaniyah',
    priceDisplay: r'$249',
    shortDescription:
        'Museums, mountain air, and café culture tucked into hillside streets.',
    tags: ['Weekend', 'Arts', 'Coffee'],
    ctaLabel: 'Explore',
    imageAssetPath: 'assets/images/place_dukan_lake.jpg',
    activeDotIndex: 1,
  ),
  ImmersiveCityCardData(
    cityName: 'Duhok',
    cityRouteId: 'duhok',
    priceDisplay: r'$189',
    shortDescription:
        'Resort lakes, canyons, and citadel walks without the big-city rush.',
    tags: ['Nature', 'Family', 'Scenic'],
    ctaLabel: 'View City',
    imageAssetPath: 'assets/images/place_amedi.jpg',
    activeDotIndex: 2,
  ),
  ImmersiveCityCardData(
    cityName: 'Halabja',
    cityRouteId: 'halabja',
    priceDisplay: r'$159',
    shortDescription:
        'Green highland trails, stone villages, and quiet pace for slow travel.',
    tags: ['Hiking', 'Weekend', 'Calm'],
    ctaLabel: 'View Details',
    imageAssetPath: 'assets/images/place_hawraman.jpg',
    activeDotIndex: 0,
  ),
];

class _HomeFeaturedSpot {
  const _HomeFeaturedSpot({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageAsset,
    required this.routeLocation,
    this.weatherCity,
  });

  final String title;
  final String subtitle;
  final String description;
  final String imageAsset;
  final String routeLocation;
  final String? weatherCity;
}

double _deterministicRating(String seed) {
  var h = 0;
  for (final u in seed.codeUnits) {
    h = (h * 31 + u) & 0x7fffffff;
  }
  return 4.0 + (h % 10) / 10;
}

const List<_HomeFeaturedSpot> _kFeaturedSpots = [
  _HomeFeaturedSpot(
    title: 'Erbil Citadel',
    subtitle: 'UNESCO Heritage Site',
    description:
        'One of the oldest continuously inhabited settlements on Earth, rising above the city for over 6,000 years.',
    imageAsset: 'assets/images/place_citadel.png',
    routeLocation: '/city/erbil',
    weatherCity: 'Erbil',
  ),
  _HomeFeaturedSpot(
    title: 'Suli Bazaar',
    subtitle: 'Cultural Heartbeat',
    description:
        'The vibrant soul of Sulaymaniyah, where history and modern commerce blend seamlessly.',
    imageAsset: 'assets/images/place_sulaymaniyah_bazaar.jpg',
    routeLocation: '/city/sulaymaniyah',
    weatherCity: 'Sulaymaniyah',
  ),
  _HomeFeaturedSpot(
    title: 'Amedi Citadel',
    subtitle: 'City in the Clouds',
    description:
        'An ancient fortress city perched on a mountaintop, overlooking spectacular valleys.',
    imageAsset: 'assets/images/place_amedi.jpg',
    routeLocation: '/city/duhok',
    weatherCity: 'Duhok',
  ),
  _HomeFeaturedSpot(
    title: 'Hawraman',
    subtitle: 'Terraced Beauty',
    description:
        'Unique stone architecture and ancient traditions in the heart of the mountains.',
    imageAsset: 'assets/images/place_hawraman.jpg',
    routeLocation: '/city/halabja',
    weatherCity: 'Halabja',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final PageController _featuredPageController = PageController(viewportFraction: 0.9);
  Map<String, CityWeather> _weatherMap = {};
  int _featuredIndex = 0;
  Timer? _featuredAutoTimer;
  late final List<ImmersiveCityCardData> _otherPlacesShuffle;

  final Color accentColor = KurdishHeritageColors.zer;

  @override
  void initState() {
    super.initState();
    _otherPlacesShuffle =
        List<ImmersiveCityCardData>.from(_kHomeCityCards)..shuffle(Random());
    _loadWeather();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _scheduleFeaturedAutoplay();
    });
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

  void _scheduleFeaturedAutoplay() {
    _featuredAutoTimer?.cancel();
    _featuredAutoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_featuredPageController.hasClients) return;
      final next = (_featuredIndex + 1) % _kFeaturedSpots.length;
      _featuredPageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 520),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _featuredAutoTimer?.cancel();
    _featuredPageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final isDark = ThemeService().isDark;
        final topInset = MediaQuery.paddingOf(context).top;
        final canvas = isDark ? const Color(0xFF161412) : TripPlannerTheme.canvasLight;
        final headline = isDark ? Colors.white : TripPlannerTheme.headlineBrown;
        final muted =
            isDark ? Colors.white.withValues(alpha: 0.62) : TripPlannerTheme.bodyMuted;
        final dotActive = isDark ? KurdishHeritageColors.zer : TripPlannerTheme.brownPrimary;

        return ValueListenableBuilder<int>(
          valueListenable: MapSpotMemoryStore.revision,
          builder: (context, _, __) {
            final memories = MapSpotMemoryStore.items;
            final sortedMemories = List<MapSpotMemory>.from(memories)
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

            return Scaffold(
          backgroundColor: canvas,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topInset + 56)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${UserSession.userName ?? 'traveler'}',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: muted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        memories.isEmpty
                            ? 'Explore cities, open the map, and pin photo memories of spots you love.'
                            : 'You have ${memories.length} map ${memories.length == 1 ? 'memory' : 'memories'} saved on this device.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                          color: muted.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Material(
                        color: isDark ? const Color(0xFF2C2C2E) : TripPlannerTheme.cardLight,
                        elevation: isDark ? 0 : 1,
                        shadowColor: Colors.black.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(999),
                        child: InkWell(
                          onTap: () => context.go('/explore'),
                          borderRadius: BorderRadius.circular(999),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
                            child: Row(
                              children: [
                                Icon(Icons.search_rounded, color: muted, size: 22),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Where to next?',
                                    style: GoogleFonts.inter(
                                      fontSize: 15,
                                      fontStyle: FontStyle.italic,
                                      color: muted,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 22),
                      _HomeQuickActions(
                        isDark: isDark,
                        titleColor: headline,
                        onOpenMap: () => context.go('/map'),
                        onOpenSaved: () => context.go('/favorites'),
                        onOpenExplore: () => context.go('/explore'),
                        onOpenEvents: () => context.go('/events'),
                      ),
                      const SizedBox(height: 22),
                      _HomeMemoriesPeek(
                        memories: sortedMemories,
                        isDark: isDark,
                        titleColor: headline,
                        muted: muted,
                        onOpenMap: () => context.go('/map'),
                        onOpenMemory: (id) => context.push('/map-memory/$id'),
                      ),
                      const SizedBox(height: 26),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'New for you',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.35,
                              color: headline,
                            ),
                          ),
                          Text(
                            '${_kFeaturedSpots.length} picks',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: muted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Handpicked places with itineraries you can follow.',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          height: 1.35,
                          color: muted.withValues(alpha: 0.95),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: SizedBox(
                    height: 300,
                    child: PageView.builder(
                      controller: _featuredPageController,
                      onPageChanged: (i) {
                        setState(() => _featuredIndex = i);
                        _scheduleFeaturedAutoplay();
                      },
                      itemCount: _kFeaturedSpots.length,
                      padEnds: true,
                      itemBuilder: (context, index) {
                        final spot = _kFeaturedSpots[index];
                        final weather = spot.weatherCity != null
                            ? _weatherMap[spot.weatherCity!]
                            : null;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: _FeaturedCarouselCard(
                            spot: spot,
                            weather: weather,
                            accentColor: accentColor,
                            plannerStyle: true,
                            onTap: () => context.go(spot.routeLocation),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 8),
                    child: SmoothPageIndicator(
                      controller: _featuredPageController,
                      count: _kFeaturedSpots.length,
                      effect: ExpandingDotsEffect(
                        dotHeight: 7,
                        dotWidth: 7,
                        spacing: 6,
                        expansionFactor: 3,
                        activeDotColor: dotActive,
                        dotColor: isDark ? Colors.white.withValues(alpha: 0.22) : Colors.black.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Popular destinations',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.35,
                                color: headline,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.go('/explore'),
                            style: TextButton.styleFrom(
                              foregroundColor: TripPlannerTheme.brownPrimary,
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(0, 36),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View all',
                                  style:
                                      GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(width: 2),
                                const Icon(Icons.chevron_right_rounded, size: 18),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    ImmersiveCityCardStage(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      children: [
                        for (final data in _kHomeCityCards)
                          ImmersiveCityCard(
                            layout: ImmersiveCityCardLayout.compact,
                            data: data,
                            onTap: () => context.go(
                              '/city/${data.cityRouteId ?? data.cityName.toLowerCase()}',
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'More places to explore',
                            style: GoogleFonts.inter(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.35,
                              color: headline,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Extra spots in a fresh order—swipe the row.',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              height: 1.35,
                              color: muted.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ImmersiveCityCardStage(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                      children: [
                        for (final data in _otherPlacesShuffle)
                          ImmersiveCityCard(
                            layout: ImmersiveCityCardLayout.compact,
                            data: data,
                            onTap: () => context.go(
                              '/city/${data.cityRouteId ?? data.cityName.toLowerCase()}',
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        );
          },
        );
      },
    );
  }
}

/// Two-by-two shortcuts: map, journeys, saves, agenda.
class _HomeQuickActions extends StatelessWidget {
  const _HomeQuickActions({
    required this.isDark,
    required this.titleColor,
    required this.onOpenMap,
    required this.onOpenSaved,
    required this.onOpenExplore,
    required this.onOpenEvents,
  });

  final bool isDark;
  final Color titleColor;
  final VoidCallback onOpenMap;
  final VoidCallback onOpenSaved;
  final VoidCallback onOpenExplore;
  final VoidCallback onOpenEvents;

  @override
  Widget build(BuildContext context) {
    final card = isDark ? const Color(0xFF2C2C2E) : TripPlannerTheme.cardLight;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Get started',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.15,
            color: titleColor.withValues(alpha: 0.88),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DashQuickTile(
                icon: Icons.map_rounded,
                label: 'Map',
                subtitle: 'Pins & GPS',
                isDark: isDark,
                cardColor: card,
                accent: KurdishHeritageColors.zer,
                onTap: onOpenMap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DashQuickTile(
                icon: Icons.travel_explore_rounded,
                label: 'Explore',
                subtitle: 'Tours',
                isDark: isDark,
                cardColor: card,
                accent: TripPlannerTheme.brownPrimary,
                onTap: onOpenExplore,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _DashQuickTile(
                icon: Icons.favorite_rounded,
                label: 'Saved',
                subtitle: 'Favorites',
                isDark: isDark,
                cardColor: card,
                accent: KurdishHeritageColors.sor,
                onTap: onOpenSaved,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _DashQuickTile(
                icon: Icons.event_rounded,
                label: 'Events',
                subtitle: 'What’s on',
                isDark: isDark,
                cardColor: card,
                accent: KurdishHeritageColors.kesk,
                onTap: onOpenEvents,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DashQuickTile extends StatelessWidget {
  const _DashQuickTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isDark,
    required this.cardColor,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final bool isDark;
  final Color cardColor;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = isDark ? Colors.white : TripPlannerTheme.headlineBrown;
    final sub = isDark ? Colors.white54 : TripPlannerTheme.bodyMuted;

    return Material(
      color: cardColor,
      elevation: isDark ? 0 : 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 22),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color: text,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: sub,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Recent photo memories or a single CTA when empty.
class _HomeMemoriesPeek extends StatelessWidget {
  const _HomeMemoriesPeek({
    required this.memories,
    required this.isDark,
    required this.titleColor,
    required this.muted,
    required this.onOpenMap,
    required this.onOpenMemory,
  });

  final List<MapSpotMemory> memories;
  final bool isDark;
  final Color titleColor;
  final Color muted;
  final VoidCallback onOpenMap;
  final void Function(String memoryId) onOpenMemory;

  @override
  Widget build(BuildContext context) {
    if (memories.isEmpty) {
      return Material(
        color: KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.11 : 0.13),
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onOpenMap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: KurdishHeritageColors.zer.withValues(alpha: 0.22),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.add_a_photo_rounded, color: KurdishHeritageColors.zer, size: 24),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Photo memories on the map',
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: titleColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Open the map, line up the + on your spot, then tap Memory.',
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: muted.withValues(alpha: 0.95),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: muted.withValues(alpha: 0.8)),
              ],
            ),
          ),
        ),
      );
    }

    final preview = memories.take(10).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                'Your map memories',
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.35,
                  color: titleColor,
                ),
              ),
            ),
            TextButton(
              onPressed: onOpenMap,
              style: TextButton.styleFrom(
                foregroundColor: KurdishHeritageColors.zer,
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Open map',
                style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 124,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: preview.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final m = preview[i];
              return _HomeMemoryCard(
                memory: m,
                isDark: isDark,
                onTap: () => onOpenMemory(m.id),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HomeMemoryCard extends StatelessWidget {
  const _HomeMemoryCard({
    required this.memory,
    required this.isDark,
    required this.onTap,
  });

  final MapSpotMemory memory;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);

    return Material(
      color: isDark ? const Color(0xFF2C2C2E) : TripPlannerTheme.cardLight,
      elevation: isDark ? 0 : 0.45,
      shadowColor: Colors.black.withValues(alpha: 0.07),
      borderRadius: radius,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: SizedBox(
          width: 150,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                  child: _thumb(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                child: Text(
                  memory.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.25,
                    color: isDark ? Colors.white : TripPlannerTheme.headlineBrown,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb() {
    if (!kIsWeb && memory.imagePaths.isNotEmpty) {
      final f = File(memory.imagePaths.first);
      if (f.existsSync()) {
        return Image.file(
          f,
          fit: BoxFit.cover,
          width: double.infinity,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: KurdishHeritageColors.zer.withValues(alpha: 0.18),
            child: const Center(
              child: Icon(Icons.photo_rounded, color: KurdishHeritageColors.zer, size: 32),
            ),
          ),
        );
      }
    }
    return ColoredBox(
      color: KurdishHeritageColors.zer.withValues(alpha: 0.18),
      child: const Center(
        child: Icon(Icons.photo_camera_rounded, color: KurdishHeritageColors.zer, size: 28),
      ),
    );
  }
}

class _FeaturedCarouselCard extends StatelessWidget {
  const _FeaturedCarouselCard({
    required this.spot,
    required this.accentColor,
    required this.onTap,
    this.weather,
    this.plannerStyle = false,
  });

  final _HomeFeaturedSpot spot;
  final Color accentColor;
  final VoidCallback onTap;
  final CityWeather? weather;
  final bool plannerStyle;

  static const BorderRadius _kOrganic = BorderRadius.only(
    topLeft: Radius.circular(40),
    topRight: Radius.circular(12),
    bottomLeft: Radius.circular(18),
    bottomRight: Radius.circular(46),
  );

  BorderRadius get _radius => plannerStyle ? BorderRadius.circular(28) : _kOrganic;

  @override
  Widget build(BuildContext context) {
    final outerShape = RoundedRectangleBorder(borderRadius: _radius);
    final rating = _deterministicRating(spot.title);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: outerShape,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: _radius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.24),
                blurRadius: 30,
                offset: const Offset(0, 18),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: _radius,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(spot.imageAsset, fit: BoxFit.cover),
                if (!plannerStyle)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    top: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: SweepGradient(
                          center: const Alignment(0.75, -0.4),
                          startAngle: 0.85,
                          endAngle: 3.35,
                          colors: [
                            const Color(0x00000000),
                            const Color(0x55000000),
                            const Color(0xBB0a0f1e),
                          ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  height: 200,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          const Color(0xEE0a0f1e),
                          const Color(0x660a0f1e),
                          const Color(0x000a0f1e),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),
                if (plannerStyle)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'New for you',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (plannerStyle)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.92),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, size: 16, color: TripPlannerTheme.starRating),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: GoogleFonts.inter(
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                              color: TripPlannerTheme.headlineBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!plannerStyle && weather != null)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: _FeaturedWeatherBadge(weather: weather!),
                  ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 22,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        spot.subtitle.toUpperCase(),
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          letterSpacing: 3,
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        spot.title,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          height: 1.15,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        spot.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          height: 1.45,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withValues(alpha: 0.85),
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
    );
  }
}

class _FeaturedWeatherBadge extends StatelessWidget {
  const _FeaturedWeatherBadge({required this.weather});

  final CityWeather weather;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(WeatherService.iconFromCode(weather.weatherCode), color: Colors.white, size: 16),
              const SizedBox(width: 8),
              Text(
                '${weather.tempC.toStringAsFixed(1)}°C',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
