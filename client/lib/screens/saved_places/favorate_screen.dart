import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/favorites_scope.dart';
import '../../data/place_repo.dart';
import '../../services/theme_service.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final fav = FavoritesScope.of(context);
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
                            const Text(
                              'COLLECTIONS',
                              style: TextStyle(
                                color: KurdishHeritageColors.zer,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 4,
                              ),
                            ),
                            if (fav.ids.isNotEmpty)
                              IconButton(
                                onPressed: fav.clear,
                                icon: Icon(Icons.delete_sweep_rounded, color: isDark ? Colors.white54 : Colors.black54),
                              ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        AnimatedBuilder(
                          animation: fav,
                          builder: (context, _) => Text(
                            'Saved Places (${fav.ids.length})',
                            style: TextStyle(
                              color: isDark ? Colors.white : KurdishHeritageColors.res,
                              fontWeight: FontWeight.w900,
                              fontSize: 36,
                              letterSpacing: -1.5,
                            ),
                          ),
                        ),
                        Text(
                          'Your curated Kurdistan journey',
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

              // ── List ──────────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 150),
                sliver: AnimatedBuilder(
                  animation: fav,
                  builder: (context, _) {
                    final savedPlaces = fav.ids
                        .map((id) => PlaceRepo.get(id))
                        .toList(growable: false);

                    if (savedPlaces.isEmpty) {
                      return SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Transform.rotate(
                                angle: 0.785,
                                child: Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    color: KurdishHeritageColors.xweli.withOpacity(0.05),
                                    border: Border.all(color: KurdishHeritageColors.xweli.withOpacity(0.1)),
                                  ),
                                  child: Transform.rotate(
                                    angle: -0.785,
                                    child: Icon(Icons.favorite_border_rounded, size: 40, color: KurdishHeritageColors.xweli.withOpacity(0.2)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                'Your collection is empty',
                                style: TextStyle(
                                  color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
                                  fontWeight: FontWeight.w900,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap ❤️ on any place to save it here',
                                style: TextStyle(
                                  color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) {
                          final p = savedPlaces[i];
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _ProSavedCard(place: p, isDark: isDark, onToggle: () => fav.toggle(p.id)),
                          );
                        },
                        childCount: savedPlaces.length,
                      ),
                    );
                  },
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
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }
}

class _ProSavedCard extends StatelessWidget {
  final dynamic place;
  final bool isDark;
  final VoidCallback onToggle;
  const _ProSavedCard({required this.place, required this.isDark, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/place/${place.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(place.coverImage, width: 80, height: 80, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    place.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: isDark ? Colors.white : KurdishHeritageColors.res),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 12, color: KurdishHeritageColors.zer),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? Colors.white54 : Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onToggle,
              icon: const Icon(Icons.favorite_rounded, color: KurdishHeritageColors.sor),
            ),
          ],
        ),
      ),
    );
  }
}
