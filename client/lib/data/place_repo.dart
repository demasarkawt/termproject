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

  // ─── Real images available in assets/images/ ───────────────────────────
  // ─── HD Unsplash images (500 KB – 1 MB each) ─────────────────────
  static const _hdMountains  = 'assets/images/hd_mountains.jpg';   // mountain peaks
  static const _hdWaterfall  = 'assets/images/hd_waterfall.jpg';   // waterfall
  static const _hdMosque     = 'assets/images/hd_mosque.jpg';      // mosque
  static const _hdBazaar     = 'assets/images/hd_bazaar.jpg';      // bazaar/market
  static const _hdLake       = 'assets/images/hd_lake.jpg';        // lake
  static const _hdValley     = 'assets/images/hd_valley.jpg';      // green valley
  static const _hdCanyon     = 'assets/images/hd_canyon.jpg';      // canyon gorge
  static const _hdVillage    = 'assets/images/hd_village.jpg';     // mountain village
  static const _hdRuins      = 'assets/images/hd_ruins.jpg';       // ancient ruins
  static const _hdPark       = 'assets/images/hd_park.jpg';        // park / nature

  // ─── Place-specific images (AI-generated + Wikimedia) ────────────
  static const _imgErbil       = 'assets/images/erbil.jpg';
  static const _imgCitadel     = 'assets/images/place_citadel.png';
  static const _imgBazaar      = 'assets/images/place_bazaar.png';
  static const _imgBekhal      = 'assets/images/place_bekhal.png';
  static const _imgShaqlawa    = 'assets/images/place_shaqlawa.png';
  static const _imgRawanduz    = 'assets/images/place_rawanduz.png';
  static const _imgMosque      = 'assets/images/place_mosque.png';
  static const _imgCha         = 'assets/images/cha.JPEG';
  static const _imgShanadar    = 'assets/images/shanadar.JPEG';
  static const _imgSulay       = 'assets/images/sulaymaniyah.jpg';
  static const _imgAmnaSuraka  = 'assets/images/place_amna_suraka.jpg';
  static const _imgDukanLake   = 'assets/images/place_dukan_lake.jpg';
  static const _imgAhmedAwa    = 'assets/images/place_ahmed_awa.jpg';
  static const _imgSulaybazaar = 'assets/images/place_sulaymaniyah_bazaar.jpg';
  static const _imgDuhok       = 'assets/images/duhok.jpg';
  static const _imgAmedi       = 'assets/images/place_amedi.jpg';
  static const _imgDuhokDam    = 'assets/images/place_duhok_dam.jpg';
  static const _imgLalish      = 'assets/images/place_lalish.jpg';
  static const _imgGaliAliBeg  = 'assets/images/place_gali_ali_beg.jpg';
  static const _imgHalabja     = 'assets/images/halabja.jpg';
  static const _imgHalabjaM    = 'assets/images/place_halabja_monument.jpg';
  static const _imgHawraman    = 'assets/images/place_hawraman.jpg';

  /// Per-place image overrides — HD first, then specific, then fallback
  static const Map<String, String> _imageByTitle = {
    // Erbil – historical
    'Citadel of Erbil'                             : _imgCitadel,
    'Qaysari Bazaar'                               : _hdBazaar,
    'Mudhafaria Minaret'                           : _hdRuins,
    'Erbil Textile Museum (Kurdish Textile Museum)': _imgCitadel,
    'Syriac Heritage Museum (Ankawa)'              : _hdRuins,
    // Erbil – nature
    'Sami Abdulrahman Park'                        : _hdPark,
    'Shaqlawa Mountain Town'                       : _hdVillage,
    'Rawanduz Canyon Viewpoints'                   : _hdCanyon,
    'Gali Ali Beg Gorge Viewpoints'                : _hdCanyon,
    'Bekhal Valley Viewpoints'                     : _hdValley,
    // Erbil – waterfalls
    'Bekhal Waterfall'                             : _hdWaterfall,
    'Gali Ali Beg Water Area'                      : _hdWaterfall,
    'Jundiyan Waterfall'                           : _hdWaterfall,
    'Zenta Waterfall'                              : _hdWaterfall,
    // Erbil – religious
    'Jalil Khayat Mosque'                          : _hdMosque,
    'Chaldean Catholic Church (Ankawa)'            : _hdMosque,
    'Mar Elia Church (Ankawa area)'                : _hdMosque,
    // Erbil – activities
    'Erbil cafes & night walk (100m Street)'       : _imgCha,
    'Family Mall & entertainment'                  : _imgErbil,
    'Shaqlawa weekend picnic'                      : _hdMountains,
    'Rawanduz scenic road trip'                    : _hdCanyon,
    // Sulaymaniyah – historical
    'Amna Suraka (Red Prison)'                     : _imgAmnaSuraka,
    'Slemani Museum'                               : _hdRuins,
    'Sulaimaniyah Bazaar (Old Market)'             : _hdBazaar,
    // Sulaymaniyah – nature
    'Azmar Mountain Viewpoint'                     : _hdMountains,
    'Dukan Lake'                                   : _hdLake,
    'Dukan Dam area'                               : _hdLake,
    'Chavi Land (viewpoint & park)'                : _hdPark,
    // Sulaymaniyah – waterfalls
    'Ahmed Awa Waterfall'                          : _hdWaterfall,
    'Tawela (near Ahmed Awa) springs'              : _hdValley,
    // Sulaymaniyah – religious
    'Grand Mosque of Sulaymaniyah'                 : _hdMosque,
    // Sulaymaniyah – activities
    'Chavi Land amusement area'                    : _hdPark,
    'Dukan boating / lakeside day'                 : _hdLake,
    'Azmar sunset hike'                            : _hdMountains,
    // Duhok – historical
    'Amedi (Amediye) old town'                     : _imgAmedi,
    'Duhok Bazaar (Old Market)'                    : _hdBazaar,
    // Duhok – nature
    'Duhok Dam'                                    : _hdLake,
    'Gara Mountain viewpoints'                     : _hdMountains,
    'Zakho Riverside (Khabur River)'               : _hdValley,
    // Duhok – waterfalls
    'Gali Sheran Waterfall'                        : _hdWaterfall,
    'Sipa Waterfall'                               : _hdWaterfall,
    // Duhok – religious
    'Lalish (Yazidi Holy Temple)'                  : _imgLalish,
    // Duhok – activities
    'Amedi day trip'                               : _hdVillage,
    'Duhok Dam picnic'                             : _hdLake,
    'Zakho day trip'                               : _hdValley,
    // Halabja – historical
    'Halabja Monument & Memorial'                  : _imgHalabjaM,
    // Halabja – nature
    'Hawraman (Kurdish mountain villages)'         : _hdVillage,
    'Byara (nature & village views)'               : _hdValley,
    // Halabja – waterfalls
    'Ahmed Awa Waterfall (Halabja route)'          : _hdWaterfall,
    'Tawela springs (Halabja route)'               : _hdValley,
    // Halabja – religious
    'Local mosques & heritage sites (Halabja)'     : _hdMosque,
    // Halabja – activities
    'Hawraman scenic drive'                        : _hdMountains,
    'Picnic day in Byara'                          : _hdValley,
  };

  /// Returns the best cover image for a given title/city/category.
  static String _asset(String cityId, String categoryId, int idx, int photo) {
    return _coverFor(cityId, categoryId);
  }

  static String _coverFor(String cityId, String categoryId) {
    switch (cityId) {
      case 'erbil':
        switch (categoryId) {
          case 'historical': return _imgCitadel;
          case 'nature':     return _imgShanadar;
          case 'waterfalls': return _imgBekhal;
          case 'religious':  return _imgMosque;
          case 'activities': return _imgCha;
          default:           return _imgErbil;
        }
      case 'sulaymaniyah': return _imgSulay;
      case 'duhok':        return _imgDuhok;
      case 'halabja':      return _imgHalabja;
      default:             return _imgErbil;
    }
  }

  /// Returns 4 varied gallery images for a place.
  static List<String> _gallery(String cityId, String categoryId, int idx, {String? title}) {
    final cover = title != null && _imageByTitle.containsKey(title)
        ? _imageByTitle[title]!
        : _coverFor(cityId, categoryId);
    // Rich gallery pool including all HD images
    final pool = [
      _hdMountains, _hdWaterfall, _hdMosque, _hdBazaar,
      _hdLake, _hdValley, _hdCanyon, _hdVillage, _hdRuins, _hdPark,
      _imgCitadel, _imgBekhal, _imgShaqlawa, _imgAhmedAwa,
      _imgAmedi, _imgDuhokDam, _imgLalish, _imgHalabjaM, _imgHawraman,
    ];
    final others = pool.where((img) => img != cover).toList();
    return [
      cover,
      others[(idx) % others.length],
      others[(idx + 1) % others.length],
      others[(idx + 2) % others.length],
    ];
  }

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
    final cover = _imageByTitle[title] ?? _asset(cityId, categoryId, idx, 1);
    final images = _gallery(cityId, categoryId, idx, title: title);

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
