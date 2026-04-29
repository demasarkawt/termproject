// Bridge between the live FastAPI backend and the legacy offline `PlaceRepo`.
//
// At app startup `LiveData.refresh()` fetches all cities, places and events
// from the backend and converts them into `PlaceData` objects keyed by the
// numeric IDs. The existing screens keep using the synchronous `PlaceRepo`
// API; that repo first consults this cache, then falls back to the bundled
// seed data.

import 'package:flutter/foundation.dart';

import 'cities_repo.dart';
import 'events_repo.dart';
import 'models.dart';
import 'place_repo.dart';
import 'places_repo.dart';

class LiveData {
  static final ValueNotifier<int> version = ValueNotifier<int>(0);

  // Both keys refer to the same place: numeric id (e.g. "12") and the
  // `live-12` form used by adapters. Either lookup works.
  static final Map<String, PlaceData> _placesById = {};

  static List<ApiCity> cities = const [];
  static List<ApiPlace> places = const [];
  static List<ApiEvent> events = const [];

  static bool get hasData => _placesById.isNotEmpty;

  static String idFor(int apiId) => 'live-$apiId';

  static PlaceData? lookup(String id) {
    if (_placesById.containsKey(id)) return _placesById[id];
    final stripped = id.replaceFirst('live-', '');
    return _placesById[stripped];
  }

  static List<PlaceData> get all => _placesById.values.toList(growable: false);

  /// Resolve a logical Flutter city slug ('erbil', 'duhok', ...) or
  /// raw integer string to the live ApiCity row.
  static ApiCity? cityForSlug(String slug) {
    final normalized = _normalizeCityId(slug);
    for (final c in cities) {
      if (_normalizeCityId(c.name) == normalized) return c;
    }
    final asInt = int.tryParse(slug.replaceFirst('live-', ''));
    if (asInt != null) {
      for (final c in cities) {
        if (c.id == asInt) return c;
      }
    }
    return null;
  }

  static Future<void> refresh({Duration? timeout}) async {
    final cityRepo = CitiesRepo();
    final placeRepo = PlacesRepo();
    final eventRepo = EventsRepo();

    try {
      final results = await Future.wait([
        cityRepo.list(),
        placeRepo.list(limit: 500),
        eventRepo.list(),
      ]);
      cities = results[0] as List<ApiCity>;
      places = results[1] as List<ApiPlace>;
      events = results[2] as List<ApiEvent>;
      _rebuildPlacesIndex();
      version.value++;
    } catch (e) {
      // Silently fall back to the bundled seed data; the rest of the app
      // continues to work unchanged when the API is unreachable.
      debugPrint('LiveData refresh failed: $e');
    }
  }

  static void _rebuildPlacesIndex() {
    _placesById.clear();
    final cityById = {for (final c in cities) c.id: c};
    for (final p in places) {
      final city = cityById[p.cityId];
      final pd = _toPlaceData(p, city);
      _placesById[idFor(p.id)] = pd;
      _placesById['${p.id}'] = pd;
    }
  }

  static PlaceData _toPlaceData(ApiPlace p, ApiCity? city) {
    final cover = p.coverUrl ?? '';
    final imageUrls = p.images.map((i) => i.url).toList();
    final fallbackAssets =
        imageUrls.isEmpty ? <String>[_categoryFallback(p.category)] : <String>[];

    return PlaceData(
      id: idFor(p.id),
      cityId: _normalizeCityId(city?.name ?? ''),
      categoryId: _normalizeCategory(p.category),
      title: p.name,
      locationText: city?.name ?? '—',
      coverImage: cover.isNotEmpty ? cover : (fallbackAssets.first),
      images: imageUrls.isNotEmpty ? imageUrls : fallbackAssets,
      stars: ((p.rating ?? 0) >= 4.5)
          ? 5
          : ((p.rating ?? 0) >= 3.5)
              ? 4
              : 3,
      rating: p.rating ?? 0.0,
      price: p.isPremium ? '\$\$' : 'Free',
      duration: '—',
      hours: '—',
      altitude: '—',
      about: p.description ?? '',
      highlights: const [],
      phone: '',
      lat: p.latitude ?? 0.0,
      lng: p.longitude ?? 0.0,
    );
  }

  static String _normalizeCityId(String name) {
    final n = name.toLowerCase().trim();
    if (n.startsWith('erbil')) return 'erbil';
    if (n.startsWith('sulay') || n.startsWith('slemani')) return 'sulaymaniyah';
    if (n.startsWith('duhok') || n.startsWith('dohuk')) return 'duhok';
    if (n.startsWith('halab')) return 'halabja';
    return n.replaceAll(' ', '_');
  }

  static String _normalizeCategory(String? cat) {
    switch (cat) {
      case 'CULTURE':
        return 'historical';
      case 'NATURE':
        return 'nature';
      case 'ADVENTURE':
        return 'activities';
      case 'FOOD':
        return 'food';
      case 'MALL':
        return 'mall';
      default:
        return 'historical';
    }
  }

  static String _categoryFallback(String? category) {
    switch (category) {
      case 'NATURE':
        return 'assets/images/hd_mountains.jpg';
      case 'ADVENTURE':
        return 'assets/images/hd_canyon.jpg';
      case 'FOOD':
        return 'assets/images/hd_bazaar.jpg';
      case 'MALL':
        return 'assets/images/hd_park.jpg';
      case 'CULTURE':
      default:
        return 'assets/images/hd_ruins.jpg';
    }
  }
}
