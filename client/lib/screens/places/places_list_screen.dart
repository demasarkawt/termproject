import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../data/live_data.dart';
import '../../data/place_repo.dart';
import '../../widgets/place_image.dart';
import '../../widgets/weather_chip.dart';
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
  _SortKey _sortKey = _SortKey.rating;
  bool _premiumOnly = false;

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
                            _buildGlassCircleBtn(
                              Icons.tune_rounded,
                              () => _showFilterSheet(context, isDark),
                              isDark,
                            ),
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
                            color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Builder(
                          builder: (_) {
                            final apiCity = LiveData.cityForSlug(widget.cityId);
                            if (apiCity?.latitude != null && apiCity?.longitude != null) {
                              return WeatherChip(cityId: apiCity!.id);
                            }
                            return const SizedBox.shrink();
                          },
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
      case 'mall': return 'Malls';
      default: return 'Places';
    }
  }

  void _showFilterSheet(BuildContext context, bool isDark) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark
          ? KurdishHeritageColors.cardDark
          : KurdishHeritageColors.surfaceLight,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) => _FilterSheet(
        sortKey: _sortKey,
        premiumOnly: _premiumOnly,
        onApply: (sortKey, premiumOnly) {
          setState(() {
            _sortKey = sortKey;
            _premiumOnly = premiumOnly;
          });
        },
      ),
    );
  }
}

enum _SortKey { rating, alphabetical, premium }

class _FilterSheet extends StatefulWidget {
  final _SortKey sortKey;
  final bool premiumOnly;
  final void Function(_SortKey, bool) onApply;

  const _FilterSheet({
    required this.sortKey,
    required this.premiumOnly,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late _SortKey _sortKey = widget.sortKey;
  late bool _premiumOnly = widget.premiumOnly;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        20,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Sort & filter',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Sort by',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: onSurface.withValues(alpha: 0.6),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _SortKey.values
                .map((k) => ChoiceChip(
                      label: Text(_labelFor(k)),
                      selected: _sortKey == k,
                      onSelected: (_) => setState(() => _sortKey = k),
                    ))
                .toList(),
          ),
          const SizedBox(height: 16),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _premiumOnly,
            onChanged: (v) => setState(() => _premiumOnly = v),
            title: Text(
              'Premium only',
              style: TextStyle(color: onSurface),
            ),
            subtitle: Text(
              'Show only places marked as premium',
              style: TextStyle(color: onSurface.withValues(alpha: 0.6), fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _sortKey = _SortKey.rating;
                      _premiumOnly = false;
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Reset'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    widget.onApply(_sortKey, _premiumOnly);
                    Navigator.of(context).pop();
                  },
                  style: FilledButton.styleFrom(
                    backgroundColor: KurdishHeritageColors.zer,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _labelFor(_SortKey k) {
    switch (k) {
      case _SortKey.rating:
        return 'Top rated';
      case _SortKey.alphabetical:
        return 'A → Z';
      case _SortKey.premium:
        return 'Premium first';
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
