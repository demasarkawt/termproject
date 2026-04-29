import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/place_repo.dart';
import '../../data/favorites_scope.dart';
import '../../widgets/place_image.dart';
import '../../services/theme_service.dart';

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
        _imagesCtrl.animateToPage(next, duration: const Duration(milliseconds: 600), curve: Curves.easeInOutCubic);
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Glow Blobs ──────────────────────────────────────────
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.1), -100, 300, 400),
          _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.1), 300, 600, 300),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── Header Gallery ──────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 450,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: const SizedBox(),
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      Hero(
                        tag: 'placeHero-${place.id}',
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
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                              isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi,
                            ],
                          ),
                        ),
                      ),
                      // Indicator
                      Positioned(
                        bottom: 40,
                        left: 0,
                        right: 0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            place.images.isEmpty ? 1 : place.images.length,
                            (i) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: _pageIndex == i ? 24 : 8,
                              height: 8,
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

              // ── Content ───────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 150),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
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
                                  style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  place.title,
                                  style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontWeight: FontWeight.w900, fontSize: 32, letterSpacing: -1),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star_rounded, color: KurdishHeritageColors.zer, size: 18),
                                const SizedBox(width: 4),
                                Text(place.rating.toStringAsFixed(1), style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Info Grid
                      Row(
                        children: [
                          Expanded(child: _ProInfoCard(icon: Icons.attach_money_rounded, label: 'Price', value: place.price)),
                          const SizedBox(width: 16),
                          Expanded(child: _ProInfoCard(icon: Icons.timer_rounded, label: 'Duration', value: place.duration)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(child: _ProInfoCard(icon: Icons.access_time_rounded, label: 'Hours', value: place.hours)),
                          const SizedBox(width: 16),
                          Expanded(child: _ProInfoCard(icon: Icons.terrain_rounded, label: 'Altitude', value: place.altitude)),
                        ],
                      ),
                      
                      const SizedBox(height: 40),
                      Text('About', style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontWeight: FontWeight.w900, fontSize: 20)),
                      const SizedBox(height: 16),
                      Text(
                        place.about,
                        style: TextStyle(color: isDark ? Colors.white.withOpacity(0.6) : Colors.black.withOpacity(0.6), fontSize: 16, height: 1.6, fontWeight: FontWeight.w500),
                      ),
                      
                      const SizedBox(height: 40),
                      Text('Highlights', style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontWeight: FontWeight.w900, fontSize: 20)),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: place.highlights.map((h) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
                          ),
                          child: Text(h, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.8) : Colors.black.withOpacity(0.7), fontSize: 13, fontWeight: FontWeight.bold)),
                        )).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── Floating Action Bar ─────────────────────────────────────
          Positioned(
            left: 20,
            right: 20,
            bottom: 125, // Increased to clear the taller heritage nav bar
            child: Row(
              children: [
                _buildGlassCircleBtn(Icons.arrow_back_ios_new_rounded, () => context.canPop() ? context.pop() : context.go('/home'), isDark),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => context.push('/place-map?lat=${place.lat}&lng=${place.lng}&title=${Uri.encodeComponent(place.title)}'),
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        color: KurdishHeritageColors.sor,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [BoxShadow(color: KurdishHeritageColors.sor.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      alignment: Alignment.center,
                      child: const Text('GET DIRECTIONS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                _buildGlassCircleBtn(isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded, () => fav.toggle(place.id), isDark, color: isFav ? Colors.redAccent : (isDark ? Colors.white : KurdishHeritageColors.res)),
              ],
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
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  Widget _buildGlassCircleBtn(IconData icon, VoidCallback onTap, bool isDark, {Color? color}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              shape: BoxShape.circle,
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
            ),
            child: Icon(icon, color: color ?? (isDark ? Colors.white : KurdishHeritageColors.res), size: 24),
          ),
        ),
      ),
    );
  }
}

class _ProInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _ProInfoCard({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: KurdishHeritageColors.zer.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: KurdishHeritageColors.zer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: isDark ? Colors.white.withOpacity(0.4) : Colors.black.withOpacity(0.4), fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res, fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
