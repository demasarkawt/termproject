import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import '../../services/theme_service.dart';



class PlaceMapScreen extends StatefulWidget {
  final String title;
  final double lat;
  final double lng;

  const PlaceMapScreen({
    super.key,
    required this.title,
    required this.lat,
    required this.lng,
  });

  @override
  State<PlaceMapScreen> createState() => _PlaceMapScreenState();
}

class _PlaceMapScreenState extends State<PlaceMapScreen> {
  final MapController _mapCtrl = MapController();

  LatLng get _dest => LatLng(widget.lat, widget.lng);

  StreamSubscription<Position>? _sub;

  LatLng? _me;
  double? _accuracyM;

  bool _loading = true;
  String? _error;

  bool _followMe = true;

  // REAL route
  List<LatLng> _route = [];
  double? _distanceKm; // from OSRM
  int? _etaMin;        // from OSRM

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _goToDest());
    _startLiveLocation();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  // -------------------------
  // LIVE LOCATION
  // -------------------------
  Future<void> _startLiveLocation() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _error = 'GPS is OFF. Enable Location services.';
          _loading = false;
        });
        return;
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();

      if (perm == LocationPermission.denied) {
        setState(() {
          _error = 'Location permission denied.';
          _loading = false;
        });
        return;
      }

      if (perm == LocationPermission.deniedForever) {
        setState(() {
          _error = 'Location permission denied forever.\nEnable it from Settings.';
          _loading = false;
        });
        return;
      }

      // quick last known
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) {
        _applyPosition(last, moveCamera: false);
      }

      // fresh fix
      final first = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.bestForNavigation,
        timeLimit: const Duration(seconds: 15),
      );
      await _applyPosition(first, moveCamera: true);

      // stream
      _sub?.cancel();
      _sub = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 10, // update every 10 meters
        ),
      ).listen((pos) async {
        if (pos.accuracy > 120) return;

        // If we moved enough, refresh route (avoid calling API too often)
        final old = _me;
        await _applyPosition(pos, moveCamera: _followMe, refreshRoute: old == null || _movedFar(old, pos));
      });

      if (mounted) setState(() => _loading = false);
    } catch (e) {
      setState(() {
        _error = 'Location error: $e';
        _loading = false;
      });
    }
  }

  bool _movedFar(LatLng oldMe, Position newPos) {
    final d = const Distance().as(
      LengthUnit.Meter,
      oldMe,
      LatLng(newPos.latitude, newPos.longitude),
    );
    return d > 40; // refresh route if moved > 40m
  }

  Future<void> _applyPosition(
      Position pos, {
        required bool moveCamera,
        bool refreshRoute = true,
      }) async {
    final me = LatLng(pos.latitude, pos.longitude);

    if (!mounted) return;
    setState(() {
      _me = me;
      _accuracyM = pos.accuracy;
    });

    if (moveCamera) {
      _mapCtrl.move(me, 16);
    }

    if (refreshRoute) {
      await _fetchRoadRoute(me, _dest);
    }
  }

  // -------------------------
  // REAL ROAD ROUTE (OSRM)
  // -------------------------
  Future<void> _fetchRoadRoute(LatLng from, LatLng to) async {
    try {
      // OSRM needs lng,lat order!
      final url = Uri.parse(
        'https://router.project-osrm.org/route/v1/driving/'
            '${from.longitude},${from.latitude};${to.longitude},${to.latitude}'
            '?overview=full&geometries=geojson&alternatives=false&steps=false',
      );

      final res = await http.get(url);
      if (res.statusCode != 200) {
        throw 'Routing failed (${res.statusCode})';
      }

      final data = jsonDecode(res.body);

      if (data['code'] != 'Ok') {
        throw 'Routing failed: ${data['code']}';
      }

      final routes = data['routes'] as List;
      if (routes.isEmpty) throw 'No route found';

      final r0 = routes.first;
      final distanceM = (r0['distance'] as num).toDouble();
      final durationS = (r0['duration'] as num).toDouble();

      final coords = (r0['geometry']['coordinates'] as List)
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      if (!mounted) return;
      setState(() {
        _route = coords;
        _distanceKm = distanceM / 1000.0;
        _etaMin = (durationS / 60.0).round().clamp(1, 999);
      });
    } catch (e) {
      // show clean error (don’t break map)
      if (!mounted) return;
      setState(() {
        _route = [];
        _distanceKm = null;
        _etaMin = null;
        _error = 'Direction error: $e';
      });
    }
  }

  // -------------------------
  // CAMERA
  // -------------------------
  void _goToDest() => _mapCtrl.move(_dest, 15);

  void _goToMe() {
    if (_me == null) return;
    setState(() => _followMe = true);
    _mapCtrl.move(_me!, 16);
  }

  void _showBoth() {
    if (_me == null) {
      _goToDest();
      return;
    }
    final me = _me!;
    final minLat = me.latitude < _dest.latitude ? me.latitude : _dest.latitude;
    final maxLat = me.latitude > _dest.latitude ? me.latitude : _dest.latitude;
    final minLng = me.longitude < _dest.longitude ? me.longitude : _dest.longitude;
    final maxLng = me.longitude > _dest.longitude ? me.longitude : _dest.longitude;

    final bounds = LatLngBounds(LatLng(minLat, minLng), LatLng(maxLat, maxLng));

    _mapCtrl.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(24, 140, 24, 220),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final canGoMe = _me != null;

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter: _dest,
                initialZoom: 14,
                interactionOptions: const InteractionOptions(flags: InteractiveFlag.all),
                onPointerDown: (_, __) {
                  if (_followMe) setState(() => _followMe = false);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.termproject',
                  tileProvider: CancellableNetworkTileProvider(),
                ),

                // ✅ CINEMATIC HERITAGE polyline (glow + main)
                if (_route.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      // Outer glow
                      Polyline(points: _route, strokeWidth: 14, color: KurdishHeritageColors.zer.withOpacity(0.2)),
                      Polyline(points: _route, strokeWidth: 8, color: KurdishHeritageColors.sor.withOpacity(0.4)),
                      // Main line
                      Polyline(points: _route, strokeWidth: 4, color: KurdishHeritageColors.sor),
                    ],
                  ),


                MarkerLayer(
                  markers: [
                    Marker(point: _dest, width: 62, height: 62, child: const _DestPin()),
                    if (_me != null) Marker(point: _me!, width: 70, height: 70, child: const _MeMarker()),
                  ],
                ),
              ],
            ),
          ),

          // TOP GLASS BAR
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
              child: Row(
                children: [
                  _GlassCircleBtn(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlassPill(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.place_rounded, size: 18, color: KurdishHeritageColors.sor),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  widget.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w900),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Decorative heritage line
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              for(int i=0; i<3; i++)
                                Container(
                                  width: 4,
                                  height: 4,
                                  margin: const EdgeInsets.symmetric(horizontal: 2),
                                  transform: Matrix4.rotationZ(0.785),
                                  decoration: BoxDecoration(
                                    color: KurdishHeritageColors.zer.withOpacity(0.5),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  _GlassCircleBtn(icon: Icons.center_focus_strong_rounded, onTap: _showBoth),
                ],
              ),
            ),
          ),

          // RIGHT FLOATS
          Positioned(
            right: 14,
            top: 110,
            child: Column(
              children: [
                _GlassCircleBtn(icon: Icons.my_location_rounded, onTap: canGoMe ? _goToMe : null),
                const SizedBox(height: 10),
                _GlassCircleBtn(
                  icon: _followMe ? Icons.gps_fixed_rounded : Icons.gps_not_fixed_rounded,
                  onTap: canGoMe ? () => setState(() => _followMe = !_followMe) : null,
                ),
              ],
            ),
          ),

          // BOTTOM SHEET
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                child: _GlassPill(
                  radius: 24,
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.directions_rounded, color: KurdishHeritageColors.sor),

                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _route.isEmpty
                                  ? 'Direction not ready'
                                  : 'Route Ready (Road)',
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15),
                            ),
                          ),
                          if (_distanceKm != null)
                            Text(
                              '${_distanceKm!.toStringAsFixed(1)} km',
                              style: const TextStyle(fontWeight: FontWeight.w900, color: KurdishHeritageColors.sor),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Text(
                            _etaMin == null ? 'ETA —' : 'ETA $_etaMin min',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: KurdishHeritageColors.res.withOpacity(0.75),
                            ),
                          ),
                          const Spacer(),
                          if (_accuracyM != null)
                            Text(
                              'GPS ${_accuracyM!.toStringAsFixed(0)}m',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: KurdishHeritageColors.res.withOpacity(0.55),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _PrimaryBtn(
                              icon: Icons.route_rounded,
                              text: 'Go to Road',
                              onTap: _showBoth,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SecondaryBtn(
                              icon: Icons.refresh_rounded,
                              text: 'Recalculate',
                              onTap: () async {
                                if (_me == null) return;
                                await _fetchRoadRoute(_me!, _dest);
                              },
                            ),
                          ),
                        ],
                      ),
                      if (_error != null) ...[
                        const SizedBox(height: 10),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),

          // LOADING overlay
          if (_loading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.10),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------- UI helpers ----------------

