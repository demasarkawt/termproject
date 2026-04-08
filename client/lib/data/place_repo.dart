// lib/data/place_repo.dart
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
  static PlaceData get(String id) =>
      _places.firstWhere((p) => p.id == id, orElse: () => _places.first);

  static List<PlaceData> list({required String cityId, required String categoryId}) {
    return _places
        .where((p) => p.cityId == cityId && p.categoryId == categoryId)
        .toList(growable: false);
  }

  // -------------------- Cities & Categories --------------------
  static const cities = ['erbil', 'sulaymaniyah', 'duhok', 'halabja'];
  static const categories = ['historical', 'nature', 'waterfalls', 'religious', 'activities'];

  // City anchors (approx city centers) used to generate reasonable coordinates near the city
  static const _anchors = {
    'erbil': (36.1911, 44.0092),
    'sulaymaniyah': (35.5656, 45.4329),
    'duhok': (36.8620, 42.9950),
    'halabja': (35.1770, 45.9860),
  };

  // small offset to avoid every place having the same lat/lng
  static double _off(int i) => (i % 5) * 0.01 - 0.02;

  static String _asset(String cityId, String categoryId, int idx, int photo) {
    final n = idx.toString().padLeft(2, '0');
    return 'assets/images/$cityId/${categoryId}_${n}_$photo.jpg';
  }

  static List<String> _gallery(String cityId, String categoryId, int idx) => [
    _asset(cityId, categoryId, idx, 1),
    _asset(cityId, categoryId, idx, 2),
    _asset(cityId, categoryId, idx, 3),
    _asset(cityId, categoryId, idx, 4),
  ];

  static String _cityLabel(String cityId) {
    switch (cityId) {
      case 'erbil':
        return 'Erbil';
      case 'sulaymaniyah':
        return 'Sulaymaniyah';
      case 'duhok':
        return 'Duhok';
      case 'halabja':
        return 'Halabja';
      default:
        return 'City';
    }
  }

  static String _catLabel(String cat) {
    switch (cat) {
      case 'historical':
        return 'Historical';
      case 'nature':
        return 'Nature';
      case 'waterfalls':
        return 'Waterfalls';
      case 'religious':
        return 'Religious';
      case 'activities':
        return 'Activities';
      default:
        return 'Places';
    }
  }

  static List<String> _highlightsFor(String cat) {
    switch (cat) {
      case 'historical':
        return const ['Heritage', 'Architecture', 'Local culture'];
      case 'nature':
        return const ['Fresh air', 'Views', 'Relaxing'];
      case 'waterfalls':
        return const ['Water views', 'Picnic spot', 'Scenic photos'];
      case 'religious':
        return const ['Peaceful', 'Respectful visit', 'Architecture'];
      case 'activities':
        return const ['Fun day', 'Friends & family', 'Memories'];
      default:
        return const ['Recommended', 'Easy access', 'Photo spot'];
    }
  }

  // ✅ Real descriptions for the most famous places
  static const Map<String, String> aboutByTitle = {
    // Erbil
    'Citadel of Erbil':
    'Erbil’s iconic ancient citadel and one of the oldest continuously inhabited settlements. Great views, history, and a perfect start to exploring the old city.',
    'Qaysari Bazaar':
    'A traditional covered bazaar near the Citadel. Ideal for shopping, local atmosphere, and seeing everyday city life.',
    'Mudhafaria Minaret':
    'A historic minaret and one of Erbil’s best-known heritage landmarks. A quick cultural stop and a great photo spot.',
    'Erbil Textile Museum (Kurdish Textile Museum)':
    'A small but impressive museum inside the Citadel showcasing Kurdish textiles, clothing, and cultural heritage.',
    'Syriac Heritage Museum (Ankawa)':
    'A museum in Ankawa focusing on Syriac heritage, history, and culture. A respectful and educational visit.',

    'Sami Abdulrahman Park':
    'A large and popular park for walking, relaxing, and sunsets. Great for families and a calm break from the city.',

    'Bekhal Waterfall':
    'One of the region’s most famous waterfall picnic spots, best enjoyed in spring and early summer when the water is strong and the weather is cool.',
    'Gali Ali Beg Water Area':
    'A scenic gorge stop with water flow and dramatic mountain views. Very popular for photos and road trips.',
    'Jundiyan Waterfall':
    'A beautiful waterfall spot surrounded by mountain scenery. Perfect for a short nature break and pictures.',
    'Zenta Waterfall':
    'A seasonal waterfall area known for fresh air and quiet views, especially enjoyable after rainy seasons.',

    'Jalil Khayat Mosque':
    'A landmark mosque in Erbil with impressive architecture and a peaceful atmosphere. Please visit respectfully.',

    // Sulaymaniyah
    'Amna Suraka (Red Prison)':
    'A powerful museum documenting modern Kurdish history. A meaningful visit to understand the region’s past.',
    'Slemani Museum':
    'A museum with a mix of archaeology and local history. A good stop for learning and exploring indoor culture.',
    'Sulaimaniyah Bazaar (Old Market)':
    'A lively old market area where you can shop, taste local snacks, and experience the city’s daily rhythm.',
    'Azmar Mountain Viewpoint':
    'A popular viewpoint overlooking Sulaymaniyah. Great for fresh air and sunset photos.',
    'Dukan Lake':
    'A large lake destination for relaxing views, picnics, and a full day out of the city.',
    'Dukan Dam area':
    'A scenic area near Dukan for views and a calm lakeside atmosphere.',
    'Chavi Land (viewpoint & park)':
    'A modern viewpoint and entertainment area with city views and family-friendly activities.',
    'Ahmed Awa Waterfall':
    'One of the most famous natural attractions near Halabja/Sulaymaniyah. Great in spring with strong water flow.',
    'Tawela (near Ahmed Awa) springs':
    'A refreshing springs area near Ahmed Awa with beautiful mountain scenery.',

    // Duhok
    'Duhok Dam':
    'A relaxing lakeside destination near Duhok, popular for picnics, views, and calm evening drives.',
    'Amedi (Amediye) old town':
    'A historic mountain town with dramatic views and old streets—one of the most famous trips in the Duhok region.',
    'Gali Sheran Waterfall':
    'A scenic waterfall area in the Duhok region, popular during spring for picnics and photos.',
    'Sipa Waterfall':
    'A well-known waterfall spot in the region, best visited in spring for cool air and strong flow.',
    'Lalish (Yazidi Holy Temple)':
    'A sacred site for the Yazidi community. Visit respectfully, dress modestly, and follow local guidance.',

    // Halabja
    'Halabja Monument & Memorial':
    'A memorial and museum honoring the victims of the Halabja tragedy. A respectful, important place to learn and remember.',
    'Hawraman (Kurdish mountain villages)':
    'A beautiful mountainous area known for dramatic landscapes and traditional village scenery.',
    'Byara (nature & village views)':
    'A scenic village area with green views and mountain air, popular for peaceful day trips.',
  };

  // ✅ REAL TITLES ONLY (any count is OK)
  static const _titles = {
    'erbil': {
      'historical': [
        'Citadel of Erbil',
        'Qaysari Bazaar',
        'Mudhafaria Minaret',
        'Erbil Textile Museum (Kurdish Textile Museum)',
        'Syriac Heritage Museum (Ankawa)',
      ],
      'nature': [
        'Sami Abdulrahman Park',
        'Shaqlawa Mountain Town',
        'Rawanduz Canyon Viewpoints',
        'Gali Ali Beg Gorge Viewpoints',
        'Bekhal Valley Viewpoints',
      ],
      'waterfalls': [
        'Bekhal Waterfall',
        'Gali Ali Beg Water Area',
        'Jundiyan Waterfall',
        'Zenta Waterfall',
      ],
      'religious': [
        'Jalil Khayat Mosque',
        'Chaldean Catholic Church (Ankawa)',
        'Mar Elia Church (Ankawa area)',
      ],
      'activities': [
        'Erbil cafes & night walk (100m Street)',
        'Family Mall & entertainment',
        'Shaqlawa weekend picnic',
        'Rawanduz scenic road trip',
      ],
    },

    'sulaymaniyah': {
      'historical': [
        'Amna Suraka (Red Prison)',
        'Slemani Museum',
        'Sulaimaniyah Bazaar (Old Market)',
      ],
      'nature': [
        'Azmar Mountain Viewpoint',
        'Dukan Lake',
        'Dukan Dam area',
        'Chavi Land (viewpoint & park)',
      ],
      'waterfalls': [
        'Ahmed Awa Waterfall',
        'Tawela (near Ahmed Awa) springs',
      ],
      'religious': [
        'Grand Mosque of Sulaymaniyah',
      ],
      'activities': [
        'Chavi Land amusement area',
        'Dukan boating / lakeside day',
        'Azmar sunset hike',
      ],
    },

    'duhok': {
      'historical': [
        'Amedi (Amediye) old town',
        'Duhok Bazaar (Old Market)',
      ],
      'nature': [
        'Duhok Dam',
        'Gara Mountain viewpoints',
        'Zakho Riverside (Khabur River)',
      ],
      'waterfalls': [
        'Gali Sheran Waterfall',
        'Sipa Waterfall',
      ],
      'religious': [
        'Lalish (Yazidi Holy Temple)',
      ],
      'activities': [
        'Amedi day trip',
        'Duhok Dam picnic',
        'Zakho day trip',
      ],
    },

    'halabja': {
      'historical': [
        'Halabja Monument & Memorial',
      ],
      'nature': [
        'Hawraman (Kurdish mountain villages)',
        'Byara (nature & village views)',
      ],
      'waterfalls': [
        'Ahmed Awa Waterfall (Halabja route)',
        'Tawela springs (Halabja route)',
      ],
      'religious': [
        'Local mosques & heritage sites (Halabja)',
      ],
      'activities': [
        'Hawraman scenic drive',
        'Picnic day in Byara',
      ],
    },
  };

  static List<String> _getTitles(String cityId, String categoryId) {
    final city = _titles[cityId];
    final list = city?[categoryId];
    return (list ?? const <String>[]).toList(growable: false);
  }

  static PlaceData _p({
    required String id,
    required String cityId,
    required String categoryId,
    required String title,
    required String locationText,
    required int idx,
    required double lat,
    required double lng,
    int stars = 5,
    double rating = 4.6,
    String price = 'Free / Varies',
    String duration = '1–3 hours',
    String hours = 'Daytime',
    String altitude = '—',
    String phone = '+964 000 000 000',
  }) {
    final cover = _asset(cityId, categoryId, idx, 1);
    final images = _gallery(cityId, categoryId, idx);

    return PlaceData(
      id: id,
      cityId: cityId,
      categoryId: categoryId,
      title: title,
      locationText: locationText,
      coverImage: cover,
      images: images,
      stars: stars,
      rating: rating,
      price: price,
      duration: duration,
      hours: hours,
      altitude: altitude,
      about: aboutByTitle[title] ??
          'A recommended ${_catLabel(categoryId).toLowerCase()} place in ${_cityLabel(cityId)}. Great for a relaxed visit, photos, and discovering the local vibe.',
      highlights: _highlightsFor(categoryId),
      phone: phone,
      lat: lat,
      lng: lng,
    );
  }

  // -------------------- Build places ONLY from real title lists --------------------
  static final List<PlaceData> _places = (() {
    final out = <PlaceData>[];

    for (final cityId in cities) {
      final anchor = _anchors[cityId]!;
      final baseLat = anchor.$1;
      final baseLng = anchor.$2;

      for (final categoryId in categories) {
        final titles = _getTitles(cityId, categoryId);
        if (titles.isEmpty) continue;

        for (var i = 0; i < titles.length; i++) {
          final idx = i + 1;

          final idPrefix =
          categoryId == 'historical'
              ? 'h'
              : categoryId == 'nature'
              ? 'n'
              : categoryId == 'waterfalls'
              ? 'w'
              : categoryId == 'religious'
              ? 'r'
              : 'a';

          final placeId = '${cityId}_${idPrefix}_${idx.toString().padLeft(2, '0')}';

          final rating = 4.5 + (i % 5) * 0.1;
          final stars = rating >= 4.8 ? 5 : 4;

          final price = categoryId == 'activities' ? 'Paid / Varies' : 'Free / Varies';
          final duration = categoryId == 'activities' ? '1–4 hours' : '1–3 hours';
          final hours = categoryId == 'religious' ? 'Daily' : 'Daytime';

          out.add(
            _p(
              id: placeId,
              cityId: cityId,
              categoryId: categoryId,
              title: titles[i],
              locationText: _cityLabel(cityId),
              idx: idx,
              lat: baseLat + _off(idx) + (categoryId.hashCode % 7) * 0.001,
              lng: baseLng + _off(16 - idx) + (categoryId.hashCode % 5) * 0.001,
              rating: double.parse(rating.toStringAsFixed(1)),
              stars: stars,
              price: price,
              duration: duration,
              hours: hours,
            ),
          );
        }
      }
    }

    out.sort((a, b) => a.id.compareTo(b.id));
    return out;
  })();
}
