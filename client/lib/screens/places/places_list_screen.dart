// Polished cinematic Places List screen.
// Drop into: lib/screens/places/places_list_screen.dart
 
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../../data/live_data.dart';
import '../../data/place_repo.dart';
import '../../widgets/place_image.dart';
import '../../widgets/weather_chip.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
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
  _SortKey _sortKey = _SortKey.rating;
  bool _premiumOnly = false;
  String _activeFilter = 'All';
 
  @override
  Widget build(BuildContext context) {
    final name = _catTitle(widget.categoryId);
    var places = PlaceRepo.list(cityId: widget.cityId, categoryId: widget.categoryId);
    
    if (_premiumOnly) {
      places = places.where((p) => p.price.contains('\$')).toList();
    }
    
    places = [...places];
    switch (_sortKey) {
      case _SortKey.rating:
        places.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _SortKey.alphabetical:
        places.sort((a, b) => a.title.compareTo(b.title));
        break;
      case _SortKey.premium:
        places.sort((a, b) {
          final ap = a.price.contains('\$') ? 0 : 1;
          final bp = b.price.contains('\$') ? 0 : 1;
          if (ap != bp) return ap - bp;
          return b.rating.compareTo(a.rating);
        });
        break;
    }
 
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
              _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.06), -100, 100, 400),
              _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.06), 300, 400, 300),
 
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Top Nav ──
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
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
                            Text(
                              'EXPLORE',
                              style: TextStyle(
                                color: KurdishHeritageColors.zer,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 5,
                              ),
                            ),
                            PressScale(
                              onTap: () => _showFilterSheet(context, isDark),
                              child: Glass(
                                radius: 999,
                                padding: const EdgeInsets.all(12),
                                child: Icon(Icons.tune_rounded, color: ink, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
 
                  // ── Hero Title ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RevealText(
                            name,
                            style: TextStyle(
                              color: ink,
                              fontWeight: FontWeight.w900,
                              fontSize: 42,
                              height: 1.1,
                              letterSpacing: -1.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${places.length} spectacular places to visit',
                            style: TextStyle(
                              color: ink.withOpacity(0.5),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Builder(
                            builder: (_) {
                              final apiCity = LiveData.cityForSlug(widget.cityId);
                              if (apiCity?.id != null) {
                                return WeatherChip(cityId: apiCity!.id);
                              }
                              return const SizedBox.shrink();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
 
                  // ── Filter Chips ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 32),
                      child: _buildFilterRow(isDark),
                    ),
                  ),
 
                  // ── List ──
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 150),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => ScrollReveal(
                          duration: Duration(milliseconds: Motion.md.inMilliseconds + (i.clamp(0, 6) * 40)),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 24),
                            child: _ProPlaceCard(
                              place: places[i],
                              onTap: () => context.push('/place/${places[i].id}'),
                            ),
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
 
  Widget _buildFilterRow(bool isDark) {
    final filters = ['All', 'Popular', 'Nearest', 'Top Rated'];
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return SizedBox(
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: filters.length,
        itemBuilder: (context, i) {
          final isSelected = _activeFilter == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: PressScale(
              onTap: () => setState(() => _activeFilter = filters[i]),
              child: AnimatedContainer(
                duration: Motion.sm,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: isSelected ? KurdishHeritageColors.zer : ink.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent),
                ),
                alignment: Alignment.center,
                child: Text(
                  filters[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : ink.withOpacity(0.6),
                    fontWeight: FontWeight.w900,
                    fontSize: 12,
                    letterSpacing: 0.5,
                  ),
                ),
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
      case 'mall': return 'Malls';
      default: return 'Places';
    }
  }
 
  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Glass(
        radius: 32,
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            const Text('SORT & FILTER', style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 4)),
            const SizedBox(height: 32),
            const Text('Sort by', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: _SortKey.values.map((k) => PressScale(
                onTap: () => setState(() => _sortKey = k),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _sortKey == k ? KurdishHeritageColors.zer : Colors.white10,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(_labelFor(k), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              )).toList(),
            ),
            const SizedBox(height: 32),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              value: _premiumOnly,
              onChanged: (v) => setState(() => _premiumOnly = v),
              activeColor: KurdishHeritageColors.zer,
              title: const Text('Premium only', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              subtitle: const Text('Show only luxury and premium spots', style: TextStyle(color: Colors.white38, fontSize: 11)),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: PressScale(
                  onTap: () {
                    setState(() { _sortKey = _SortKey.rating; _premiumOnly = false; });
                    Navigator.pop(context);
                  },
                  child: Container(height: 56, decoration: BoxDecoration(border: Border.all(color: Colors.white24), borderRadius: BorderRadius.circular(16)), alignment: Alignment.center, child: const Text('RESET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2))),
                )),
                const SizedBox(width: 12),
                Expanded(child: PressScale(
                  onTap: () => Navigator.pop(context),
                  child: Container(height: 56, decoration: BoxDecoration(color: KurdishHeritageColors.zer, borderRadius: BorderRadius.circular(16)), alignment: Alignment.center, child: const Text('APPLY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2))),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  String _labelFor(_SortKey k) {
    switch (k) {
      case _SortKey.rating: return 'Top rated';
      case _SortKey.alphabetical: return 'A → Z';
      case _SortKey.premium: return 'Premium first';
    }
  }
}
 
enum _SortKey { rating, alphabetical, premium }
 
class _ProPlaceCard extends StatelessWidget {
  final dynamic place;
  final VoidCallback onTap;
  const _ProPlaceCard({required this.place, required this.onTap});
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PressScale(
      onTap: onTap,
      child: Glass(
        radius: 35,
        opacity: isDark ? 0.05 : 0.03,
        child: Container(
          height: 380,
          child: Stack(
            children: [
              Positioned.fill(
                child: Hero(
                  tag: 'place-${place.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(35),
                    child: PlaceImage(imagePath: place.coverImage, title: place.title, fit: BoxFit.cover),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black.withOpacity(0.2), Colors.transparent, Colors.black.withOpacity(0.85)],
                      stops: const [0, 0.4, 1],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 24,
                right: 24,
                bottom: 28,
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(Icons.location_on_rounded, size: 14, color: KurdishHeritageColors.zer),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  place.locationText,
                                  style: TextStyle(color: Colors.white.withOpacity(0.6), fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Glass(
                      radius: 18,
                      padding: const EdgeInsets.all(12),
                      opacity: 0.2,
                      child: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
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
