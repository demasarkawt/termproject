import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/place_repo.dart';
import '../../widgets/place_image.dart';
import '../../services/theme_service.dart';

class PlacesListScreen extends StatefulWidget {
  final String cityId;
  final String categoryId;

  const PlacesListScreen({
    super.key,
    required this.cityId,
    required this.categoryId,
  });

  @override
  State<PlacesListScreen> createState() => _PlacesListScreenState();
}

class _PlacesListScreenState extends State<PlacesListScreen> {
  @override
  Widget build(BuildContext context) {
    final name = _catTitle(widget.categoryId);
    final places = PlaceRepo.list(cityId: widget.cityId, categoryId: widget.categoryId);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Glows ──────────────────────────────────────────
          _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.1), -100, 100, 400),
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.1), 300, 400, 300),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header ───────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildGlassCircleBtn(Icons.arrow_back_ios_new_rounded, () => context.canPop() ? context.pop() : context.go('/home'), isDark),
                            Text(
                              'EXPLORE',
                              style: TextStyle(
                                color: KurdishHeritageColors.zer,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 4,
                              ),
                            ),
                            _buildGlassCircleBtn(Icons.tune_rounded, () {}, isDark),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          name,
                          style: TextStyle(
                            color: isDark ? Colors.white : KurdishHeritageColors.res,
                            fontWeight: FontWeight.w900,
                            fontSize: 36,
                            letterSpacing: -1.5,
                          ),
                        ),
                        Text(
                          '${places.length} spectacular places to visit',
                          style: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── Filter Chips ─────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildGlassFilterRow(isDark),
                ),
              ),

              // ── Places List ──────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 150),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: _ProPlaceCard(
                        place: places[i],
                        onTap: () => context.go('/place/${places[i].id}'),
                      ),
                    ),
                    childCount: places.length,
                  ),
                ),
              ),
            ],
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
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
          shape: BoxShape.circle,
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
        ),
        child: Icon(icon, color: isDark ? Colors.white : KurdishHeritageColors.res, size: 20),
      ),
    );
  }

  Widget _buildGlassFilterRow(bool isDark) {
    final filters = ['All', 'Popular', 'Nearest', 'Top Rated'];
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final isSelected = i == 0;
          return Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: isSelected ? KurdishHeritageColors.zer : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05)),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isSelected ? Colors.white.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
            ),
            alignment: Alignment.center,
            child: Text(
              filters[i],
              style: TextStyle(
                color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          );
        },
      ),
    );
  }

  String _catTitle(String id) {
    switch (id) {
      case 'historical': return 'Historical';
      case 'nature': return 'Nature';
      case 'waterfalls': return 'Waterfalls';
      case 'religious': return 'Religious';
      case 'activities': return 'Activities';
      case 'food': return 'Food & Dining';
      default: return 'Places';
    }
  }
}

class _ProPlaceCard extends StatelessWidget {
  final PlaceData place;
  final VoidCallback onTap;
  const _ProPlaceCard({required this.place, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 380,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.black.withOpacity(0.1), width: 1.5),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: PlaceImage(imagePath: place.coverImage, title: place.title, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.2),
                      Colors.transparent,
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          place.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_rounded, size: 14, color: KurdishHeritageColors.zer),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                place.locationText,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
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
