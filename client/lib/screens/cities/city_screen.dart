// lib/screens/cities/city_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/glass.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Category data — real photos per category
// ─────────────────────────────────────────────────────────────────────────────
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
    accent: Color(0xFFFF8A3D),
    imagePath: 'assets/images/place_citadel.png',
  ),
  _CatData(
    id: 'nature',
    label: 'Nature',
    subtitle: 'Mountains & Parks',
    icon: Icons.park_rounded,
    accent: Color(0xFF16A34A),
    imagePath: 'assets/images/hd_mountains.jpg',
  ),
  _CatData(
    id: 'waterfalls',
    label: 'Waterfalls',
    subtitle: 'Rivers & Springs',
    icon: Icons.water_drop_rounded,
    accent: Color(0xFF2563EB),
    imagePath: 'assets/images/hd_waterfall.jpg',
  ),
  _CatData(
    id: 'religious',
    label: 'Religious',
    subtitle: 'Mosques & Heritage',
    icon: Icons.mosque_rounded,
    accent: Color(0xFFDB2777),
    imagePath: 'assets/images/hd_mosque.jpg',
  ),
  _CatData(
    id: 'activities',
    label: 'Activities',
    subtitle: 'Hiking & Adventure',
    icon: Icons.hiking_rounded,
    accent: Color(0xFF7C3AED),
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

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────
class CityScreen extends StatelessWidget {
  final String cityId;
  const CityScreen({super.key, required this.cityId});

  @override
  Widget build(BuildContext context) {
    final name = _cityName(cityId);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Hero ─────────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: _CityHero(cityId: cityId, name: name),
              ),

              // ── Title ────────────────────────────────────────────────────
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 22, 20, 2),
                  child: Text(
                    'Explore Categories',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 14),
                  child: Text(
                    'Choose what you want to discover today',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ),

              // ── 2-column photo grid ───────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _CategoryPhotoCard(
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

          // ── Top nav ───────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  _RoundGlassBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go('/home');
                      }
                    },
                  ),
                  const Spacer(),
                  _RoundGlassBtn(
                    icon: Icons.favorite_border_rounded,
                    onTap: () => context.go('/favorites'),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom fade + pills ───────────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.10),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16, right: 16, bottom: 14,
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: _PillAction(
                      icon: Icons.bookmark_rounded,
                      text: 'Saved',
                      onTap: () => context.go('/favorites'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PillAction(
                      icon: Icons.map_rounded,
                      text: 'Map',
                      onTap: () => context.go('/map'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _cityName(String id) {
    switch (id) {
      case 'erbil':         return 'Erbil';
      case 'sulaymaniyah':  return 'Sulaymaniyah';
      case 'duhok':         return 'Duhok';
      case 'halabja':       return 'Halabja';
      default:              return 'City';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// City hero header
// ─────────────────────────────────────────────────────────────────────────────
class _CityHero extends StatelessWidget {
  final String cityId;
  final String name;
  const _CityHero({required this.cityId, required this.name});

  String _asset(String id) {
    switch (id) {
      case 'erbil':         return 'assets/images/erbil.jpg';
      case 'sulaymaniyah':  return 'assets/images/sulaymaniyah.jpg';
      case 'duhok':         return 'assets/images/duhok.jpg';
      case 'halabja':       return 'assets/images/halabja.jpg';
      default:              return 'assets/images/erbil.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: 'cityHero-$cityId',
              child: Image.asset(
                _asset(cityId),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF0F766E),
                  child: const Icon(Icons.image_not_supported_rounded,
                      size: 46, color: Colors.white30),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.30),
                    Colors.transparent,
                    Colors.black.withOpacity(0.70),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
              ),
            ),
          ),
          Positioned(
            left: 20, right: 20, bottom: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 36,
                    height: 1.0,
                    letterSpacing: -1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.location_on_rounded,
                        size: 13, color: Colors.white60),
                    const SizedBox(width: 4),
                    Text(
                      'Kurdistan Region, Iraq',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.70),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category card — REAL PHOTO background + small icon badge
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryPhotoCard extends StatelessWidget {
  final _CatData data;
  final VoidCallback onTap;
  const _CategoryPhotoCard({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Real photo background ─────────────────────────────────
              Image.asset(
                data.imagePath,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: data.accent.withOpacity(0.15),
                  child: Icon(data.icon, color: data.accent, size: 40),
                ),
              ),

              // ── Dark gradient so text is always readable ──────────────
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.08),
                      Colors.black.withOpacity(0.62),
                    ],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),

              // ── Small icon badge (top-left) ───────────────────────────
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: data.accent,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: data.accent.withOpacity(0.45),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(data.icon, color: Colors.white, size: 18),
                ),
              ),

              // ── Text content (bottom) ─────────────────────────────────
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      data.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.78),
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Explore pill
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text(
                            'Explore',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded,
                              color: Colors.white, size: 11),
                        ],
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

// ─────────────────────────────────────────────────────────────────────────────
// Round glass button
// ─────────────────────────────────────────────────────────────────────────────
class _RoundGlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundGlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.white.withOpacity(0.16),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom pill action
// ─────────────────────────────────────────────────────────────────────────────
class _PillAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _PillAction(
      {required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.white.withOpacity(0.72),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFF0F766E), size: 20),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: const TextStyle(
                      color: Color(0xFF0B3D3B),
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
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
