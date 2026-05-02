// Polished cinematic Favorites (Saved Places) screen.
// Drop into: lib/screens/saved_places/favorate_screen.dart
 
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../../data/favorites_scope.dart';
import '../../data/place_repo.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});
 
  @override
  Widget build(BuildContext context) {
    final fav = FavoritesScope.of(context);
    
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.08), -100, 100, 400),
              _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.08), 300, 400, 300),
 
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Header ──
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
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
                                  PressScale(
                                    onTap: fav.clear,
                                    child: Glass(
                                      radius: 999,
                                      padding: const EdgeInsets.all(8),
                                      child: Icon(Icons.delete_sweep_rounded, color: ink.withOpacity(0.4), size: 20),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            AnimatedBuilder(
                              animation: fav,
                              builder: (context, _) => RevealText(
                                'Saved Places (${fav.ids.length})',
                                style: TextStyle(
                                  color: ink,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 38,
                                  height: 1.1,
                                  letterSpacing: -1.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your curated Travelo tour list',
                              style: TextStyle(
                                color: ink.withOpacity(0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
 
                  // ── List ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 150),
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
                                  GoldRingSweep(
                                    size: 100,
                                    thickness: 1,
                                    child: Icon(Icons.favorite_border_rounded, size: 40, color: ink.withOpacity(0.15)),
                                  ),
                                  const SizedBox(height: 32),
                                  Text(
                                    'Your collection is empty',
                                    style: TextStyle(
                                      color: ink.withOpacity(0.3),
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tap ❤️ on any place to save it here',
                                    style: TextStyle(
                                      color: ink.withOpacity(0.24),
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
                              return ScrollReveal(
                                duration: Duration(milliseconds: Motion.md.inMilliseconds + (i.clamp(0, 8) * 40)),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _ProSavedCard(place: p, isDark: isDark, onToggle: () => fav.toggle(p.id)),
                                ),
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
}
 
class _ProSavedCard extends StatelessWidget {
  final dynamic place;
  final bool isDark;
  final VoidCallback onToggle;
  const _ProSavedCard({required this.place, required this.isDark, required this.onToggle});
 
  @override
  Widget build(BuildContext context) {
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return PressScale(
      onTap: () => context.push('/place/${place.id}'),
      child: Glass(
        radius: 28,
        padding: const EdgeInsets.all(12),
        opacity: isDark ? 0.05 : 0.03,
        child: Row(
          children: [
            Hero(
              tag: 'place-${place.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(place.coverImage, width: 85, height: 85, fit: BoxFit.cover),
              ),
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
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17, color: ink),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_rounded, size: 13, color: KurdishHeritageColors.zer),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          place.locationText,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ink.withOpacity(0.4)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            PressScale(
              onTap: onToggle,
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.favorite_rounded, color: KurdishHeritageColors.sor, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
