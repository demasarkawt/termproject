import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/map_travel_poi.dart';

/// Live POIs from OpenStreetMap via the public Overpass API (same data many travel sites derive from).
/// Disabled on **web** by default (CORS); mobile/desktop native works.
class OsmNearbyService {
  OsmNearbyService._();

  static const _endpoint = 'https://overpass-api.de/api/interpreter';

  /// [south], [west], [north], [east] in WGS84 (bbox around map center).
  static Future<List<TravelPoi>> fetchAmenities({
    required double south,
    required double west,
    required double north,
    required double east,
    int maxNodes = 45,
  }) async {
    if (kIsWeb) return [];

    final q = '''
[out:json][timeout:25];
(
  node["amenity"="fuel"]($south,$west,$north,$east);
  node["amenity"="restaurant"]($south,$west,$north,$east);
  node["tourism"="hotel"]($south,$west,$north,$east);
);
out body;
''';

    try {
      final res = await http
          .post(Uri.parse(_endpoint), body: q)
          .timeout(const Duration(seconds: 12));
      if (res.statusCode != 200) return [];

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final elements = data['elements'] as List<dynamic>? ?? [];
      final out = <TravelPoi>[];

      for (final raw in elements) {
        final el = raw as Map<String, dynamic>;
        final id = el['id'];
        final lat = el['lat'];
        final lon = el['lon'];
        final tags = el['tags'] as Map<String, dynamic>? ?? {};
        if (id == null || lat == null || lon == null) continue;

        final name = tags['name'] ?? tags['brand'];
        if (name == null || name.toString().trim().isEmpty) continue;

        TravelPoiKind kind = TravelPoiKind.other;
        final amenity = tags['amenity']?.toString();
        final tourism = tags['tourism']?.toString();
        if (amenity == 'fuel') kind = TravelPoiKind.fuel;
        if (amenity == 'restaurant') kind = TravelPoiKind.restaurant;
        if (tourism == 'hotel') kind = TravelPoiKind.hotel;

        out.add(
          TravelPoi(
            id: 'osm-$id',
            name: name.toString(),
            kind: kind,
            lat: (lat as num).toDouble(),
            lon: (lon as num).toDouble(),
            address: tags['addr:street']?.toString(),
            source: 'osm',
          ),
        );
        if (out.length >= maxNodes) break;
      }

      return out;
    } catch (e) {
      debugPrint('OsmNearbyService: $e');
      return [];
    }
  }
}
