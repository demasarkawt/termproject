// Polished cinematic Place Detail screen.
// Drop into: lib/screens/places/place_detail_screen.dart
 
import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../../data/place_repo.dart';
import '../../data/favorites_scope.dart';
import '../../widgets/place_image.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
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
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      final place = PlaceRepo.get(widget.placeId);
      final count = place.images.isEmpty ? 1 : place.images.length;
      if (count <= 1) return;
      final next = (_pageIndex + 1) % count;
      setState(() => _pageIndex = next);
      if (_imagesCtrl.hasClients) {
        _imagesCtrl.animateToPage(next, duration: Motion.lg, curve: Motion.between);
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
    final fav = FavoritesScope.of(context);
    final isFav = fav.isSaved(place.id);
 
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
              // Parallax Header & Content.
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: 500,
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    leading: const SizedBox(),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Stack(
                        fit: StackFit.expand,
                        children: [
                          Hero(
                            tag: 'place-${place.id}',
                            child: PageView.builder(
                              controller: _imagesCtrl,
                              itemCount: place.images.isEmpty ? 1 : place.images.length,
                              onPageChanged: (i) => setState(() => _pageIndex = i),
                              itemBuilder: (context, i) {
                                return PlaceImage(
                                  imagePath: place.images.isEmpty ? place.coverImage : place.images[i],
                                  title: place.title,
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.35),
                                  Colors.transparent,
                                  bg,
                                ],
                                stops: const [0.0, 0.5, 1.0],
                              ),
                            ),
                          ),
                          // Pagination dots.
                          Positioned(
                            bottom: 40,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(
                                place.images.isEmpty ? 1 : place.images.length,
                                (i) => AnimatedContainer(
                                  duration: Motion.md,
                                  margin: const EdgeInsets.symmetric(horizontal: 4),
                                  width: _pageIndex == i ? 24 : 8,
                                  height: 3,
                                  decoration: BoxDecoration(
                                    color: _pageIndex == i ? KurdishHeritageColors.zer : Colors.white.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
 
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 180),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Section.
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      place.locationText.toUpperCase(),
                                      style: const TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 4),
                                    ),
                                    const SizedBox(height: 10),
                                    RevealText(
                                      place.title,
                                      style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 38, height: 1.05, letterSpacing: -1.5),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Glass(
                                radius: 18,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded, color: KurdishHeritageColors.zer, size: 20),
                                    const SizedBox(width: 4),
                                    Text(place.rating.toStringAsFixed(1), style: TextStyle(color: ink, fontWeight: FontWeight.w900)),
                                  ],
                                ),
                              ),
                            ],
                          ),
 
                          const SizedBox(height: 36),
 
                          // Info Grid.
                          _buildInfoGrid(place, isDark),
 
                          const SizedBox(height: 48),
                          _buildSectionHeader('ABOUT', isDark),
                          const SizedBox(height: 16),
                          Text(
                            place.about,
                            style: TextStyle(color: ink.withOpacity(0.7), fontSize: 16, height: 1.7, fontWeight: FontWeight.w500),
                          ),
 
                          const SizedBox(height: 40),
                          _buildSectionHeader('HIGHLIGHTS', isDark),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: place.highlights.map((h) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: ink.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: ink.withOpacity(0.1)),
                              ),
                              child: Text(h, style: TextStyle(color: ink.withOpacity(0.8), fontSize: 13, fontWeight: FontWeight.w800)),
                            )).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
 
              // Custom Floating Header Actions.
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
                        onTap: () => fav.toggle(place.id),
                        child: Glass(
                          radius: 999,
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isFav ? KurdishHeritageColors.sor : ink,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
 
              // Bottom Action Button.
              Positioned(
                left: 24,
                right: 24,
                bottom: 36,
                child: PressScale(
                  onTap: () => context.push('/place-map?lat=${place.lat}&lng=${place.lng}&title=${Uri.encodeComponent(place.title)}'),
                  child: Container(
                    height: 64,
                    decoration: BoxDecoration(
                      color: KurdishHeritageColors.sor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(color: KurdishHeritageColors.sor.withOpacity(0.35), blurRadius: 20, offset: const Offset(0, 10)),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text('BEGIN NAVIGATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 4, fontSize: 12)),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 
  Widget _buildInfoGrid(PlaceData place, bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _InfoTile(Icons.attach_money_rounded, 'COST', place.price)),
            const SizedBox(width: 16),
            Expanded(child: _InfoTile(Icons.timer_rounded, 'TIME', place.duration)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _InfoTile(Icons.access_time_rounded, 'OPEN', place.hours)),
            const SizedBox(width: 16),
            Expanded(child: _InfoTile(Icons.terrain_rounded, 'ALTITUDE', place.altitude)),
          ],
        ),
      ],
    );
  }
 
  Widget _buildSectionHeader(String title, bool isDark) {
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return Text(title, style: TextStyle(color: ink.withOpacity(0.3), fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 3));
  }
}
 
class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoTile(this.icon, this.label, this.value);
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
    return Glass(
      radius: 20,
      padding: const EdgeInsets.all(16),
      opacity: isDark ? 0.05 : 0.03,
      child: Row(
        children: [
          Icon(icon, color: KurdishHeritageColors.zer, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: ink.withOpacity(0.4), fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: ink, fontWeight: FontWeight.w900, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
