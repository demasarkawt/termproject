import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:termproject/constants/app_branding.dart';
import 'ai_search_bottom_sheet.dart';
import '../../services/theme_service.dart';
import '../../services/weather_service.dart';
import '../../data/place_repo.dart';


class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedFilter;
  final ScrollController _scrollCtrl = ScrollController();
  double _scrollOffset = 0.0;
  Map<String, CityWeather> _weatherMap = {};

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(() {
      setState(() {
        _scrollOffset = _scrollCtrl.offset;
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
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final isDark = ThemeService().isDark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.go('/map'),
            backgroundColor: KurdishHeritageColors.zer,
            icon: const Icon(Icons.map_rounded, color: Colors.white),
            label: const Text('VIEW MAP', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ),
          body: Stack(


        children: [
          // ── Background Glows ──────────────────────────────────────────
          _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.05), -100, 100, 400),
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.05), 300, 400, 300),

          SafeArea(
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Top Header ────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: KurdishHeritageColors.zer.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: KurdishHeritageColors.zer.withValues(alpha: 0.28)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.directions_walk_rounded, size: 15, color: KurdishHeritageColors.zer.withValues(alpha: 0.95)),
                              const SizedBox(width: 8),
                              const Text(
                                'EXPLORE',
                                style: TextStyle(
                                  color: KurdishHeritageColors.zer,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          AppBranding.exploreHeroLine1,
                          style: TextStyle(
                            color: isDark ? Colors.white : KurdishHeritageColors.res,
                            fontWeight: FontWeight.w900,
                            fontSize: 36,
                            height: 1.05,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          AppBranding.exploreHeroLine2,
                          style: TextStyle(
                            color: isDark ? Colors.white.withValues(alpha: 0.92) : KurdishHeritageColors.res.withValues(alpha: 0.88),
                            fontWeight: FontWeight.w800,
                            fontSize: 22,
                            height: 1.15,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          AppBranding.exploreHeroSupporting,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white.withValues(alpha: 0.52) : KurdishHeritageColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Search & Map Integration ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    child: _buildGlassSearch(context, isDark),
                  ),
                ),

                // ── Filter Chips ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    child: Row(
                      children: [
                        _buildFilterBtn(isDark),
                        const SizedBox(width: 12),
                        _buildFilterChip('Erbil', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('Sulaymaniyah', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('Duhok', isDark),
                        const SizedBox(width: 8),
                        _buildFilterChip('Halabja', isDark),
                      ],
                    ),
                  ),
                ),

                // ── Places Grid (Dynamic) ──────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
                  sliver: Builder(
                    builder: (context) {
                      final filtered = PlaceRepo.all.where((p) {
                        if (_selectedFilter == null) return true;
                        return p.cityId.toLowerCase() == _selectedFilter!.toLowerCase() ||
                               p.locationText.toLowerCase().contains(_selectedFilter!.toLowerCase());
                      }).toList();

                      if (filtered.isEmpty) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text('No places found in this region.', style: TextStyle(color: Colors.grey)),
                          ),
                        );
                      }

                      return SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final p = filtered[index];
                            return _buildCategoryPlaceCard(
                              title: p.title,
                              city: p.locationText,
                              image: p.coverImage,
                              categoryId: p.categoryId,
                              onTap: () => context.go('/place/${p.id}'),
                            );
                          },
                          childCount: filtered.length,
                        ),
                      );
                    },
                  ),
                ),


              ],
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  Widget _buildGlowBlob(Color color, double left, double top, double size) {

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  Widget _buildGlassCircleBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
        child: Icon(icon, color: KurdishHeritageColors.zer, size: 22),
      ),
    );
  }

  Widget _buildGlassSearch(BuildContext context, bool isDark) {
    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const AiSearchBottomSheet(),
      ),
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Icon(Icons.search_rounded, color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Search heritage, nature, cities...',
                style: TextStyle(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: KurdishHeritageColors.zer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBtn(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: KurdishHeritageColors.sor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KurdishHeritageColors.sor.withOpacity(0.3)),
      ),
      child: const Row(
        children: [
          Icon(Icons.tune_rounded, size: 16, color: KurdishHeritageColors.sor),
          SizedBox(width: 6),
          Text('Filters', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: KurdishHeritageColors.sor)),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isDark) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = isSelected ? null : label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? KurdishHeritageColors.kesk : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? Colors.white.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
            color: isSelected ? Colors.white : (isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryPlaceCard({
    required String title,
    required String city,
    required String image,
    required VoidCallback onTap,
    required String categoryId,
  }) {
    // Extract the base city name (e.g., "Erbil" from "Erbil, Kurdistan")
    final cityName = city.split(',').first.trim();
    final weather = _weatherMap[cityName];
    
    // Fallback image based on category if specific one fails
    final fallbackImage = _getFallbackForCategory(categoryId);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: KurdishHeritageColors.res.withOpacity(0.1),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Base/Fallback Image Layer
            Image.asset(
              fallbackImage,
              fit: BoxFit.cover,
            ),
            
            // Primary Image Layer (with error handling)
            Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
            ),

            // Content Overlay
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city.toUpperCase(),
                    style: const TextStyle(color: KurdishHeritageColors.zer, fontSize: 8, letterSpacing: 2, fontWeight: FontWeight.w900),
                  ),
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),

            // Subtle Weather Indicator
            if (weather != null)
              Positioned(
                top: 12,
                right: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.1)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(WeatherService.iconFromCode(weather.weatherCode), color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            '${weather.tempC.round()}°',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _getFallbackForCategory(String cat) {
    switch (cat.toLowerCase()) {
      case 'nature': return 'assets/images/hd_mountains.jpg';
      case 'historical': return 'assets/images/hd_ruins.jpg';
      case 'waterfalls': return 'assets/images/hd_waterfall.jpg';
      case 'religious': return 'assets/images/hd_mosque.jpg';
      case 'food': return 'assets/images/hd_bazaar.jpg';
      default: return 'assets/images/erbil.jpg';
    }
  }
}


