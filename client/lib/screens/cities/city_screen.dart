import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/live_data.dart';
import '../../services/theme_service.dart';
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
  _CatData(
    id: 'mall',
    label: 'Malls',
    subtitle: 'Shopping & Entertainment',
    icon: Icons.shopping_bag_rounded,
    accent: Color(0xFFA21CAF),
    imagePath: 'assets/images/hd_park.jpg',
  ),
];

class CityScreen extends StatelessWidget {
  final String cityId;
  const CityScreen({super.key, required this.cityId});

  @override
  Widget build(BuildContext context) {
    final name = _cityName(cityId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Glow Blobs ──────────────────────────────────────────
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.15), -100, 200, 400),
          _buildGlowBlob(KurdishHeritageColors.zer.withOpacity(0.1), 300, 500, 300),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Parallax Hero Header ──────────────────────────────────────
              SliverAppBar(
                expandedHeight: 380,
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
                              isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        right: 24,
                        bottom: 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name.toUpperCase(),
                              style: const TextStyle(
                                color: KurdishHeritageColors.zer,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 4,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Explore &\nwander freely',
                              style: TextStyle(
                                color: isDark ? Colors.white : KurdishHeritageColors.res,
                                fontWeight: FontWeight.w900,
                                fontSize: 42,
                                height: 1.0,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Builder(
                              builder: (_) {
                                final apiCity = LiveData.cityForSlug(cityId);
                                if (apiCity?.latitude != null && apiCity?.longitude != null) {
                                  return WeatherChip(
                                    cityId: apiCity!.id,
                                  );
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

              // ── Category Grid ─────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 150),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _ProCategoryCard(
                      data: _categories[i],
                      onTap: () => context
                          .go('/city/$cityId/category/${_categories[i].id}'),
                    ),
                    childCount: _categories.length,
                  ),
                ),
              ),
            ],
          ),

          // ── Floating Custom Top Bar ─────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildGlassCircleBtn(Icons.arrow_back_ios_new_rounded, () => context.canPop() ? context.pop() : context.go('/home'), isDark),
                  _buildGlassCircleBtn(Icons.favorite_border_rounded, () => context.go('/favorites'), isDark),
                ],
              ),
            ),
          ),
        ],
      ),
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
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 100,
              spreadRadius: 50,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCircleBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1)),
            ),
            child: Icon(icon, color: isDark ? Colors.white : KurdishHeritageColors.res, size: 20),
          ),
        ),
      ),
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
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.02),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.05)),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(data.imagePath, fit: BoxFit.cover, opacity: const AlwaysStoppedAnimation(0.4)),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          isDark ? Colors.black.withOpacity(0.8) : Colors.white.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: data.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(data.icon, color: data.accent, size: 20),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        data.label,
                        style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                      Text(
                        data.subtitle,
                        style: TextStyle(color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.w600),
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
