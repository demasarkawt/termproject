// lib/data/place_repo.dart
import 'live_data.dart';
import 'places_data.dart';

class PlaceData {
  final String id;
  final String cityId;       // erbil / sulaymaniyah / duhok / halabja
  final String categoryId;   // historical / nature / waterfalls / religious / activities

  final String title;
  final String locationText;

  final String coverImage;       // ✅ asset path
  final List<String> images;     // ✅ asset paths

  final int stars;
  final double rating;

  final String price;
  final String duration;
  final String hours;
  final String altitude;

  final String about;
  final List<String> highlights;
  final String phone;

  final double lat;
  final double lng;

  const PlaceData({
    required this.id,
    required this.cityId,
    required this.categoryId,
    required this.title,
    required this.locationText,
    required this.coverImage,
    required this.images,
    required this.stars,
    required this.rating,
    required this.price,
    required this.duration,
    required this.hours,
    required this.altitude,
    required this.about,
    required this.highlights,
    required this.phone,
    required this.lat,
    required this.lng,
  });
}

class PlaceRepo {
  /// When the FastAPI backend has been reached at least once, prefer the
  /// data from [LiveData]. Otherwise fall back to the bundled seed data so
  /// the app still renders without a network connection.
  static PlaceData get(String id) {
    final live = LiveData.lookup(id);
    if (live != null) return live;
    return _places.firstWhere((p) => p.id == id, orElse: () => _places.first);
  }

  static List<PlaceData> get all =>
      LiveData.hasData ? LiveData.all : _places;

  static List<PlaceData> list({required String cityId, required String categoryId}) {
    if (LiveData.hasData) {
      return LiveData.all
          .where((p) => p.cityId == cityId && p.categoryId == categoryId)
          .toList(growable: false);
    }
    return _places.where((p) {
      if (p.cityId != cityId) return false;
      
      // Normalize category comparison
      final target = categoryId.toLowerCase();
      final actual = p.categoryId.toLowerCase();
      
      if (target == actual) return true;
      
      // Special mappings for legacy or grouped categories
      if (target == 'waterfalls' && actual == 'nature') {
        return p.title.toLowerCase().contains('waterfall');
      }
      if (target == 'religious' && actual == 'religion') return true;
      if (target == 'religion' && actual == 'religious') return true;
      if (target == 'activities' && actual == 'activity') return true;
      if (target == 'activity' && actual == 'activities') return true;
      
      return false;
    }).toList(growable: false);
  }

  // -------------------- Cities & Categories --------------------
  static const cities = ['erbil', 'sulaymaniyah', 'duhok', 'halabja'];
  static const categories = ['historical', 'nature', 'waterfalls', 'religious', 'activities', 'food'];

  static String _cityLabel(String cityId) {
    switch (cityId) {
      case 'erbil': return 'Erbil';
      case 'sulaymaniyah': return 'Sulaymaniyah';
      case 'duhok': return 'Duhok';
      case 'halabja': return 'Halabja';
      default: return cityId;
    }
  }

  static List<String> highlightsFor(String cat) {
    switch (cat) {
      case 'historical': return const ['Heritage', 'Architecture', 'History'];
      case 'nature': return const ['Fresh air', 'Scenic views', 'Relaxing'];
      case 'waterfalls': return const ['Water cascades', 'Picnic spots', 'Cool breeze'];
      case 'religious':
      case 'religion': return const ['Peaceful', 'Architectural', 'Spiritual'];
      case 'activities':
      case 'activity': return const ['Family fun', 'Hiking', 'Adventure'];
      case 'food': return const ['Traditional', 'Local flavors', 'Famous'];
      default: return const ['Recommended', 'Easy access', 'Photo spot'];
    }
  }

  static final List<PlaceData> _places = kKurdistanPlaces.map((tp) {
    // Map religion to religious and activity to activities for compatibility
    String catId = tp.categoryId;
    if (catId == 'religion') catId = 'religious';
    if (catId == 'activity') catId = 'activities';

    return PlaceData(
      id: tp.id,
      cityId: tp.cityId,
      categoryId: catId,
      title: tp.title,
      locationText: _cityLabel(tp.cityId),
      coverImage: tp.image,
      images: [tp.image],
      stars: 5,
      rating: 4.8,
      price: tp.categoryId == 'activities' ? 'Paid / Varies' : 'Free / Varies',
      duration: '1–3 hours',
      hours: tp.categoryId == 'religious' ? 'Daily' : 'Daytime',
      altitude: '—',
      about: tp.about,
      highlights: highlightsFor(tp.categoryId),
      phone: '+964 000 000 000',
      lat: tp.lat ?? 36.1911,
      lng: tp.lng ?? 44.0092,
    );
  }).toList();
}
