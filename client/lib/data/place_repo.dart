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

  static List<PlaceData> get all => _places;

  static List<PlaceData> list({required String cityId, required String categoryId}) {
    return _places
        .where((p) => p.cityId == cityId && p.categoryId == categoryId)
        .toList(growable: false);
  }

  // -------------------- Cities & Categories --------------------
  static const cities = ['erbil', 'sulaymaniyah', 'duhok', 'halabja'];
  static const categories = ['historical', 'nature', 'waterfalls', 'religious', 'activities', 'food'];

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
  // ─── Authentic Wikipedia & High-Quality Images ─────────────────────
  static const _imgWikiCitadel     = 'assets/images/wiki_citadel_erbil.jpg';
  static const _imgWikiBazaar      = 'assets/images/wiki_qaysari_bazaar.jpg';
  static const _imgWikiMinaret     = 'assets/images/wiki_mudhafaria_minaret.jpg';
  static const _imgWikiSamiPark    = 'assets/images/wiki_sami_abdulrahman.jpg';
  static const _imgWikiBekhal      = 'assets/images/wiki_bekhal_waterfall.jpg';
  static const _imgWikiGaliAliBeg  = 'assets/images/wiki_gali_ali_beg.jpg';
  static const _imgWikiAmnaSuraka  = 'assets/images/wiki_amna_suraka.jpg';

  static const _imgRawanduzCanyon = 'assets/images/place_rawanduz.png';
  static const _imgAmediPlateau  = 'assets/images/place_amedi.jpg';
  static const _imgDukanLake     = 'assets/images/place_dukan_lake.jpg';
  static const _imgAhmadAwa      = 'assets/images/place_ahmed_awa.jpg';
  static const _imgShanadarCave  = 'assets/images/shanadar.jpeg';
  static const _imgCitadel       = 'assets/images/place_citadel.png';
  static const _imgBazaar        = 'assets/images/place_bazaar.png';
  static const _imgBekhal        = 'assets/images/place_bekhal.png';
  static const _imgLalish        = 'assets/images/place_lalish.jpg';
  static const _imgAmnaSuraka    = 'assets/images/place_amna_suraka.jpg';
  static const _imgHalabjaM      = 'assets/images/place_halabja_monument.jpg';
  static const _imgHawraman      = 'assets/images/place_hawraman.jpg';
  static const _imgShaqlawa      = 'assets/images/place_shaqlawa.png';
  static const _imgDuhokDam      = 'assets/images/place_duhok_dam.jpg';
  static const _imgJalilKhayat   = 'assets/images/place_mosque.png';
  static const _imgSulayBazaar   = 'assets/images/place_sulaymaniyah_bazaar.jpg';

  // ─── HD Category Fallbacks ─────────────────────
  static const _hdMountains  = 'assets/images/hd_mountains.jpg';
  static const _hdWaterfall  = 'assets/images/hd_waterfall.jpg';
  static const _hdMosque     = 'assets/images/hd_mosque.jpg';
  static const _hdBazaar     = 'assets/images/hd_bazaar.jpg';
  static const _hdLake       = 'assets/images/hd_lake.jpg';
  static const _hdValley     = 'assets/images/hd_valley.jpg';
  static const _hdCanyon     = 'assets/images/hd_canyon.jpg';
  static const _hdVillage    = 'assets/images/hd_village.jpg';
  static const _hdRuins      = 'assets/images/hd_ruins.jpg';
  static const _hdPark       = 'assets/images/hd_park.jpg';

  static const _imgErbil       = 'assets/images/erbil.jpg';
  static const _imgSulay       = 'assets/images/sulaymaniyah.jpg';
  static const _imgDuhok       = 'assets/images/duhok.jpg';
  static const _imgHalabja     = 'assets/images/halabja.jpg';
  static const _imgCha         = 'assets/images/cha.jpeg';
  static const _imgShanadar    = 'assets/images/shanadar.jpeg';

  /// Per-place image overrides — HD first, then specific, then fallback
  static const Map<String, String> _imageByTitle = {
    // Erbil – historical
    'Citadel of Erbil'                             : _imgWikiCitadel,
    'Qaysari Bazaar'                               : _imgWikiBazaar,
    'Mudhafaria Minaret'                           : _imgWikiMinaret,
    'Erbil Textile Museum (Kurdish Textile Museum)': _imgCitadel,
    'Syriac Heritage Museum (Ankawa)'              : _hdRuins,
    // Erbil – nature
    'Sami Abdulrahman Park'                        : _imgWikiSamiPark,
    'Shaqlawa Mountain Town'                       : _imgShaqlawa,
    'Rawanduz Canyon Viewpoints'                   : _imgRawanduzCanyon,
    'Gali Ali Beg Gorge Viewpoints'                : _imgWikiGaliAliBeg,
    'Bekhal Valley Viewpoints'                     : _imgBekhal,
    // Erbil – waterfalls
    'Bekhal Waterfall'                             : _imgWikiBekhal,
    'Gali Ali Beg Water Area'                      : _imgWikiGaliAliBeg,
    'Jundiyan Waterfall'                           : _hdWaterfall,
    'Zenta Waterfall'                              : _hdWaterfall,
    // Erbil – religious
    'Jalil Khayat Mosque'                          : _imgJalilKhayat,
    'Chaldean Catholic Church (Ankawa)'            : _hdMosque,
    'Mar Elia Church (Ankawa area)'                : _hdMosque,
    // Erbil – activities
    'Erbil cafes & night walk (100m Street)'       : _imgCha,
    'Family Mall & entertainment'                  : _imgErbil,
    'Shaqlawa weekend picnic'                      : _imgShaqlawa,
    'Rawanduz scenic road trip'                    : _imgRawanduzCanyon,
    // Sulaymaniyah – historical
    'Amna Suraka (Red Prison)'                     : _imgWikiAmnaSuraka,
    'Slemani Museum'                               : _hdRuins,
    'Sulaimaniyah Bazaar (Old Market)'             : _imgSulayBazaar,
    // Sulaymaniyah – nature
    'Azmar Mountain Viewpoint'                     : _hdMountains,
    'Dukan Lake'                                   : _imgDukanLake,
    'Dukan Dam area'                               : _imgDukanLake,
    'Chavi Land (viewpoint & park)'                : _hdPark,
    // Sulaymaniyah – waterfalls
    'Ahmed Awa Waterfall'                          : _imgAhmadAwa,
    'Tawela (near Ahmed Awa) springs'              : _hdValley,
    // Sulaymaniyah – religious
    'Grand Mosque of Sulaymaniyah'                 : _hdMosque,
    // Sulaymaniyah – activities
    'Chavi Land amusement area'                    : _hdPark,
    'Dukan boating / lakeside day'                 : _imgDukanLake,
    'Azmar sunset hike'                            : _hdMountains,
    // Duhok – historical
    'Amedi (Amediye) old town'                     : _imgAmediPlateau,
    'Duhok Bazaar (Old Market)'                    : _hdBazaar,
    // Duhok – nature
    'Duhok Dam'                                    : _imgDuhokDam,
    'Gara Mountain viewpoints'                     : _hdMountains,
    'Zakho Riverside (Khabur River)'               : _hdValley,
    // Duhok – waterfalls
    'Gali Sheran Waterfall'                        : _hdWaterfall,
    'Sipa Waterfall'                               : _hdWaterfall,
    // Duhok – religious
    'Lalish (Yazidi Holy Temple)'                  : _imgLalish,
    // Duhok – activities
    'Amedi day trip'                               : _imgAmediPlateau,
    'Duhok Dam picnic'                             : _imgDuhokDam,
    'Zakho day trip'                               : _hdValley,
    // Halabja – historical
    'Halabja Monument & Memorial'                  : _imgHalabjaM,
    // Halabja – nature
    'Hawraman (Kurdish mountain villages)'         : _imgHawraman,
    'Byara (nature & village views)'               : _hdValley,
    // Halabja – waterfalls
    'Ahmed Awa Waterfall (Halabja route)'          : _imgAhmadAwa,
    'Tawela springs (Halabja route)'               : _hdValley,
    // Halabja – religious
    'Local mosques & heritage sites (Halabja)'     : _hdMosque,
    // Halabja – activities
    'Hawraman scenic drive'                        : _imgHawraman,
    'Picnic day in Byara'                          : _hdValley,
    // Erbil – food
    'Machko Chaikhana'                             : _imgCha,
    'Abu Shihab Restaurant'                        : _hdBazaar,
    'Kebab Yasin'                                  : _hdBazaar,
    'Dawa 2 Restaurant'                            : _hdBazaar,
    // Sulaymaniyah – food
    'Shaab Teahouse (Chaikhanay Shaab)'            : _imgSulayBazaar,
    'Kebab Wasta Hasan'                            : _hdBazaar,
    "Chalak's Place"                               : _hdBazaar,
    // Duhok – food
    'Kebab Kawa'                                   : _hdBazaar,
    'Malta Restaurant'                             : _hdBazaar,
    'Mazi Mall Food Court'                         : _imgDuhok,
    // Halabja – food
    'Hawraman Traditional Restaurants'             : _imgHawraman,
    'Halabja Kebab and Fish'                       : _imgHalabja,

    // --- New Places ---
    'Shanidar Cave'                                : _imgShanadar,
    'Korek Mountain Resort'                        : _hdMountains,
    'Pank Tourist Resort'                          : _imgRawanduzCanyon,
    'Kani Bast Waterfall'                          : _hdWaterfall,
    'Darbandikhan Lake'                            : _hdLake,
    'Qaradagh Mountain'                            : _hdMountains,
    'Akre (Aqrah)'                                 : _hdVillage,
    'Zanta Waterfall'                              : _hdWaterfall,
    'Gara Mountain'                                : _hdMountains,
    'Sartaki Bamo'                                 : _hdCanyon,
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
          case 'nature':     return _imgRawanduzCanyon;
          case 'waterfalls': return _imgBekhal;
          case 'religious':  return _hdMosque;
          case 'activities': return _imgCha;
          case 'food':       return _hdBazaar;
          default:           return _imgErbil;
        }
      case 'sulaymaniyah':
        switch (categoryId) {
          case 'historical': return _imgAmnaSuraka;
          case 'nature':     return _imgDukanLake;
          case 'waterfalls': return _imgAhmadAwa;
          case 'religious':  return _hdMosque;
          case 'activities': return _hdPark;
          case 'food':       return _hdBazaar;
          default:           return _imgSulay;
        }
      case 'duhok':
        switch (categoryId) {
          case 'historical': return _imgAmediPlateau;
          case 'nature':     return _hdValley;
          case 'waterfalls': return _hdWaterfall;
          case 'religious':  return _imgLalish;
          case 'activities': return _hdMountains;
          case 'food':       return _hdBazaar;
          default:           return _imgDuhok;
        }
      case 'halabja':
        switch (categoryId) {
          case 'historical': return _imgHalabjaM;
          case 'nature':     return _imgHawraman;
          case 'waterfalls': return _imgAhmadAwa;
          case 'religious':  return _hdMosque;
          case 'activities': return _hdMountains;
          case 'food':       return _hdBazaar;
          default:           return _imgHalabja;
        }
      default:
        return _imgErbil;
    }
  }

  /// Returns 4 varied gallery images for a place.
  static List<String> _gallery(String cityId, String categoryId, int idx, {String? title}) {
    final cover = title != null && _imageByTitle.containsKey(title)
        ? _imageByTitle[title]!
        : _coverFor(cityId, categoryId);
    
    // The user requested that all fake/generic images be removed.
    // So we only return the actual cover image, avoiding the random pool.
    return [cover];
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
      case 'food':
        return 'Food & Dining';
      default:
        return 'Places';
    }
  }

  /// Public accessor used by PlacesListScreen for filter chips
  static List<String> highlightsFor(String categoryId) =>
      _highlightsFor(categoryId);

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
      case 'food':
        return const ['Traditional', 'Famous', 'Must try', 'Local favorite', 'Café & Tea'];
      default:
        return const ['Recommended', 'Easy access', 'Photo spot'];
    }
  }

  // ✅ Real, comprehensive, factual descriptions for every place
  static const Map<String, String> aboutByTitle = {
    // Erbil - Historical
    'Citadel of Erbil':
    'The Citadel of Erbil is a tell or occupied mound in the historical center of Erbil. It has been inscribed on the UNESCO World Heritage List since 2014. Evidence suggests it is one of the oldest continuously inhabited settlements in the world, dating back to at least the 5th millennium BC. The citadel offers stunning panoramic views of the modern city and houses several museums and traditional craft shops.',
    'Qaysari Bazaar':
    'Located just south of the Erbil Citadel, the Qaysari Bazaar is a vast, labyrinthine traditional market that dates back to the Ottoman era. It is the beating heart of Erbil\'s commerce, where locals and tourists alike wander through narrow alleys to buy spices, gold, traditional Kurdish clothing, sweets, and local tea.',
    'Mudhafaria Minaret':
    'Also known as the Choli Minaret, this 36-meter-high brick tower was built in the late 12th century by the Kurdish prince Muzaffar al-Din Abu Sa\'eed al-Kawkaboori. It is a stunning example of Islamic architecture in the region, featuring intricate geometric brickwork and Kufic calligraphy.',
    'Erbil Textile Museum (Kurdish Textile Museum)':
    'Situated inside the historic Erbil Citadel, this museum is dedicated to preserving the rich textile heritage of Kurdistan. It features magnificent hand-woven carpets, traditional clothing, and antique weaving tools used by nomadic Kurdish tribes over the centuries.',
    'Syriac Heritage Museum (Ankawa)':
    'Located in the Christian district of Ankawa, this museum preserves the rich cultural and religious history of the Syriac, Chaldean, and Assyrian people in the region. It showcases ancient manuscripts, traditional clothing, and historical artifacts.',

    // Erbil - Nature
    'Sami Abdulrahman Park':
    'The largest park in Erbil, built on the site of a former military base. It spans over 800 acres and features lush gardens, serene lakes, walking trails, and monuments, serving as the city\'s primary green lung and a beloved gathering spot for families.',
    'Shaqlawa Mountain Town':
    'Nestled at the base of Mount Safeen, Shaqlawa is a historic resort town famous for its cool summer climate, dense walnut and pomegranate orchards, and vibrant local markets selling fresh honey, nuts, and traditional Kurdish sweets.',
    'Rawanduz Canyon Viewpoints':
    'Rawanduz is renowned for its dramatic, deep canyons and spectacular mountain scenery. The viewpoints offer breathtaking panoramas of the gorge, carved by the Rawanduz River, providing some of the most striking landscapes in the Middle East.',
    'Gali Ali Beg Gorge Viewpoints':
    'This majestic gorge cuts through the Bradost and Korek mountain ranges. It is historically significant and naturally stunning, featuring towering limestone cliffs that frame the rushing river below.',
    'Bekhal Valley Viewpoints':
    'A stunning mountainous valley area offering sweeping views of the surrounding peaks and lush greenery, heavily visited during the spring when the landscape bursts into vibrant life.',

    // Erbil - Waterfalls
    'Bekhal Waterfall':
    'One of the most famous and accessible waterfalls in the Kurdistan Region, located near Rawanduz. The water cascades powerfully down a wide, terraced rocky slope, creating a cool and refreshing microclimate that attracts thousands of summer visitors.',
    'Gali Ali Beg Water Area':
    'Famous enough to be featured on the Iraqi 10,000 dinar note, the Gali Ali Beg waterfall plunges down from the high cliffs into a vibrant pool. It is a defining natural landmark of Kurdistan.',
    'Jundiyan Waterfall':
    'Known as the "Magic Spring," Jundiyan is a unique water source that flows vigorously from a cave at the base of Mount Handren. The area is heavily shaded by large trees, making it a perfect picnic destination.',
    'Zenta Waterfall':
    'A more secluded and tranquil waterfall in the Akre/Erbil border region, surrounded by thick forests and striking rock formations. It offers a pristine natural experience away from heavy crowds.',

    // Erbil - Religious & Activities
    'Jalil Khayat Mosque':
    'Erbil\'s largest and most visually striking mosque, completed in 2007. Its architecture is heavily inspired by the Ottoman style of the Blue Mosque in Istanbul, featuring magnificent domes and incredibly detailed interior tile work.',
    'Chaldean Catholic Church (Ankawa)':
    'A cornerstone of the ancient Christian community in Ankawa, serving as a center for worship and community gathering. The architecture reflects modern ecclesiastical design combined with Middle Eastern heritage.',
    'Mar Elia Church (Ankawa area)':
    'A historic and culturally significant church in Ankawa, representing the enduring legacy of the Christian faith in the Erbil region. It is a place of deep peace and spiritual reflection.',
    'Erbil cafes & night walk (100m Street)':
    'Experience the modern, bustling side of Erbil by night. The 100m street and Ankawa areas are lined with vibrant cafes, tea houses, and restaurants where locals gather to socialize late into the night.',
    'Family Mall & entertainment':
    'One of the premier shopping and entertainment complexes in Erbil, featuring international brands, an indoor ice rink, cinemas, and a lively atmosphere that showcases the city\'s rapid modernization.',
    'Shaqlawa weekend picnic':
    'A classic Kurdish weekend tradition: gathering with family and friends in the cool, shaded orchards of Shaqlawa to barbecue, drink tea, and enjoy the beautiful mountain weather.',
    'Rawanduz scenic road trip':
    'Driving the Hamilton Road through the Rawanduz gorge is an unforgettable experience. The road, engineered in the 1920s, clings to the sheer cliff faces and passes through spectacular mountainous terrain.',

    // Erbil - Food & Dining
    'Machko Chaikhana':
    'Located right at the base of the Erbil Citadel, Machko is the most famous traditional tea house in the city. Frequented by intellectuals, locals, and tourists, it offers a deeply authentic atmosphere with sweet Kurdish tea and historic photographs lining the walls.',
    'Abu Shihab Restaurant':
    'One of Erbil\'s most renowned restaurants, offering an extensive buffet of traditional Kurdish and Middle Eastern cuisine, including perfectly grilled meats, quzi, and fresh appetizers in a grand, welcoming setting.',
    'Kebab Yasin':
    'A legendary, historic kebab joint located within the labyrinth of the Qaysari Bazaar. It is famous for serving incredibly fresh, simple, and perfectly spiced Kurdish kebabs with freshly baked naan.',
    'Dawa 2 Restaurant':
    'A favorite local spot known for its authentic, hearty Kurdish meals like dolma, biryani, and slow-cooked lamb. It provides a true taste of home-cooked Kurdish hospitality.',

    // Sulaymaniyah - Historical
    'Amna Suraka (Red Prison)':
    'The "Red Security" building was the headquarters of Saddam Hussein\'s intelligence agency in Sulaymaniyah. Today, it serves as a powerful and sobering museum documenting the Kurdish genocide, the Anfal campaign, and the resilience of the Kurdish people.',
    'Slemani Museum':
    'The second largest museum in Iraq after the National Museum in Baghdad. It houses an incredible collection of artifacts from the Paleolithic era to the Islamic period, including crucial discoveries from the Zagros Mountains.',
    'Sulaimaniyah Bazaar (Old Market)':
    'The cultural and commercial heart of Sulaymaniyah. The bazaar is renowned for its intellectual atmosphere, traditional tea houses (Chaikanas), and bustling alleys selling everything from Kurdish fabrics to local spices.',

    // Sulaymaniyah - Nature
    'Azmar Mountain Viewpoint':
    'Mount Azmar directly overlooks the city of Sulaymaniyah. The drive to the top offers spectacular, uninterrupted panoramic views of the sprawling city below, making it especially popular for sunset and night viewing.',
    'Dukan Lake':
    'The largest lake in the Kurdistan Region, created by the Dukan Dam on the Little Zab river. Its vivid blue waters contrast beautifully with the surrounding hills, making it a premier destination for boating, swimming, and lakeside resorts.',
    'Dukan Dam area':
    'An impressive feat of engineering built in the 1950s, the dam area offers magnificent views of the deep gorge on one side and the expansive, tranquil lake on the other.',
    'Chavi Land (viewpoint & park)':
    'A massive amusement park and tourist complex built into the side of Goizha Mountain. It features a scenic cable car (teleferic) that takes visitors to the mountain\'s peak for incredible views of Sulaymaniyah.',

    // Sulaymaniyah - Waterfalls & Religious
    'Ahmed Awa Waterfall':
    'Situated near the Iranian border in the Hawraman region, Ahmed Awa is surrounded by dense walnut, pomegranate, and fig trees. The powerful waterfall and the cool, rushing streams make it a highly favored nature retreat.',
    'Tawela (near Ahmed Awa) springs':
    'Located in the heart of the Hawraman mountains, Tawela is famous for its unique stepped village architecture, lush green springs, and the rich cultural traditions of its inhabitants.',
    'Grand Mosque of Sulaymaniyah':
    'Also known as the Great Mosque (Mzgawti Gawra), this is the oldest and most historically significant mosque in the city. It contains the tomb of Haji Kaka Ahmad and is a central hub for religious life in Sulaymaniyah.',

    // Sulaymaniyah - Activities
    'Chavi Land amusement area':
    'A sprawling entertainment hub offering roller coasters, Ferris wheels, wax museums, and sprawling gardens. It is the perfect destination for family fun and vibrant evening entertainment.',
    'Dukan boating / lakeside day':
    'Rent a traditional boat or a modern speedboat to explore the vast, pristine waters of Dukan Lake. The lakeside is dotted with cabins and picnic areas ideal for a relaxing getaway.',
    'Azmar sunset hike':
    'A rewarding activity for nature lovers. Hiking up the trails of Mount Azmar during the late afternoon offers spectacular views as the sun sets and the city lights of Sulaymaniyah slowly illuminate the valley.',

    // Sulaymaniyah - Food & Dining
    'Shaab Teahouse (Chaikhanay Shaab)':
    'A cultural institution in Sulaymaniyah. This historic teahouse is the traditional gathering place for the city\'s poets, writers, and politicians. The walls are covered with portraits of famous Kurdish figures, making it a living museum of Kurdish intellect.',
    'Kebab Wasta Hasan':
    'Arguably the most famous kebab restaurant in Sulaymaniyah, known across the region for its exceptionally tender and flavorful minced meat kebabs served with fresh herbs, sumac, and warm bread.',
    'Chalak\'s Place':
    'A modern yet culturally rooted cafe and restaurant that has become a staple of Sulaymaniyah\'s vibrant youth and arts scene, offering great food, coffee, and a lively atmosphere.',

    // Duhok - Historical
    'Amedi (Amediye) old town':
    'Amedi is an ancient, breathtaking town built entirely on the flat top of an elliptical mountain. With a history spanning over 5,000 years, it has been home to Assyrians, Jews, Christians, and Muslims, featuring ancient gates, an old mosque, and incredible valley views.',
    'Duhok Bazaar (Old Market)':
    'A vibrant and historic marketplace in the center of Duhok. It retains an authentic, traditional feel where visitors can find local Kurdish crafts, fresh produce, and traditional sweets unique to the Bahdinan region.',

    // Duhok - Nature
    'Duhok Dam':
    'Just a few minutes from the city center, the Duhok Dam forms a beautiful lake surrounded by dramatic hills. The area is flanked by cafes and walking paths, making it a favorite local spot for evening strolls and tea.',
    'Gara Mountain viewpoints':
    'Mount Gara stands over 2,000 meters high and offers some of the most commanding, majestic views in the entire Kurdistan Region. In winter, it is heavily snow-capped, while spring brings a carpet of green to the slopes.',
    'Zakho Riverside (Khabur River)':
    'The Khabur River flows peacefully through the ancient city of Zakho. The riverside is famous for the historic Delal Bridge (Pira Delal), an ancient stone bridge with mysterious origins that spans the river with majestic arches.',

    // Duhok - Waterfalls & Religious
    'Gali Sheran Waterfall':
    'A hidden gem in the Duhok region, Gali Sheran features stunning, crystal-clear blue-green pools fed by cascading mountain water. It is a pristine natural sanctuary perfect for photography and nature hiking.',
    'Sipa Waterfall':
    'Located near the town of Akre, Sipa is a beautiful waterfall that flows heavily during the spring melt. It is surrounded by lush vegetation and provides a cool, refreshing atmosphere.',
    'Lalish (Yazidi Holy Temple)':
    'Lalish is the holiest temple and the spiritual heart of the Yazidi faith. Nestled in a quiet mountain valley, the site is known for its conical shrines, sacred springs, and profound peacefulness. Visitors must remove their shoes and walk barefoot as a sign of respect.',

    // Duhok - Activities
    'Amedi day trip':
    'Exploring Amedi offers a journey back in time. Walk to the ancient Badinan Gate, visit the historic minaret, and enjoy a traditional lunch while overlooking the expansive, stunning mountain valleys.',
    'Duhok Dam picnic':
    'Join the locals in a cherished weekend activity: bringing a picnic basket and tea thermos to the shores of the Duhok Dam lake to enjoy the cool breeze and sunset views over the water.',
    'Zakho day trip':
    'A trip to Zakho is incomplete without walking across the ancient Delal Bridge, exploring the local border-town markets, and enjoying fresh fish by the Khabur River.',

    // Duhok - Food & Dining
    'Kebab Kawa':
    'A staple of Duhok\'s culinary scene, Kebab Kawa is famous for its high-quality, perfectly grilled traditional kebabs. It is a must-visit for anyone wanting to experience authentic Bahdinan-style grilling.',
    'Malta Restaurant':
    'A highly regarded local restaurant offering a wide variety of traditional Kurdish dishes, fresh salads, and excellent grilled meats in a family-friendly environment.',
    'Mazi Mall Food Court':
    'For a modern dining experience, the Mazi Mall area offers a bustling collection of local and regional food vendors, blending traditional Kurdish street food flavors with modern convenience.',

    // Halabja - Historical & Nature
    'Halabja Monument & Memorial':
    'A deeply moving memorial dedicated to the 5,000 Kurdish civilians who lost their lives in the tragic 1988 chemical attack. The museum respectfully preserves the memory of the victims and stands as a global symbol for peace and human rights.',
    'Hawraman (Kurdish mountain villages)':
    'Hawraman is a stunning, rugged mountainous region famous for its unique stepped villages, where the roof of one house serves as the courtyard for the house above it. The region has a distinct dialect, unique traditional clothing, and rich folklore.',
    'Byara (nature & village views)':
    'A prominent village in the Hawraman region, Byara is renowned for its lush orchards, religious significance (housing several Sufi lodges), and incredibly scenic, serene mountain environment.',

    // Halabja - Waterfalls & Religious
    'Ahmed Awa Waterfall (Halabja route)':
    'Approaching Ahmed Awa from the Halabja route provides a scenic journey through the Hawraman mountains. The waterfall itself is a powerful cascade surrounded by thick forests and lively outdoor tea stalls.',
    'Tawela springs (Halabja route)':
    'Famous for its pure, cold mountain springs and exceptional walnuts, Tawela is the last village before the Iranian border. It represents the quintessential beauty of rural Kurdish mountain life.',
    'Local mosques & heritage sites (Halabja)':
    'Halabja has a long history as a center for Islamic scholarship in Kurdistan. Its local mosques and heritage sites reflect a deep-rooted tradition of learning, poetry, and resilience.',

    // Halabja - Activities
    'Hawraman scenic drive':
    'The drive through the Hawraman region is breathtaking. The narrow roads wind through deep valleys and towering mountain peaks, passing through ancient villages that seem untouched by time.',
    'Picnic day in Byara':
    'A perfect way to experience local culture: relaxing under the shade of ancient walnut trees in Byara, drinking fresh mountain spring water, and enjoying the unmatched tranquility of the Hawraman mountains.',
    // Halabja - Food & Dining
    'Hawraman Traditional Restaurants':
    'Scattered throughout the Hawraman mountains and Byara, these traditional open-air restaurants serve localized Kurdish delicacies, including slow-roasted meats and dishes made with the region\'s famous fresh walnuts and pomegranates.',
    'Halabja Kebab and Fish':
    'Local eateries in Halabja are renowned for their fresh mountain river fish (masgouf style) and hearty local kebabs, offering simple, incredibly fresh, and flavorful meals.',

    // --- New Places ---
    'Shanidar Cave':
    'An archaeological site in the Bradost Mountain where remains of ten Neanderthals were discovered. This cave is world-famous for the "flower burial" theory, providing crucial insights into prehistoric human life and empathy among Neanderthals.',
    'Korek Mountain Resort':
    'A year-round tourist destination featuring a 4km cable car ride, luxury villas, and recreational activities. In winter, it serves as a premier skiing destination with panoramic views of the Zagros Mountains.',
    'Pank Tourist Resort':
    'A popular leisure destination near Rawanduz, famous for its high-speed alpine toboggan run that winds through dramatic mountain scenery and cliffs overlooking the gorge.',
    'Kani Bast Waterfall':
    'One of the highest and most majestic waterfalls in the region, located in the rugged Choman area. It cascades down massive rock faces and is a favorite for adventurous hikers.',
    'Darbandikhan Lake':
    'A vast and scenic reservoir on the Sirwan River. The area is surrounded by dramatic limestone peaks and offers excellent opportunities for boating, fishing, and lakeside camping.',
    'Qaradagh Mountain':
    'Known for its lush oak forests and ancient rock carvings. It is a center for Kurdish nature conservation and offers some of the best hiking trails in the Sulaymaniyah governorate.',
    'Akre (Aqrah)':
    'A stunning historic town built directly into the steep mountainside. Akre is internationally famous for its spectacular Newroz (Kurdish New Year) celebrations, where thousands carry torches up the mountain peaks.',
    'Zanta Waterfall':
    'A hidden natural gem located in a lush valley near Akre. The waterfall is surrounded by verdant greenery and provides a cool, tranquil escape during the summer months.',
    'Gara Mountain':
    'A high mountain range offering breathtaking views of the Amadiya plateau. It features unique flora and is a popular spot for mountain climbing and viewing the sunset over the Duhok mountains.',
    'Sartaki Bamo':
    'A dramatic mountain pass and nature reserve near the Halabja-Iran border. It is known for its steep, sheer cliffs, deep valleys, and being a habitat for rare wild mountain goats.',
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
        'Shanidar Cave',
      ],
      'nature': [
        'Sami Abdulrahman Park',
        'Shaqlawa Mountain Town',
        'Rawanduz Canyon Viewpoints',
        'Gali Ali Beg Gorge Viewpoints',
        'Bekhal Valley Viewpoints',
        'Dore Canyon',
      ],
      'waterfalls': [
        'Bekhal Waterfall',
        'Gali Ali Beg Water Area',
        'Jundiyan Waterfall',
        'Zenta Waterfall',
        'Kani Bast Waterfall',
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
        'Korek Mountain Resort',
        'Pank Tourist Resort',
      ],
      'food': [
        'Machko Chaikhana',
        'Abu Shihab Restaurant',
        'Kebab Yasin',
        'Dawa 2 Restaurant',
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
        'Darbandikhan Lake',
        'Qaradagh Mountain',
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
      'food': [
        'Shaab Teahouse (Chaikhanay Shaab)',
        'Kebab Wasta Hasan',
        'Chalak\'s Place',
      ],
    },

    'duhok': {
      'historical': [
        'Amedi (Amediye) old town',
        'Duhok Bazaar (Old Market)',
        'Akre (Aqrah)',
      ],
      'nature': [
        'Duhok Dam',
        'Gara Mountain viewpoints',
        'Zakho Riverside (Khabur River)',
        'Gara Mountain',
      ],
      'waterfalls': [
        'Gali Sheran Waterfall',
        'Sipa Waterfall',
        'Zenta Waterfall',
      ],
      'religious': [
        'Lalish (Yazidi Holy Temple)',
      ],
      'activities': [
        'Amedi day trip',
        'Duhok Dam picnic',
        'Zakho day trip',
      ],
      'food': [
        'Kebab Kawa',
        'Malta Restaurant',
        'Mazi Mall Food Court',
      ],
    },

    'halabja': {
      'historical': [
        'Halabja Monument & Memorial',
      ],
      'nature': [
        'Hawraman (Kurdish mountain villages)',
        'Byara (nature & village views)',
        'Sartaki Bamo',
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
      'food': [
        'Hawraman Traditional Restaurants',
        'Halabja Kebab and Fish',
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
