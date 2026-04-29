import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../../data/place_repo.dart';
import '../../services/theme_service.dart';

class MapTabScreen extends StatefulWidget {
  const MapTabScreen({super.key});

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  final MapController _mapCtrl = MapController();
  final TextEditingController _searchCtrl = TextEditingController();
  List<PlaceData> _filteredPlaces = [];

  static const LatLng _defaultCenter = LatLng(36.1911, 44.0092);

  @override
  void initState() {
    super.initState();
    _filteredPlaces = PlaceRepo.all;
    _searchCtrl.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchCtrl.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredPlaces = PlaceRepo.all;
      } else {
        _filteredPlaces = PlaceRepo.all
            .where((p) => p.title.toLowerCase().contains(query) || p.locationText.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  void _focusDefault() {
    _mapCtrl.move(_defaultCenter, 13.5);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ FULL SCREEN MAP WITH ALL PLACES
          FlutterMap(
            mapController: _mapCtrl,
            options: const MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 12.0,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.termproject',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              MarkerLayer(
                markers: _filteredPlaces.map((p) {
                  return Marker(
                    point: LatLng(p.lat, p.lng),
                    width: 45,
                    height: 45,
                    child: GestureDetector(
                      onTap: () => _showPlaceInfo(p),
                      child: Container(
                        decoration: BoxDecoration(
                          color: KurdishHeritageColors.zer,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Icon(
                          _getCategoryIcon(p.categoryId),
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ✅ TOP-CENTER SEARCH
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88,
                  child: Row(
                    children: [
                      Expanded(
                        child: _Glass(
                          radius: 18,
                          blur: 16,
                          opacity: isDark ? 0.7 : 0.85,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Icon(Icons.search_rounded, color: isDark ? Colors.white70 : KurdishHeritageColors.res),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  textInputAction: TextInputAction.search,
                                  style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                                  decoration: InputDecoration(
                                    hintText: 'Discover places...',
                                    hintStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black45),
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                                ),
                              ),
                              if (_searchCtrl.text.isNotEmpty)
                                GestureDetector(
                                  onTap: () {
                                    _searchCtrl.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                  child: const Icon(Icons.close_rounded, color: Color(0xFF64748B)),
                                ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _GlassIconBtn(
                        icon: Icons.my_location_rounded,
                        onTap: _focusDefault,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'historical': return Icons.account_balance_rounded;
      case 'nature': return Icons.terrain_rounded;
      case 'waterfalls': return Icons.water_rounded;
      case 'religious': return Icons.church_rounded;
      case 'activities': return Icons.skateboarding_rounded;
      case 'food': return Icons.restaurant_rounded;
      default: return Icons.place_rounded;
    }
  }

  void _showPlaceInfo(PlaceData p) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, -5)),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(p.coverImage, width: 60, height: 60, fit: BoxFit.cover),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      Text(p.locationText, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_ios_rounded, color: KurdishHeritageColors.zer),
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/place/${p.id}');
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _infoBadge(Icons.star_rounded, p.rating.toString(), KurdishHeritageColors.zer),
                const SizedBox(width: 12),
                _infoBadge(Icons.access_time_rounded, p.duration, Colors.blue),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/place-map?title=${Uri.encodeComponent(p.title)}&lat=${p.lat}&lng=${p.lng}');
                  },
                  icon: const Icon(Icons.directions_rounded),
                  label: const Text('DIRECTIONS', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _GlassIconBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      blur: 16,
      opacity: isDark ? 0.7 : 0.85,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: isDark ? Colors.white : KurdishHeritageColors.zer),
        ),
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final double opacity;
  final EdgeInsets padding;

  const _Glass({
    required this.child,
    this.radius = 20,
    this.blur = 14,
    this.opacity = 0.80,
    this.padding = const EdgeInsets.all(12),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(opacity),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
            boxShadow: const [
              BoxShadow(
                blurRadius: 22,
                offset: Offset(0, 14),
                color: Color(0x22000000),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
