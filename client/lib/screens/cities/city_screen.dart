// Polished cinematic City screen.
// Drop into: lib/screens/cities/city_screen.dart
 
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/live_data.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
import '../../widgets/weather_chip.dart';
 
class _CatData {
  final String id;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final String imagePath;
 
  const _CatData({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.accent,
    required this.imagePath,
  });
}
 
const List<_CatData> _categories = [
  _CatData(
    id: 'historical',
    label: 'Historical',
    subtitle: 'Citadels & Museums',
    icon: Icons.account_balance_rounded,
    accent: KurdishHeritageColors.sor,
    imagePath: 'assets/images/place_citadel.png',
  ),
  _CatData(
    id: 'nature',
    label: 'Nature',
    subtitle: 'Mountains & Parks',
    icon: Icons.park_rounded,
    accent: KurdishHeritageColors.kesk,
    imagePath: 'assets/images/hd_mountains.jpg',
  ),
  _CatData(
    id: 'waterfalls',
    label: 'Waterfalls',
    subtitle: 'Rivers & Springs',
    icon: Icons.water_drop_rounded,
    accent: Color(0xFF1E3A8A),
    imagePath: 'assets/images/hd_waterfall.jpg',
  ),
  _CatData(
    id: 'religious',
    label: 'Religious',
    subtitle: 'Mosques & Heritage',
    icon: Icons.mosque_rounded,
    accent: KurdishHeritageColors.zer,
    imagePath: 'assets/images/hd_mosque.jpg',
  ),
  _CatData(
    id: 'activities',
    label: 'Activities',
    subtitle: 'Hiking & Adventure',
    icon: Icons.hiking_rounded,
    accent: KurdishHeritageColors.xweli,
    imagePath: 'assets/images/hd_valley.jpg',
  ),
  _CatData(
    id: 'food',
    label: 'Food & Dining',
    subtitle: 'Restaurants & Cafés',
    icon: Icons.restaurant_rounded,
    accent: Color(0xFFDC2626),
    imagePath: 'assets/images/hd_bazaar.jpg',
  ),
];
 
class CityScreen extends StatelessWidget {
  final String cityId;
  const CityScreen({super.key, required this.cityId});
 
  @override
  Widget build(BuildContext context) {
    final name = _cityName(cityId);
 
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
        final bg = isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi;
 
        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              // Parallax Header.
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 440,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: const SizedBox(),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'cityHero-$cityId',
                            child: Image.asset(
                              _cityAsset(cityId),
                              fit: BoxFit.cover,
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.4),
                                  Colors.transparent,
                                  bg,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 24,
                            right: 24,
                            bottom: 40,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name.toUpperCase(),
                                  style: const TextStyle(
                                    color: KurdishHeritageColors.zer,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    letterSpacing: 6,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                RevealText(
                                  'Explore\n$name',
                                  style: TextStyle(
                                    color: ink,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 48,
                                    height: 1.05,
                                    letterSpacing: -2,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Builder(
                                  builder: (_) {
                                    final apiCity = LiveData.cityForSlug(cityId);
                                    if (apiCity?.id != null) {
                                      return WeatherChip(cityId: apiCity!.id);
                                    }
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
 
                  // Category Grid.
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 20,
                        crossAxisSpacing: 20,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ScrollReveal(
                          duration: Duration(milliseconds: Motion.md.inMilliseconds + (i % 2) * 80),
                          child: _ProCategoryCard(
                            data: _categories[i],
                            onTap: () => context.push('/city/$cityId/category/${_categories[i].id}'),
                          ),
                        ),
                        childCount: _categories.length,
                      ),
                    ),
                  ),
                ],
              ),
 
              // Custom Top Bar.
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      PressScale(
                        onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                        child: Glass(
                          radius: 999,
                          padding: const EdgeInsets.all(12),
                          child: Icon(Icons.arrow_back_ios_new_rounded, color: ink, size: 18),
                        ),
                      ),
                      PressScale(
                        onTap: () => context.push('/favorites'),
                        child: Glass(
                          radius: 999,
                          padding: const EdgeInsets.all(12),
                          child: Icon(Icons.favorite_rounded, color: KurdishHeritageColors.sor, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 
  String _cityName(String id) {
    switch (id) {
      case 'erbil': return 'Erbil';
      case 'sulaymaniyah': return 'Sulaymaniyah';
      case 'duhok': return 'Duhok';
      case 'halabja': return 'Halabja';
      default: return 'City';
    }
  }
 
  String _cityAsset(String id) {
    switch (id) {
      case 'erbil': return 'assets/images/erbil.jpg';
      case 'sulaymaniyah': return 'assets/images/sulaymaniyah.jpg';
      case 'duhok': return 'assets/images/duhok.jpg';
      case 'halabja': return 'assets/images/halabja.jpg';
      default: return 'assets/images/erbil.jpg';
    }
  }
}
 
class _ProCategoryCard extends StatelessWidget {
  final _CatData data;
  final VoidCallback onTap;
  const _ProCategoryCard({required this.data, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
    return PressScale(
      onTap: onTap,
      child: Glass(
        radius: 30,
        opacity: isDark ? 0.05 : 0.03,
        child: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(data.imagePath, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: data.accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(data.icon, color: data.accent, size: 22),
                  ),
                  const Spacer(),
                  Text(
                    data.label,
                    style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    data.subtitle,
                    style: TextStyle(color: ink.withOpacity(0.5), fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
