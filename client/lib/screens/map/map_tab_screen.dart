import 'dart:io';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/map_travel_poi.dart';
import '../../data/map_travel_pois_seed.dart';
import '../../data/place_repo.dart';
import '../../models/map_spot_memory.dart';
import '../../services/map_spot_memory_store.dart';
import '../../services/osm_nearby_service.dart';
import '../../services/theme_service.dart';

/// Map filters — Google Maps–style layers for travel.
enum _MapFilter {
  all,
  memories,
  tours,
  eat,
  stay,
  gas;

  String get label {
    switch (this) {
      case _MapFilter.all:
        return 'All';
      case _MapFilter.memories:
        return 'My memories';
      case _MapFilter.tours:
        return 'Tours & sights';
      case _MapFilter.eat:
        return 'Eat';
      case _MapFilter.stay:
        return 'Hotels';
      case _MapFilter.gas:
        return 'Gas';
    }
  }
}

class _MapSearchHit {
  const _MapSearchHit({
    required this.title,
    required this.subtitle,
    required this.point,
    required this.badge,
  });

  final String title;
  final String subtitle;
  final LatLng point;

  /// Short label chip: Tour, Travel, Memory.
  final String badge;
}

class MapTabScreen extends StatefulWidget {
  const MapTabScreen({super.key});

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  final MapController _mapCtrl = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  _MapFilter _filter = _MapFilter.all;
  List<TravelPoi> _osmPois = [];
  bool _osmLoading = false;
  bool _locatingUser = false;

  /// Last known GPS fix for the blue “you are here” dot.
  LatLng? _userLocation;

  static const LatLng _defaultCenter = LatLng(36.1911, 44.0092);

