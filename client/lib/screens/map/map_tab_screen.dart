import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapTabScreen extends StatefulWidget {
  const MapTabScreen({super.key});

  @override
  State<MapTabScreen> createState() => _MapTabScreenState();
}

class _MapTabScreenState extends State<MapTabScreen> {
  final MapController _mapCtrl = MapController();
  final TextEditingController _searchCtrl = TextEditingController();

  static const LatLng _defaultCenter = LatLng(36.1911, 44.0092);

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _focusDefault() {
    _mapCtrl.move(_defaultCenter, 13.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ FULL SCREEN MAP
          FlutterMap(
            mapController: _mapCtrl,
            options: const MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.5,
              interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.termproject',
              ),
              MarkerLayer(
                markers: const [
                  Marker(
                    point: _defaultCenter,
                    width: 56,
                    height: 56,
                    child: Icon(
                      Icons.location_pin,
                      size: 54,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ✅ TOP-CENTER SEARCH (fixed at top center)
          SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.88, // centered width
                  child: Row(
                    children: [
                      Expanded(
                        child: _Glass(
                          radius: 18,
                          blur: 16,
                          opacity: 0.80,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              const Icon(Icons.search_rounded, color: Color(0xFF0F766E)),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  textInputAction: TextInputAction.search,
                                  decoration: const InputDecoration(
                                    hintText: 'Search places…',
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
}

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconBtn({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 18,
      blur: 16,
      opacity: 0.80,
      padding: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: SizedBox(
          width: 46,
          height: 46,
          child: Icon(icon, color: const Color(0xFF0F766E)),
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