class _GlassPill extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsets padding;

  const _GlassPill({
    required this.child,
    this.radius = 18,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.78),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.28)),
            boxShadow: const [
              BoxShadow(blurRadius: 26, offset: Offset(0, 16), color: Color(0x22000000)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassCircleBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _GlassCircleBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: Colors.white.withOpacity(onTap == null ? 0.55 : 0.84),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 46,
              height: 46,
              child: Icon(icon, color: KurdishHeritageColors.sor),
            ),
          ),
        ),
      ),
    );
  }
}

class _PrimaryBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _PrimaryBtn({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: KurdishHeritageColors.sor,
          foregroundColor: Colors.white,
          shape: const StadiumBorder(),
          elevation: 10,
        ),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _SecondaryBtn extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SecondaryBtn({required this.icon, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: KurdishHeritageColors.res,
          side: BorderSide(color: KurdishHeritageColors.res.withOpacity(0.25)),
          shape: const StadiumBorder(),
          backgroundColor: Colors.white.withOpacity(0.28),
        ),
        icon: Icon(icon),
        label: Text(text, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class _DestPin extends StatelessWidget {
  const _DestPin();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Icon(Icons.location_pin, size: 56, color: KurdishHeritageColors.sor),
        Positioned(
          top: 14,
          child: Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: KurdishHeritageColors.zer, width: 2),
              boxShadow: const [
                BoxShadow(blurRadius: 10, offset: Offset(0, 6), color: Color(0x22000000)),
              ],
            ),
            child: const Icon(Icons.flag_rounded, size: 16, color: KurdishHeritageColors.zer),
          ),
        ),
      ],
    );
  }
}

class _MeMarker extends StatelessWidget {
  const _MeMarker();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: KurdishHeritageColors.zer.withOpacity(0.2),
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: KurdishHeritageColors.zer,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white, width: 3),
          ),
        ),
      ],
    );
  }
}