  @override
  void initState() {
    super.initState();
    MapSpotMemoryStore.revision.addListener(_onMemoriesRevision);
    _searchCtrl.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      await _bootstrapLocation();
      if (mounted) await _loadOsmAroundView();
    });
  }

  void _onMemoriesRevision() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    MapSpotMemoryStore.revision.removeListener(_onMemoriesRevision);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOsmAroundView() async {
    setState(() => _osmLoading = true);
    const pad = 0.058;
    LatLng center = _defaultCenter;
    try {
      final c = _mapCtrl.camera.center;
      center = LatLng(c.latitude, c.longitude);
    } catch (_) {}

    final extra = await OsmNearbyService.fetchAmenities(
      south: center.latitude - pad,
      west: center.longitude - pad,
      north: center.latitude + pad,
      east: center.longitude + pad,
    );
    if (!mounted) return;
    setState(() {
      _osmPois = extra;
      _osmLoading = false;
    });
  }

  List<PlaceData> get _placesFiltered {
    final q = _searchCtrl.text.trim().toLowerCase();
    Iterable<PlaceData> list = PlaceRepo.all.where(_validPlaceCoord);

    if (q.isNotEmpty) {
      list = list.where(
        (p) =>
            p.title.toLowerCase().contains(q) ||
            p.locationText.toLowerCase().contains(q) ||
            p.about.toLowerCase().contains(q),
      );
    }

    switch (_filter) {
      case _MapFilter.all:
        break;
      case _MapFilter.memories:
        list = list.where((_) => false);
        break;
      case _MapFilter.tours:
        list = list.where(
          (p) => const {
            'historical',
            'nature',
            'waterfalls',
            'religious',
            'activities',
          }.contains(p.categoryId),
        );
        break;
      case _MapFilter.eat:
        list = list.where((p) => p.categoryId == 'food');
        break;
      case _MapFilter.stay:
      case _MapFilter.gas:
        list = list.where((_) => false);
        break;
    }

    return list.toList(growable: false);
  }

  List<TravelPoi> get _travelFiltered {
    final q = _searchCtrl.text.trim().toLowerCase();
    final seed = [...kMapTravelPoisSeed, ..._osmPois];

    Iterable<TravelPoi> list = seed;
    if (q.isNotEmpty) {
      list = list.where(
        (t) =>
            t.name.toLowerCase().contains(q) ||
            (t.address?.toLowerCase().contains(q) ?? false),
      );
    }

    switch (_filter) {
      case _MapFilter.all:
        break;
      case _MapFilter.memories:
        list = list.where((_) => false);
        break;
      case _MapFilter.tours:
        list = list.where((t) => t.kind == TravelPoiKind.sight);
        break;
      case _MapFilter.eat:
        list = list.where((t) => t.kind == TravelPoiKind.restaurant);
        break;
      case _MapFilter.stay:
        list = list.where((t) => t.kind == TravelPoiKind.hotel);
        break;
      case _MapFilter.gas:
        list = list.where((t) => t.kind == TravelPoiKind.fuel);
        break;
    }

    return list.toList(growable: false);
  }

  List<MapSpotMemory> get _memoriesFiltered {
    final q = _searchCtrl.text.trim().toLowerCase();
    Iterable<MapSpotMemory> list = MapSpotMemoryStore.items;
    if (q.isNotEmpty) {
      list = list.where(
        (m) =>
            m.title.toLowerCase().contains(q) ||
            m.description.toLowerCase().contains(q) ||
            m.thoughts.toLowerCase().contains(q),
      );
    }
    switch (_filter) {
      case _MapFilter.all:
      case _MapFilter.memories:
        break;
      default:
        list = list.where((_) => false);
        break;
    }
    return list.toList(growable: false);
  }

  bool _validPlaceCoord(PlaceData p) {
    if (p.lat == 0 && p.lng == 0) return false;
    return p.lat.abs() <= 90 && p.lng.abs() <= 180;
  }

  Future<void> _bootstrapLocation() async {
    try {
      final serviceOk = await Geolocator.isLocationServiceEnabled();
      if (!serviceOk) return;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      final pos = await Geolocator.getLastKnownPosition() ??
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.medium,
            timeLimit: const Duration(seconds: 18),
          );

      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _userLocation = ll);
      _mapCtrl.move(ll, 14);
    } catch (_) {}
  }

  Future<void> _focusMyLocation() async {
    if (_locatingUser) return;
    setState(() => _locatingUser = true);

    try {
      final serviceOk = await Geolocator.isLocationServiceEnabled();
      if (!serviceOk) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Turn on Location services to see where you are.')),
          );
        }
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }

      if (perm == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permission is needed to move the map to you.')),
          );
        }
        return;
      }

      if (perm == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Location is blocked. Enable it in system Settings for Travelo.'),
              action: SnackBarAction(
                label: 'Settings',
                onPressed: Geolocator.openAppSettings,
              ),
            ),
          );
        }
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 22),
      );

      final ll = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;
      setState(() => _userLocation = ll);
      _mapCtrl.move(ll, 15);
      await _loadOsmAroundView();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not get your location: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _locatingUser = false);
    }
  }

  void _flyMapTo(LatLng target, {double zoom = 15}) {
    _mapCtrl.move(target, zoom);
    _loadOsmAroundView();
  }

  void _submitSearch() {
    FocusScope.of(context).unfocus();
    final q = _searchCtrl.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a name or keyword to search the pins.')),
      );
      return;
    }

    final hits = <_MapSearchHit>[
      ..._placesFiltered.map(
        (p) => _MapSearchHit(
          title: p.title,
          subtitle: p.locationText,
          point: LatLng(p.lat, p.lng),
          badge: 'Tour',
        ),
      ),
      ..._travelFiltered.map(
        (t) => _MapSearchHit(
          title: t.name,
          subtitle: t.address ?? t.kind.label,
          point: t.point,
          badge: 'Travel',
        ),
      ),
      ..._memoriesFiltered.map(
        (m) => _MapSearchHit(
          title: m.title,
          subtitle: m.description.isNotEmpty ? m.description : 'My memory',
          point: LatLng(m.lat, m.lng),
          badge: 'Memory',
        ),
      ),
    ];

    if (hits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No pins match — try another word or change the filter chips.')),
      );
      return;
    }

    if (hits.length == 1) {
      final h = hits.single;
      _flyMapTo(h.point);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Showing “${h.title}”')),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _SearchHitsSheet(
        hits: hits,
        onPick: (h) {
          Navigator.of(ctx).pop();
          _flyMapTo(h.point);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Showing “${h.title}”')),
          );
        },
      ),
    );
  }

  Marker _markerUser(LatLng me) {
    return Marker(
      point: me,
      width: 26,
      height: 26,
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF1E88E5),
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.35), blurRadius: 8, offset: const Offset(0, 2)),
          ],
        ),
      ),
    );
  }

  Future<void> _openGoogleMaps(double lat, double lng) async {
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openCaptureHere() async {
    var lat = _defaultCenter.latitude;
    var lng = _defaultCenter.longitude;
    try {
      final cam = _mapCtrl.camera.center;
      lat = cam.latitude;
      lng = cam.longitude;
    } catch (_) {}
    if (!mounted) return;
    await context.push('/map-memory/new?lat=$lat&lng=$lng');
  }

  String _tileTemplate(bool isDark) {
    if (isDark) {
      return 'https://a.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png';
    }
    return 'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;
    final places = _placesFiltered;
    final travels = _travelFiltered;
    final memories = _memoriesFiltered;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapCtrl,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.4,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: _tileTemplate(isDark),
                userAgentPackageName: 'com.example.termproject',
                tileProvider: CancellableNetworkTileProvider(),
              ),
              MarkerLayer(
                markers: [
                  ...places.map(_markerPlace),
                  ...travels.map(_markerTravel),
                  ...memories.map(_markerMemory),
                  if (_userLocation != null) _markerUser(_userLocation!),
                ],
              ),
            ],
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_rounded,
                      size: 36,
                      color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.22),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: Text(
                        'Pan until the + sits on your spot,\nthen tap Memory below.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          height: 1.35,
                          color: (isDark ? Colors.white : KurdishHeritageColors.res).withValues(alpha: 0.42),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 80, 10, 0),
                  child: Row(
                    children: [
                      _RoundGlassBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        isDark: isDark,
                        onTap: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/home');
                          }
                        },
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SearchGlass(
                          controller: _searchCtrl,
                          isDark: isDark,
                          onSearch: _submitSearch,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _RoundGlassBtn(
                        icon: Icons.my_location_rounded,
                        isDark: isDark,
                        loading: _locatingUser,
                        onTap: _focusMyLocation,
                      ),
                      const SizedBox(width: 4),
                      _RoundGlassBtn(
                        icon: Icons.refresh_rounded,
                        isDark: isDark,
                        loading: _osmLoading,
                        onTap: _loadOsmAroundView,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: _MapFilter.values.map((f) {
                      final sel = _filter == f;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: sel,
                          showCheckmark: false,
                          label: Text(f.label),
                          selectedColor: KurdishHeritageColors.zer.withValues(alpha: 0.35),
                          labelStyle: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: sel
                                ? KurdishHeritageColors.res
                                : (isDark ? Colors.white70 : KurdishHeritageColors.res.withValues(alpha: 0.82)),
                          ),
                          onSelected: (_) => setState(() => _filter = f),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${places.length} tours · ${travels.length} travel · ${memories.length} memories${_osmPois.isNotEmpty ? ' (+${_osmPois.length} nearby)' : ''}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white54 : Colors.black54,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 8),
                  child: GestureDetector(
                    onTap: () => launchUrl(Uri.parse('https://www.openstreetmap.org/copyright')),
                    child: Text(
                      'Map data © OpenStreetMap contributors · Voyager tiles © CARTO',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark ? Colors.white54 : Colors.black.withValues(alpha: 0.45),
                        decoration: TextDecoration.underline,
                        decorationStyle: TextDecorationStyle.dotted,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 14,
            bottom: bottomInset + 120,
            child: FloatingActionButton.extended(
              heroTag: 'map_spot_memory_fab',
              elevation: 6,
              backgroundColor: KurdishHeritageColors.zer,
              foregroundColor: KurdishHeritageColors.res,
              onPressed: _openCaptureHere,
              icon: const Icon(Icons.add_a_photo_rounded),
              label: const Text('Memory', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.2)),
            ),
          ),
        ],
      ),
    );
  }

  Marker _markerPlace(PlaceData p) {
    return Marker(
      point: LatLng(p.lat, p.lng),
      width: 44,
      height: 44,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => _sheetPlace(p),
        child: _PinCircle(
          color: _colorForPlaceCategory(p.categoryId),
          icon: _iconForPlaceCategory(p.categoryId),
        ),
      ),
    );
  }

  Marker _markerTravel(TravelPoi t) {
    return Marker(
      point: t.point,
      width: 40,
      height: 40,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => _sheetTravel(t),
        child: _PinCircle(
          color: _travelColor(t.kind),
          icon: _travelIcon(t.kind),
          compact: true,
        ),
      ),
    );
  }

  Marker _markerMemory(MapSpotMemory m) {
    return Marker(
      point: LatLng(m.lat, m.lng),
      width: 50,
      height: 50,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => context.push('/map-memory/${m.id}'),
        child: _MemorySpotPin(memory: m),
      ),
    );
  }

  void _sheetPlace(PlaceData p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => _PlaceSheet(
        place: p,
        onDirections: () {
          Navigator.pop(ctx);
          context.go('/place-map?title=${Uri.encodeComponent(p.title)}&lat=${p.lat}&lng=${p.lng}');
        },
        onDetail: () {
          Navigator.pop(ctx);
          context.go('/place/${p.id}');
        },
        onOpenMaps: () => _openGoogleMaps(p.lat, p.lng),
      ),
    );
  }

  void _sheetTravel(TravelPoi t) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _TravelPoiSheet(
        poi: t,
        onOpenMaps: () => _openGoogleMaps(t.lat, t.lon),
      ),
    );
  }
}

