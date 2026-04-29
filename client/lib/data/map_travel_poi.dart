import 'package:latlong2/latlong.dart';

/// Travel-oriented map point — curated seed data + optional OSM enrichment.
/// Coordinates are aligned with publicly mapped streets (OpenStreetMap-style).
enum TravelPoiKind {
  sight,
  restaurant,
  hotel,
  fuel,
  shop,
  other;

  String get label {
    switch (this) {
      case TravelPoiKind.sight:
        return 'Sight';
      case TravelPoiKind.restaurant:
        return 'Restaurant';
      case TravelPoiKind.hotel:
        return 'Hotel';
      case TravelPoiKind.fuel:
        return 'Gas';
      case TravelPoiKind.shop:
        return 'Shop';
      case TravelPoiKind.other:
        return 'Place';
    }
  }
}

class TravelPoi {
  const TravelPoi({
    required this.id,
    required this.name,
    required this.kind,
    required this.lat,
    required this.lon,
    this.address,
    this.source = 'curated',
  });

  final String id;
  final String name;
  final TravelPoiKind kind;
  final double lat;
  final double lon;
  final String? address;

  /// `curated` | `osm`
  final String source;

  LatLng get point => LatLng(lat, lon);
}
