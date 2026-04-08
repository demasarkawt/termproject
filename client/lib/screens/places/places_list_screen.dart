import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/place_repo.dart';
import '../../widgets/glass.dart';

class PlacesListScreen extends StatelessWidget {
  final String cityId;
  final String categoryId;

  const PlacesListScreen({
    super.key,
    required this.cityId,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context) {
    final places = PlaceRepo.list(cityId: cityId, categoryId: categoryId);
    final cityName = _cityTitle(cityId);
    final catName = _catTitle(categoryId);

    return Scaffold(
      backgroundColor: const Color(0xFFF7FFFB),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            pinned: true,
            centerTitle: true,
            leading: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: _CircleGlassBtn(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: () => context.pop(),
              ),
            ),
            title: Glass(
              radius: 999,
              blur: 16,
              opacity: 0.18,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Text(
                '$cityName • $catName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0B3D3B),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
            sliver: places.isEmpty
                ? SliverToBoxAdapter(
              child: Glass(
                radius: 22,
                blur: 16,
                opacity: 0.16,
                padding: const EdgeInsets.all(16),
                child: const Text(
                  'No places added for this category yet.',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            )
                : SliverList.separated(
              itemCount: places.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = places[i];
                return _IOSGlassPlaceCard(
                  place: p,
                  onTap: () => context.go('/place/${p.id}'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _cityTitle(String id) {
    switch (id) {
      case 'erbil': return 'Erbil';
      case 'sulaymaniyah': return 'Sulaymaniyah';
      case 'duhok': return 'Duhok';
      case 'halabja': return 'Halabja';
      default: return 'City';
    }
  }

  String _catTitle(String id) {
    switch (id) {
      case 'historical': return 'Historical';
      case 'nature': return 'Nature';
      case 'waterfalls': return 'Waterfalls';
      case 'religious': return 'Religious';
      case 'activities': return 'Activities';
      default: return 'Places';
    }
  }
}

class _IOSGlassPlaceCard extends StatelessWidget {
  final PlaceData place;
  final VoidCallback onTap;

  const _IOSGlassPlaceCard({
    required this.place,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                place.coverImage,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFFEFFCF7),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_rounded,
                      color: Color(0xFF0F766E), size: 40),
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
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.62),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Glass(
                radius: 22,
                blur: 18,
                opacity: 0.16,
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withOpacity(0.22)),
                      ),
                      child: const Icon(Icons.place_rounded, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded,
                                  size: 14, color: Colors.white),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place.locationText,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.88),
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F766E),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            blurRadius: 18,
                            offset: Offset(0, 10),
                            color: Color(0x22000000),
                          )
                        ],
                      ),
                      child: const Icon(Icons.arrow_forward_rounded,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleGlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleGlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.22),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}
