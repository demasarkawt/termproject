// lib/screens/cities/city_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/glass.dart';

// Top-level helper: pick the right image for each city × category
String _catImage(String cityId, String catId) {
  const imgs = {
    'erbil': {
      'historical': 'assets/images/place_citadel.png',
      'nature':     'assets/images/place_shaqlawa.png',
      'waterfalls': 'assets/images/place_bekhal.png',
      'religious':  'assets/images/place_mosque.png',
      'activities': 'assets/images/cha.JPEG',
    },
    'sulaymaniyah': {
      'historical': 'assets/images/place_amna_suraka.jpg',
      'nature':     'assets/images/hd_mountains.jpg',
      'waterfalls': 'assets/images/place_ahmed_awa.jpg',
      'religious':  'assets/images/hd_mosque.jpg',
      'activities': 'assets/images/hd_park.jpg',
    },
    'duhok': {
      'historical': 'assets/images/place_amedi.jpg',
      'nature':     'assets/images/hd_valley.jpg',
      'waterfalls': 'assets/images/hd_waterfall.jpg',
      'religious':  'assets/images/place_lalish.jpg',
      'activities': 'assets/images/hd_mountains.jpg',
    },
    'halabja': {
      'historical': 'assets/images/place_halabja_monument.jpg',
      'nature':     'assets/images/place_hawraman.jpg',
      'waterfalls': 'assets/images/place_ahmed_awa.jpg',
      'religious':  'assets/images/hd_mosque.jpg',
      'activities': 'assets/images/hd_mountains.jpg',
    },
  };
  return imgs[cityId]?[catId] ?? 'assets/images/hd_mountains.jpg';
}

class CityScreen extends StatelessWidget {
  final String cityId;
  const CityScreen({super.key, required this.cityId});

  @override
  Widget build(BuildContext context) {
    final name = _cityName(cityId);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _ModernCityHero(cityId: cityId, name: name),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      _CategoryCard(
                        emoji: '🏛️',
                        title: 'Historical',
                        subtitle: 'Citadels • bazaars • museums',
                        accent: const Color(0xFFFF8A3D),
                        image: _catImage(cityId, 'historical'),
                        onTap: () => context.go('/city/$cityId/category/historical'),
                      ),
                      const SizedBox(height: 14),
                      _CategoryCard(
                        emoji: '🌿',
                        title: 'Nature',
                        subtitle: 'Mountains • parks • viewpoints',
                        accent: const Color(0xFF22C55E),
                        image: _catImage(cityId, 'nature'),
                        onTap: () => context.go('/city/$cityId/category/nature'),
                      ),
                      const SizedBox(height: 14),
                      _CategoryCard(
                        emoji: '💧',
                        title: 'Waterfalls',
                        subtitle: 'Rivers • springs • falls',
                        accent: const Color(0xFF2563EB),
                        image: _catImage(cityId, 'waterfalls'),
                        onTap: () => context.go('/city/$cityId/category/waterfalls'),
                      ),
                      const SizedBox(height: 14),
                      _CategoryCard(
                        emoji: '🕌',
                        title: 'Religious',
                        subtitle: 'Mosques • churches • heritage',
                        accent: const Color(0xFFEC4899),
                        image: _catImage(cityId, 'religious'),
                        onTap: () => context.go('/city/$cityId/category/religious'),
                      ),
                      const SizedBox(height: 14),
                      _CategoryCard(
                        emoji: '⚡️',
                        title: 'Activities',
                        subtitle: 'Hiking • adventure • weekend',
                        accent: const Color(0xFF8B5CF6),
                        image: _catImage(cityId, 'activities'),
                        onTap: () => context.go('/city/$cityId/category/activities'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ✅ Top floating buttons (iOS style)
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

          // ✅ Soft fade behind bottom actions (always readable)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: IgnorePointer(
              child: Container(
                height: 130,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.12),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ✅ Floating bottom quick actions (NOW visible: dark text/icons)
          Positioned(
            left: 16,
            right: 16,
            bottom: 14,
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
      case 'erbil':
        return 'Erbil';
      case 'sulaymaniyah':
        return 'Sulaymaniyah';
      case 'duhok':
        return 'Duhok';
      case 'halabja':
        return 'Halabja';
      default:
        return 'City';
    }
  }
}

/// ✅ Hero header using ASSET image (not network)
class _ModernCityHero extends StatelessWidget {
  final String cityId;
  final String name;
  const _ModernCityHero({required this.cityId, required this.name});

  String _assetForCity(String id) {
    // Put your hero images here
    switch (id) {
      case 'erbil':
        return 'assets/images/erbil.jpg';
      case 'sulaymaniyah':
        return 'assets/images/sulaymaniyah.jpg';
      case 'duhok':
        return 'assets/images/duhok.jpg';
      case 'halabja':
        return 'assets/images/halabja.jpg';
      default:
        return 'assets/images/erbil.jpg';
    }
  }

  @override
  Widget build(BuildContext context) {
    final hero = _assetForCity(cityId);

    return SizedBox(
      height: 320,
      child: Stack(
        children: [
          Positioned.fill(
            child: Hero(
              tag: 'cityHero-$cityId',
              child: Image.asset(
                hero,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEFF2F6),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported_rounded,
                    size: 46,
                    color: Color(0xFF0F766E),
                  ),
                ),
              ),
            ),
          ),

          // modern dark gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.50),
                    Colors.transparent,
                    Colors.black.withOpacity(0.78),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // city title + mini info card
          Positioned(
            left: 16,
            right: 16,
            bottom: 18,
            child: Glass(
              radius: 26,
              blur: 18,
              opacity: 0.14,
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 20,
                          offset: Offset(0, 12),
                          color: Color(0x22000000),
                        )
                      ],
                    ),
                    child: const Icon(Icons.location_on_rounded, color: Colors.white),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Choose a category to explore',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.80),
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Photo-backed category card — shows a real image for each city+category
class _CategoryCard extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final Color accent;
  final String image;       // asset path
  final VoidCallback onTap;

  const _CategoryCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: SizedBox(
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background photo ─────────────────────────────────────
              Image.asset(
                image,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: accent.withOpacity(0.18),
                  alignment: Alignment.center,
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 48)),
                ),
              ),

              // ── Gradient overlay ─────────────────────────────────────
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      accent.withOpacity(0.82),
                      Colors.black.withOpacity(0.55),
                    ],
                  ),
                ),
              ),

              // ── Content ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 14, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Emoji icon box
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 26)),
                    ),
                    const SizedBox(width: 16),

                    // Title + subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 18,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  blurRadius: 6,
                                  color: Colors.black38,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // Mini chips
                          Row(
                            children: [
                              _MiniChip(text: 'Top spots', color: Colors.white),
                              const SizedBox(width: 6),
                              _MiniChip(text: 'Photos', color: Colors.white),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Arrow button
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.35),
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
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

class _MiniChip extends StatelessWidget {
  final String text;
  final Color color;
  const _MiniChip({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w900,
          fontSize: 11,
        ),
      ),
    );
  }
}

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

/// ✅ UPDATED: Bottom buttons
class _PillAction extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  const _PillAction({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.white.withOpacity(0.68),
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: onTap,
            child: Container(
              height: 54,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.black.withOpacity(0.06)),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 18,
                    offset: Offset(0, 12),
                    color: Color(0x14000000),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: const Color(0xFF0F766E)),
                  const SizedBox(width: 10),
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
