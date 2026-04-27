import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/place_repo.dart';
import '../../data/favorites_scope.dart';
import '../../widgets/glass.dart';
import '../../widgets/place_image.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  final PageController _imagesCtrl = PageController();
  Timer? _autoTimer;

  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();

    // ✅ Auto change image every 5 seconds
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;

      final place = PlaceRepo.get(widget.placeId);
      final count = place.images.isEmpty ? 1 : place.images.length;
      if (count <= 1) return;

      final next = (_pageIndex + 1) % count;

      setState(() => _pageIndex = next);

      if (_imagesCtrl.hasClients) {
        _imagesCtrl.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _imagesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final place = PlaceRepo.get(widget.placeId);

    // ✅ GLOBAL favorites (real saving)
    final fav = FavoritesScope.of(context);
    final isFav = fav.isSaved(place.id);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: _TopGallery(
                  imagesCtrl: _imagesCtrl,
                  heroTag: 'placeHero-${place.id}',
                  images: place.images,
                  title: place.title,
                  category: _categoryTitle(place.categoryId),
                  pageIndex: _pageIndex,
                  onPageChanged: (i) => setState(() => _pageIndex = i),

                  // ✅ back always works
                  onBack: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/city/${place.cityId}/category/${place.categoryId}');
                    }
                  },

                  // ✅ this is the fix
                  onFavorite: () => fav.toggle(place.id),
                  isFav: isFav,

                  onShare: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Share coming soon')),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 96),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              place.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0B3D3B),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Row(
                            children: [
                              ...List.generate(
                                5,
                                    (i) => Icon(
                                  i < place.stars
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  size: 16,
                                  color: Colors.amber,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                place.rating.toStringAsFixed(1),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0B3D3B),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      Row(
                        children: [
                          const Icon(Icons.location_on_rounded,
                              size: 16, color: Color(0xFF0F766E)),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              place.locationText,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _InfoBox(
                              icon: Icons.attach_money_rounded,
                              title: 'Price',
                              value: place.price,
                              tint: const Color(0xFFE8FFF7),
                              iconBg: const Color(0xFF0F766E),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoBox(
                              icon: Icons.timer_rounded,
                              title: 'Duration',
                              value: place.duration,
                              tint: const Color(0xFFE9F2FF),
                              iconBg: const Color(0xFF2563EB),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoBox(
                              icon: Icons.access_time_rounded,
                              title: 'Hours',
                              value: place.hours,
                              tint: const Color(0xFFF1E9FF),
                              iconBg: const Color(0xFF7C3AED),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoBox(
                              icon: Icons.terrain_rounded,
                              title: 'Altitude',
                              value: place.altitude,
                              tint: const Color(0xFFFFF3E2),
                              iconBg: const Color(0xFFEA580C),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Glass(
                        radius: 18,
                        blur: 18,
                        opacity: 0.14,
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'About',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                color: Color(0xFF0B3D3B),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              place.about,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                height: 1.5,
                                color: Color(0xFF334155),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      const Text(
                        'Highlights',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 14,
                          color: Color(0xFF0B3D3B),
                        ),
                      ),
                      const SizedBox(height: 10),

                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: place.highlights.map<Widget>((h) {
                          return Glass(
                            radius: 999,
                            blur: 16,
                            opacity: 0.10,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            child: Text(
                              h,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: Color(0xFF0F766E),
                              ),
                            ),
                          );
                        }).toList(growable: false),
                      ),

                      const SizedBox(height: 16),

                      Glass(
                        radius: 18,
                        blur: 18,
                        opacity: 0.12,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F766E),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.call_rounded,
                                  color: Colors.white),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Phone\n${place.phone}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF0B3D3B),
                                  height: 1.15,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Bottom button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.92),
                  border:
                  Border(top: BorderSide(color: Colors.black.withOpacity(0.06))),
                ),
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        '/place-map?lat=${place.lat}&lng=${place.lng}&title=${Uri.encodeComponent(place.title)}',
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 0,
                    ),
                    icon: const Icon(Icons.near_me_rounded),
                    label: const Text(
                      'Get Directions',
                      style: TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _categoryTitle(String id) {
    switch (id) {
      case 'historical':
        return 'Historical';
      case 'nature':
        return 'Nature';
      case 'waterfalls':
        return 'Waterfalls';
      case 'religious':
        return 'Religious';
      case 'activities':
        return 'Activities';
      default:
        return 'Places';
    }
  }
}

class _TopGallery extends StatelessWidget {
  final PageController imagesCtrl;
  final String heroTag;
  final List<String> images;
  final String title;
  final String category;

  final int pageIndex;
  final ValueChanged<int> onPageChanged;

  final VoidCallback onBack;
  final VoidCallback onFavorite;
  final bool isFav;
  final VoidCallback onShare;

  const _TopGallery({
    required this.imagesCtrl,
    required this.heroTag,
    required this.images,
    required this.title,
    required this.category,
    required this.pageIndex,
    required this.onPageChanged,
    required this.onBack,
    required this.onFavorite,
    required this.isFav,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final safeImages = images.isEmpty ? const <String>[] : images;

    return SizedBox(
      height: 300,
      child: Stack(
        children: [
          Hero(
            tag: heroTag,
            child: PageView.builder(
              controller: imagesCtrl,
              itemCount: safeImages.isEmpty ? 1 : safeImages.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, i) {
                if (safeImages.isEmpty) {
                  return Container(
                    color: const Color(0xFFEFF2F6),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_rounded,
                        size: 44, color: Color(0xFF0F766E)),
                  );
                }
                return PlaceImage(
                  imagePath: safeImages[i],
                  title: title,
                  fit: BoxFit.cover,
                );
              },
            ),
          ),

          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.40),
                    Colors.transparent,
                    Colors.black.withOpacity(0.70),
                  ],
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
              child: Row(
                children: [
                  _TopBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
                  const Spacer(),
                  _TopBtn(
                    icon: isFav
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    onTap: onFavorite,
                  ),
                  const SizedBox(width: 10),
                  _TopBtn(icon: Icons.ios_share_rounded, onTap: onShare),
                ],
              ),
            ),
          ),

          Positioned(
            left: 14,
            top: MediaQuery.of(context).padding.top + 62,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.35),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: Colors.white.withOpacity(0.18)),
              ),
              child: Text(
                category,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 12,
                ),
              ),
            ),
          ),

          if (safeImages.length > 1)
            Positioned(
              left: 0,
              right: 0,
              bottom: 12,
              child: Center(
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(safeImages.length, (i) {
                      final active = i == pageIndex;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        height: 6,
                        width: active ? 18 : 6,
                        decoration: BoxDecoration(
                          color: active
                              ? Colors.white
                              : Colors.white.withOpacity(0.35),
                          borderRadius: BorderRadius.circular(999),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _TopBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.28),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color tint;
  final Color iconBg;

  const _InfoBox({
    required this.icon,
    required this.title,
    required this.value,
    required this.tint,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black.withOpacity(0.04)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    color: Color(0xFF0B3D3B),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                    color: Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