Color _colorForPlaceCategory(String cat) {
  switch (cat) {
    case 'historical':
      return KurdishHeritageColors.zer;
    case 'nature':
      return KurdishHeritageColors.kesk;
    case 'waterfalls':
      return const Color(0xFF2C7A7B);
    case 'religious':
      return KurdishHeritageColors.sor;
    case 'activities':
      return const Color(0xFF6B46C1);
    case 'food':
      return const Color(0xFFC53030);
    case 'mall':
      return const Color(0xFFB83280);
    default:
      return KurdishHeritageColors.xweli;
  }
}

IconData _iconForPlaceCategory(String cat) {
  switch (cat) {
    case 'historical':
      return Icons.account_balance_rounded;
    case 'nature':
      return Icons.terrain_rounded;
    case 'waterfalls':
      return Icons.water_rounded;
    case 'religious':
      return Icons.mosque_rounded;
    case 'activities':
      return Icons.hiking_rounded;
    case 'food':
      return Icons.restaurant_rounded;
    case 'mall':
      return Icons.shopping_bag_rounded;
    default:
      return Icons.place_rounded;
  }
}

Color _travelColor(TravelPoiKind k) {
  switch (k) {
    case TravelPoiKind.hotel:
      return const Color(0xFF7C3AED);
    case TravelPoiKind.restaurant:
      return const Color(0xFFEA580C);
    case TravelPoiKind.fuel:
      return const Color(0xFF059669);
    case TravelPoiKind.sight:
      return KurdishHeritageColors.zer;
    case TravelPoiKind.shop:
      return const Color(0xFFDB2777);
    case TravelPoiKind.other:
      return KurdishHeritageColors.res;
  }
}

