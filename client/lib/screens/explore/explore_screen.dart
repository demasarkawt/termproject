// Polished cinematic Explore screen — Visit Kurdistan-inspired mosaic grid.
// Drop into: lib/screens/explore/explore_screen.dart
// Preserves: PlaceRepo data, /place/:id navigation, weather chip, AI search sheet.
 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../../data/place_repo.dart';
import '../../services/theme_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/cinematic.dart';
import 'ai_search_bottom_sheet.dart';
 
class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
 
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}
 
class _ExploreScreenState extends State<ExploreScreen> {
  String? _filter;
  final _scroll = ScrollController();
  Map<String, CityWeather> _weather = {};
 
  static const _filters = <String>[
    'All',
    'History',
    'Nature',
    'Mountains',
    'Waterfalls',
    'Bazaars',
  ];
 
  @override
  void initState() {
    super.initState();
    _loadWeather();
  }
 
  Future<void> _loadWeather() async {
    try {
      final list = await WeatherService.fetchAll();
      if (mounted) setState(() => _weather = {for (final w in list) w.city: w});
    } catch (_) {}
  }
 
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }
 
  List _filteredPlaces() {
    final all = PlaceRepo.all;
    if (_filter == null || _filter == 'All') return all;
    final q = _filter!.toLowerCase();
    return all.where((p) {
      return p.categoryId.toLowerCase().contains(q) ||
          p.title.toLowerCase().contains(q) ||
          p.about.toLowerCase().contains(q);
    }).toList();
  }
 
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
        final places = _filteredPlaces();
 
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: PressScale(
            onTap: () => context.push('/map'),
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: KurdishHeritageColors.zer,
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: KurdishHeritageColors.zer.withOpacity(0.45),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.map_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'VIEW MAP',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
          ),
          body: SafeArea(
            child: CustomScrollView(
              controller: _scroll,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header.
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 80, 24, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            SizedBox(
                                width: 26,
                                height: 1.5,
                                child: ColoredBox(
                                    color: KurdishHeritageColors.zer)),
                            SizedBox(width: 10),
                            Text(
                              'EXPLORE',
                              style: TextStyle(
                                color: KurdishHeritageColors.zer,
                                fontSize: 11,
                                letterSpacing: 5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        RevealText(
                          'Travelo\nDiscovery',
                          style: TextStyle(
                            color: ink,
                            fontSize: 38,
                            height: 1.05,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
 
                // Search bar (glass).
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                    child: PressScale(
                      onTap: () => showAiSearchBottomSheet(context),
                      child: Glass(
                        radius: 20,
                        opacity: isDark ? 0.06 : 0.04,
                        borderOpacity: isDark ? 0.10 : 0.08,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18, vertical: 14),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome_rounded,
                                color: KurdishHeritageColors.zer, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Ask AI: "quiet nature spot"',
                                style: TextStyle(
                                  color: ink.withOpacity(0.55),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Icon(Icons.tune_rounded,
                                color: KurdishHeritageColors.zer, size: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
 
                // Filter chips.
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _filters.length,
                      itemBuilder: (context, i) {
                        final label = _filters[i];
                        final selected =
                            _filter == label || (_filter == null && i == 0);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: PressScale(
                            onTap: () => setState(
                                () => _filter = label == 'All' ? null : label),
                            child: AnimatedContainer(
                              duration: Motion.sm,
                              curve: Motion.arrive,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: selected
                                    ? KurdishHeritageColors.zer
                                    : ink.withOpacity(0.05),
                                border: Border.all(
                                  color: selected
                                      ? KurdishHeritageColors.zer
                                      : ink.withOpacity(0.12),
                                ),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Center(
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    color: selected ? Colors.white : ink,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
 
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
 
                // Mosaic grid (Visit Kurdistan style).
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 140),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final p = places[i];
                        // Alternate "tall" cards for mosaic feel via a gentle
                        // mainAxisExtent variation? SliverGrid is uniform here;
                        // we vary by image crop instead.
                        return _MosaicCard(
                          heroTag: 'place-${p.id}',
                          title: p.title,
                          category: p.categoryId,
                          image: p.coverImage,
                          weather: _weather[p.cityId],
                          onTap: () => context.push('/place/${p.id}'),
                          stagger: i,
                        );
                      },
                      childCount: places.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showAiSearchBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AiSearchBottomSheet(),
    );
  }
}
 
class _MosaicCard extends StatelessWidget {
  final String heroTag;
  final String title;
  final String category;
  final String image;
  final CityWeather? weather;
  final VoidCallback onTap;
  final int stagger;
 
  const _MosaicCard({
    required this.heroTag,
    required this.title,
    required this.category,
    required this.image,
    required this.onTap,
    required this.stagger,
    this.weather,
  });
 
  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      duration: Duration(
          milliseconds:
              Motion.md.inMilliseconds + (40 * (stagger.clamp(0, 8))).toInt()),
      child: PressScale(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Hero(
                tag: heroTag,
                child: Image.asset(image, fit: BoxFit.cover),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                    stops: [0.45, 1],
                  ),
                ),
              ),
              if (weather != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Glass(
                    radius: 999,
                    blur: 14,
                    opacity: 0.18,
                    borderOpacity: 0.22,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(WeatherService.iconFromCode(weather!.weatherCode),
                            color: Colors.white, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${weather!.tempC.toStringAsFixed(0)}°',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.toUpperCase(),
                      style: const TextStyle(
                        color: KurdishHeritageColors.zer,
                        fontSize: 10,
                        letterSpacing: 3,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                      ),
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
}