IconData _travelIcon(TravelPoiKind k) {
  switch (k) {
    case TravelPoiKind.hotel:
      return Icons.hotel_rounded;
    case TravelPoiKind.restaurant:
      return Icons.restaurant_rounded;
    case TravelPoiKind.fuel:
      return Icons.local_gas_station_rounded;
    case TravelPoiKind.sight:
      return Icons.photo_camera_rounded;
    case TravelPoiKind.shop:
      return Icons.storefront_rounded;
    case TravelPoiKind.other:
      return Icons.place_rounded;
  }
}

class _MemorySpotPin extends StatelessWidget {
  const _MemorySpotPin({required this.memory});

  final MapSpotMemory memory;

  @override
  Widget build(BuildContext context) {
    Widget inner;
    if (!kIsWeb && memory.imagePaths.isNotEmpty) {
      final f = File(memory.imagePaths.first);
      inner = ClipOval(
        child: f.existsSync()
            ? Image.file(f, width: 44, height: 44, fit: BoxFit.cover)
            : const SizedBox(
                width: 44,
                height: 44,
                child: ColoredBox(
                  color: KurdishHeritageColors.zer,
                  child: Icon(Icons.photo_camera_rounded, color: Colors.white, size: 22),
                ),
              ),
      );
    } else {
      inner = const SizedBox(
        width: 44,
        height: 44,
        child: ColoredBox(
          color: KurdishHeritageColors.zer,
          child: Icon(Icons.photo_camera_rounded, color: Colors.white, size: 22),
        ),
      );
    }

    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.34), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: inner,
    );
  }
}

class _PinCircle extends StatelessWidget {
  const _PinCircle({
    required this.color,
    required this.icon,
    this.compact = false,
  });

  final Color color;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final s = compact ? 36.0 : 42.0;
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.28), blurRadius: 8, offset: const Offset(0, 3)),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: compact ? 16 : 19),
    );
  }
}

class _SearchGlass extends StatelessWidget {
  const _SearchGlass({
    required this.controller,
    required this.isDark,
    required this.onSearch,
  });

  final TextEditingController controller;
  final bool isDark;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: BoxDecoration(
            color: isDark ? Colors.black.withValues(alpha: 0.52) : Colors.white.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: isDark ? 0.12 : 0.2)),
          ),
          child: Row(
            children: [
              IconButton(
                tooltip: 'Search map pins',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                onPressed: onSearch,
                icon: Icon(
                  Icons.search_rounded,
                  color: isDark ? Colors.white70 : KurdishHeritageColors.res.withValues(alpha: 0.65),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  style: TextStyle(
                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  onSubmitted: (_) => onSearch(),
                  decoration: InputDecoration(
                    hintText: 'Search sights, hotels, my memories…',
                    border: InputBorder.none,
                    isDense: true,
                    hintStyle: TextStyle(
                      color: isDark ? Colors.white38 : KurdishHeritageColors.textMutedLight,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoundGlassBtn extends StatelessWidget {
  const _RoundGlassBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
    this.loading = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Material(
          color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.92),
          child: InkWell(
            onTap: loading ? null : onTap,
            child: SizedBox(
              width: 46,
              height: 46,
              child: loading
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: KurdishHeritageColors.zer),
                    )
                  : Icon(icon, size: 20, color: isDark ? Colors.white : KurdishHeritageColors.zer),
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHitsSheet extends StatelessWidget {
  const _SearchHitsSheet({
    required this.hits,
    required this.onPick,
  });

  final List<_MapSearchHit> hits;
  final ValueChanged<_MapSearchHit> onPick;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.48,
      minChildSize: 0.28,
      maxChildSize: 0.92,
      builder: (ctx, scrollCtrl) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          child: Container(
            color: bg,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                  child: Row(
                    children: [
                      Icon(Icons.map_rounded, color: KurdishHeritageColors.zer),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${hits.length} matches',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 17,
                            color: isDark ? Colors.white : KurdishHeritageColors.res,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20, right: 20, bottom: 8 + bottom),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Tap a row to zoom the map',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    controller: scrollCtrl,
                    padding: EdgeInsets.only(left: 8, right: 8, bottom: 14 + bottom),
                    itemCount: hits.length,
                    separatorBuilder: (_, __) => Divider(height: 1, color: Colors.grey.withValues(alpha: 0.25)),
                    itemBuilder: (cx, i) {
                      final h = hits[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: KurdishHeritageColors.zer.withValues(alpha: 0.28),
                          foregroundColor: isDark ? Colors.white : KurdishHeritageColors.res,
                          child: Text(
                            h.badge.length >= 2 ? h.badge.substring(0, 2) : h.badge,
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                          ),
                        ),
                        title: Text(
                          h.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                        ),
                        subtitle: Text(
                          h.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                        ),
                        trailing: const Icon(Icons.north_east_rounded, size: 18),
                        onTap: () => onPick(h),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PlaceSheet extends StatelessWidget {
  const _PlaceSheet({
    required this.place,
    required this.onDirections,
    required this.onDetail,
    required this.onOpenMaps,
  });

  final PlaceData place;
  final VoidCallback onDirections;
  final VoidCallback onDetail;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final path = place.coverImage;

    Widget thumb;
    if (path.startsWith('http://') || path.startsWith('https://')) {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(imageUrl: path, width: 72, height: 72, fit: BoxFit.cover),
      );
    } else {
      thumb = ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          path,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            width: 72,
            height: 72,
            color: KurdishHeritageColors.surface3Light,
            child: const Icon(Icons.image_not_supported_outlined),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, -4))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              thumb,
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    const SizedBox(height: 4),
                    Text(place.locationText, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.arrow_forward_ios_rounded, color: KurdishHeritageColors.zer, size: 18),
                onPressed: onDetail,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onOpenMaps,
                icon: const Icon(Icons.map_outlined, size: 18),
                label: const Text('Open in Maps'),
              ),
              FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: KurdishHeritageColors.zer, foregroundColor: KurdishHeritageColors.res),
                onPressed: onDirections,
                icon: const Icon(Icons.directions_rounded),
                label: const Text('Directions'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TravelPoiSheet extends StatelessWidget {
  const _TravelPoiSheet({required this.poi, required this.onOpenMaps});

  final TravelPoi poi;
  final VoidCallback onOpenMaps;

  @override
  Widget build(BuildContext context) {
    final bg = Theme.of(context).scaffoldBackgroundColor;
    final c = _travelColor(poi.kind);
    final ic = _travelIcon(poi.kind);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: c.withValues(alpha: 0.15), shape: BoxShape.circle),
                child: Icon(ic, color: c, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(poi.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                    Text(
                      poi.kind.label.toUpperCase(),
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (poi.address != null) Text(poi.address!, style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            poi.source == 'osm' ? 'Live nearby · OpenStreetMap' : 'Curated pin · travel amenities',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: KurdishHeritageColors.zer,
                foregroundColor: KurdishHeritageColors.res,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: onOpenMaps,
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('Open in Google Maps', style: TextStyle(fontWeight: FontWeight.w800)),
            ),
          ),
        ],
      ),
    );
  }
}
