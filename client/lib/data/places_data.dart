// Auto-generated tourist places dataset for Kurdistan.
//
// Drop into:  lib/data/places_data.dart

class TouristPlace {
  final String id;
  final String title;
  final String cityId;        // erbil | sulaymaniyah | duhok | halabja
  final String categoryId;    // historical | religion | food | activity | nature
  final String about;
  final String image;         // local asset path
  final String wikimediaUrl;  // Wikimedia Commons / Wikipedia source
  final double? lat;
  final double? lng;

  const TouristPlace({
    required this.id,
    required this.title,
    required this.cityId,
    required this.categoryId,
    required this.about,
    required this.image,
    required this.wikimediaUrl,
    this.lat,
    this.lng,
  });
}

const kKurdistanPlaces = <TouristPlace>[
  // ───────────────────────────── ERBIL ─────────────────────────────

  // Historical
  TouristPlace(
    id: 'erbil-citadel',
    title: 'Erbil Citadel',
    cityId: 'erbil',
    categoryId: 'historical',
    about:
        'A UNESCO World Heritage Site and one of the oldest continuously inhabited places on Earth — the tell rises 32 m above modern Erbil and has been occupied for over 6,000 years.',
    image: 'assets/images/place_citadel.png',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Citadel_of_Erbil',
    lat: 36.1916,
    lng: 44.0093,
  ),
  TouristPlace(
    id: 'mudhafaria-minaret',
    title: 'Mudhafaria Minaret',
    cityId: 'erbil',
    categoryId: 'historical',
    about:
        'A 36-metre brick minaret from the 12th-century Atabeg dynasty, set in a small park — one of the oldest Islamic monuments in Iraq still standing.',
    image: 'assets/images/wiki_mudhafaria_minaret.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Choli_Minaret',
    lat: 36.2156,
    lng: 43.9919,
  ),
  TouristPlace(
    id: 'qaysari-bazaar',
    title: 'Qaysari Bazaar',
    cityId: 'erbil',
    categoryId: 'historical',
    about:
        'The ancient covered bazaar at the foot of the citadel — copper merchants, spice stalls, and 19th-century chaikhanas under stone arches.',
    image: 'assets/images/wiki_qaysari_bazaar.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Qaysari_Bazaar',
    lat: 36.1908,
    lng: 44.0090,
  ),
  TouristPlace(
    id: 'erbil-civilization-museum',
    title: 'Erbil Civilization Museum',
    cityId: 'erbil',
    categoryId: 'historical',
    about:
        'Compact museum near the citadel showing Assyrian, Sumerian and Akkadian artifacts found across Kurdistan, including cuneiform tablets and ancient pottery.',
    image: 'assets/images/place_erbil_museum.jpg',
    wikimediaUrl:
        'https://en.wikipedia.org/wiki/Erbil_Civilization_Museum',
    lat: 36.1898,
    lng: 44.0094,
  ),
  TouristPlace(
    id: 'khanzad-castle',
    title: 'Khanzad Castle',
    cityId: 'erbil',
    categoryId: 'historical',
    about:
        'A 16th-century Soran-Emirate fortress on the road from Erbil to Shaqlawa. Built by Princess Khanzad, the castle hosts cultural festivals and offers sweeping mountain views.',
    image: 'assets/images/place_khanzad_castle.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Khanzad_Castle',
    lat: 36.5417,
    lng: 44.2750,
  ),
  TouristPlace(
    id: 'mar-behnam-erbil',
    title: 'Mar Behnam Church',
    cityId: 'erbil',
    categoryId: 'historical',
    about:
        'A historic Chaldean church in Ainkawa (the Christian quarter of Erbil), important to Kurdistan\'s Christian heritage.',
    image: 'assets/images/place_mar_behnam.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Ankawa',
    lat: 36.2346,
    lng: 43.9939,
  ),

  // Religion
  TouristPlace(
    id: 'jalil-khayat-mosque',
    title: 'Jalil Khayat Mosque',
    cityId: 'erbil',
    categoryId: 'religion',
    about:
        'Erbil\'s largest mosque, opened 2007. Inspired by Cairo\'s Muhammad Ali Mosque, with two 65-metre minarets and a turquoise-and-gold interior.',
    image: 'assets/images/place_mosque.png',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Jalil_Khayat_Mosque',
    lat: 36.1830,
    lng: 43.9897,
  ),
  TouristPlace(
    id: 'mar-yousef-cathedral',
    title: 'Mar Yousef Cathedral',
    cityId: 'erbil',
    categoryId: 'religion',
    about:
        'The Chaldean Catholic cathedral in Ainkawa — centre of Erbil\'s Christian community since the 1990s.',
    image: 'assets/images/place_mar_yousef.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Ankawa',
    lat: 36.2360,
    lng: 43.9942,
  ),
  TouristPlace(
    id: 'sayidna-khalil-mosque',
    title: 'Sayidna Khalil Mosque',
    cityId: 'erbil',
    categoryId: 'religion',
    about:
        'Historic shrine and mosque in central Erbil, popular for Friday prayers and local pilgrimage.',
    image: 'assets/images/place_khalil_mosque.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Erbil',
    lat: 36.1900,
    lng: 44.0080,
  ),

  // Food
  TouristPlace(
    id: 'mama-khalil-erbil',
    title: 'Mama Khalil Restaurant',
    cityId: 'erbil',
    categoryId: 'food',
    about:
        'Traditional Kurdish restaurant on the citadel slope famous for tashreeb (lamb stew over flatbread), kibbeh and dolma. A locals\' favourite for decades.',
    image: 'assets/images/food_mama_khalil.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Kurdish_cuisine',
  ),
  TouristPlace(
    id: 'abu-shahab-kebab',
    title: 'Abu Shahab Kebab',
    cityId: 'erbil',
    categoryId: 'food',
    about:
        'Erbil\'s most famous kebab house — charcoal-grilled lamb kebabs with sumac onions and warm samoon bread. Often a 2-hour wait at peak.',
    image: 'assets/images/food_abu_shahab.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Kebab',
  ),
  TouristPlace(
    id: 'citadel-tea-houses',
    title: 'Citadel Tea Houses',
    cityId: 'erbil',
    categoryId: 'food',
    about:
        'Tiny century-old tea houses around the citadel where men play dominoes over kettles of red tea (cha) sweetened with cardamom.',
    image: 'assets/images/cha.jpeg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Tea_in_Iraq',
  ),
  TouristPlace(
    id: 'kebab-mahmoud',
    title: 'Kebab Mahmoud',
    cityId: 'erbil',
    categoryId: 'food',
    about:
        'Casual neighbourhood spot specialising in kofta and shish-tawook, served with pickled turnips and fresh tabbouleh.',
    image: 'assets/images/food_kebab_mahmoud.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Kurdish_cuisine',
  ),

  // Activity
  TouristPlace(
    id: 'sami-abdulrahman-park',
    title: 'Sami Abdulrahman Park',
    cityId: 'erbil',
    categoryId: 'activity',
    about:
        'Erbil\'s largest urban park (over 200 hectares), with lakes, walking trails, fountains and a martyrs\' memorial. Locals walk here at sunset.',
    image: 'assets/images/wiki_sami_abdulrahman.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Sami_Abdulrahman_Park',
    lat: 36.1839,
    lng: 43.9619,
  ),
  TouristPlace(
    id: 'shanidar-park',
    title: 'Shanidar Park',
    cityId: 'erbil',
    categoryId: 'activity',
    about:
        'Central park between the citadel and 60-Metre Road, with a man-made lake, food kiosks and weekend concerts.',
    image: 'assets/images/shanadar.jpeg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Erbil',
    lat: 36.1825,
    lng: 44.0080,
  ),
  TouristPlace(
    id: 'korek-mountain',
    title: 'Korek Mountain Resort',
    cityId: 'erbil',
    categoryId: 'activity',
    about:
        'Year-round resort 70 km north of Erbil with the longest cable car in the Middle East — 4.6 km up to a 2,100-m summit. Skiing, hiking and luge.',
    image: 'assets/images/wiki_korek.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Korek_Mountain',
    lat: 36.6614,
    lng: 44.5689,
  ),
  TouristPlace(
    id: 'pank-resort',
    title: 'Pank Resort',
    cityId: 'erbil',
    categoryId: 'activity',
    about:
        'Mountain resort near Rawanduz with cable cars, alpine slides and chalets — a growing weekend escape from Erbil.',
    image: 'assets/images/wiki_pank_resort.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Pank_Resort',
    lat: 36.6308,
    lng: 44.5325,
  ),
  TouristPlace(
    id: 'family-mall-erbil',
    title: 'Family Mall Erbil',
    cityId: 'erbil',
    categoryId: 'activity',
    about:
        'The largest shopping mall in Iraq, with 200+ international brands, an Imax cinema, and one of Erbil\'s biggest food courts.',
    image: 'assets/images/place_family_mall.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Family_Mall',
  ),

  // Nature
  TouristPlace(
    id: 'bekhal-waterfall',
    title: 'Bekhal Waterfall',
    cityId: 'erbil',
    categoryId: 'nature',
    about:
        'A 25-m cascade in Soran with restaurants and tea-house decks built right onto the rocks. Iconic Kurdish picnic spot.',
    image: 'assets/images/place_bekhal.png',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Bekhal_waterfall',
    lat: 36.6383,
    lng: 44.5533,
  ),
  TouristPlace(
    id: 'gali-ali-beg',
    title: 'Gali Ali Beg',
    cityId: 'erbil',
    categoryId: 'nature',
    about:
        'A famed canyon and 800-m waterfall on the Hamilton Road; the cliff-side waterfall is featured on the 5,000-dinar banknote.',
    image: 'assets/images/place_gali_ali_beg.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Gali_Ali_Beg',
    lat: 36.6294,
    lng: 44.4583,
  ),
  TouristPlace(
    id: 'rawanduz',
    title: 'Rawanduz',
    cityId: 'erbil',
    categoryId: 'nature',
    about:
        'Historic town perched above a deep gorge, surrounded by orchards. Gateway to the Hamilton Road and the Iranian border.',
    image: 'assets/images/place_rawanduz.png',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Rawandiz',
    lat: 36.6094,
    lng: 44.5278,
  ),
  TouristPlace(
    id: 'shaqlawa',
    title: 'Shaqlawa',
    cityId: 'erbil',
    categoryId: 'nature',
    about:
        'Summer resort town in the Safeen mountains, famous for its cool climate, vineyards and walnut trees.',
    image: 'assets/images/place_shaqlawa.png',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Shaqlawa',
    lat: 36.4031,
    lng: 44.3267,
  ),
  TouristPlace(
    id: 'hamilton-road',
    title: 'Hamilton Road',
    cityId: 'erbil',
    categoryId: 'nature',
    about:
        'A 1930s mountain road built by New Zealand engineer A. M. Hamilton, threading canyons, suspension bridges and tunnels from Erbil to the Iranian border.',
    image: 'assets/images/place_hamilton_road.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Hamilton_Road',
  ),
  TouristPlace(
    id: 'akre-erbil',
    title: 'Akre Mountain Town',
    cityId: 'erbil',
    categoryId: 'nature',
    about:
        'Mountain town famous for Newroz bonfires that climb the cliffs every 21 March. Stone houses and panoramic valleys.',
    image: 'assets/images/wiki_akre.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Aqrah',
    lat: 36.7414,
    lng: 43.8900,
  ),
  TouristPlace(
    id: 'halgurd-sakran',
    title: 'Halgurd-Sakran National Park',
    cityId: 'erbil',
    categoryId: 'nature',
    about:
        'Iraq\'s first national park, home to Halgurd (3,607 m) and Cheekha Dar (3,611 m). Wild bears, wolves and the rare Persian leopard.',
    image: 'assets/images/place_halgurd.jpg',
    wikimediaUrl:
        'https://en.wikipedia.org/wiki/Halgurd-Sakran_National_Park',
    lat: 36.7833,
    lng: 44.9333,
  ),

  // ─────────────────────────── SULAYMANIYAH ───────────────────────────

  // Historical
  TouristPlace(
    id: 'slemani-museum',
    title: 'Slemani Museum',
    cityId: 'sulaymaniyah',
    categoryId: 'historical',
    about:
        'The second-largest museum in Iraq, with artifacts from the Paleolithic to the Islamic period — Sumerian, Akkadian, Babylonian and Sassanid.',
    image: 'assets/images/place_slemani_museum.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Sulaymaniyah_Museum',
    lat: 35.5611,
    lng: 45.4347,
  ),
  TouristPlace(
    id: 'amna-suraka',
    title: 'Amna Suraka',
    cityId: 'sulaymaniyah',
    categoryId: 'historical',
    about:
        'Former Ba\'athist security headquarters now a museum dedicated to Kurdish victims of Saddam Hussein. The Hall of Mirrors contains 182,000 shards — one for every Anfal victim.',
    image: 'assets/images/place_amna_suraka.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Amna_Sur',
    lat: 35.5664,
    lng: 45.4358,
  ),
  TouristPlace(
    id: 'suli-bazaar',
    title: 'Old Sulaymaniyah Bazaar',
    cityId: 'sulaymaniyah',
    categoryId: 'historical',
    about:
        'Vast warren of stalls selling fabrics, gold, spices, traditional Kurdish clothes (jli kurdi), and stand-up shorba counters.',
    image: 'assets/images/place_sulaymaniyah_bazaar.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Bazaar_of_Sulaymaniyah',
    lat: 35.5631,
    lng: 45.4364,
  ),
  TouristPlace(
    id: 'mawlana-khalid-shrine',
    title: 'Mawlana Khalid Shrine',
    cityId: 'sulaymaniyah',
    categoryId: 'historical',
    about:
        'Ornate 19th-century shrine of Mawlana Khalid Naqshbandi, founder of the Naqshbandi Khalidi Sufi order — important pilgrimage site.',
    image: 'assets/images/place_mawlana_khalid.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Khalid_al-Baghdadi',
    lat: 35.5575,
    lng: 45.4325,
  ),

  // Religion
  TouristPlace(
    id: 'grand-mosque-suli',
    title: 'Grand Mosque of Sulaymaniyah',
    cityId: 'sulaymaniyah',
    categoryId: 'religion',
    about:
        'The city\'s main Friday mosque, built 1784 — a serene courtyard, an old library, and arched arcades typical of late-Ottoman Kurdish architecture.',
    image: 'assets/images/place_grand_mosque_suli.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Sulaymaniyah',
    lat: 35.5609,
    lng: 45.4356,
  ),
  TouristPlace(
    id: 'mawlana-khalid-mosque',
    title: 'Mawlana Khalid Mosque',
    cityId: 'sulaymaniyah',
    categoryId: 'religion',
    about:
        'A small mosque attached to the Mawlana Khalid shrine, with green-domed minarets and traditional Naqshbandi calligraphy.',
    image: 'assets/images/place_mawlana_mosque.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Sulaymaniyah',
  ),
  TouristPlace(
    id: 'surdash-tomb',
    title: 'Surdash Tomb',
    cityId: 'sulaymaniyah',
    categoryId: 'religion',
    about:
        'Mountain shrine north of Sulaymaniyah honouring a local Sufi saint, set in alpine meadows.',
    image: 'assets/images/place_surdash.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Sulaymaniyah_Governorate',
  ),

  // Food
  TouristPlace(
    id: 'bazaar-shorja-sweets',
    title: 'Bazaar Shorja Sweets',
    cityId: 'sulaymaniyah',
    categoryId: 'food',
    about:
        'Sulaymaniyah\'s old sweet alleys — pistachio mann al-sama, sesame halva and saffron rice pudding made on copper trays since the 1920s.',
    image: 'assets/images/food_bazaar_shorja.jpg',
    wikimediaUrl:
        'https://en.wikipedia.org/wiki/Iraqi_cuisine',
  ),
  TouristPlace(
    id: 'kani-spi',
    title: 'Kani Spi Restaurant',
    cityId: 'sulaymaniyah',
    categoryId: 'food',
    about:
        'Riverside restaurant on the road to Tasluja famous for whole grilled trout (masgouf), Kurdish dolma and seasonal fruit platters.',
    image: 'assets/images/food_kani_spi.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Masgouf',
  ),
  TouristPlace(
    id: 'suli-bazaar-food',
    title: 'Suli Bazaar Street Food',
    cityId: 'sulaymaniyah',
    categoryId: 'food',
    about:
        'Bazaar stalls selling kuba, shaftal and freshly pressed pomegranate juice from Halabja.',
    image: 'assets/images/food_suli_bazaar.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Bazaar_of_Sulaymaniyah',
  ),
  TouristPlace(
    id: 'mam-khalil-suli',
    title: 'Mam Khalil Dolma',
    cityId: 'sulaymaniyah',
    categoryId: 'food',
    about:
        'Long-running Sulaymaniyah dolma house — vine leaves, peppers, courgettes and onions stuffed with rice, lamb and sumac, simmered for half a day.',
    image: 'assets/images/food_mam_khalil_suli.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Dolma',
  ),

  // Activity
  TouristPlace(
    id: 'azadi-park',
    title: 'Azadi Park',
    cityId: 'sulaymaniyah',
    categoryId: 'activity',
    about:
        '"Freedom Park" — Sulaymaniyah\'s central green space with a lake, fountains, jogging tracks and an outdoor amphitheatre.',
    image: 'assets/images/place_azadi_park.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Sulaymaniyah',
    lat: 35.5650,
    lng: 45.4322,
  ),
  TouristPlace(
    id: 'goyzha-mountain',
    title: 'Goyzha Mountain',
    cityId: 'sulaymaniyah',
    categoryId: 'activity',
    about:
        'The mountain rising above the city — paved switchbacks to the summit, sunset cafés, and weekend hikers. Unmatched dusk view across Sulaymaniyah.',
    image: 'assets/images/place_goyzha.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Goyzha',
    lat: 35.5839,
    lng: 45.4214,
  ),
  TouristPlace(
    id: 'sarchnar',
    title: 'Sarchnar',
    cityId: 'sulaymaniyah',
    categoryId: 'activity',
    about:
        'Cool springs and walnut groves on the city\'s western edge — picnic decks, waterwheels and small kebab restaurants.',
    image: 'assets/images/place_sarchnar.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Sulaymaniyah',
  ),
  TouristPlace(
    id: 'family-mall-suli',
    title: 'Family Mall Sulaymaniyah',
    cityId: 'sulaymaniyah',
    categoryId: 'activity',
    about:
        'Modern shopping mall with cinema, ice rink, food court and rooftop play area.',
    image: 'assets/images/place_family_mall_suli.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Family_Mall',
  ),
  TouristPlace(
    id: 'majidi-mall',
    title: 'Majidi Mall',
    cityId: 'sulaymaniyah',
    categoryId: 'activity',
    about:
        'Sulaymaniyah\'s premium retail destination with international brands and an outdoor terrace overlooking the city.',
    image: 'assets/images/place_majidi_mall.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Sulaymaniyah',
  ),

  // Nature
  TouristPlace(
    id: 'dukan-lake',
    title: 'Dukan Lake',
    cityId: 'sulaymaniyah',
    categoryId: 'nature',
    about:
        'Vast Y-shaped reservoir 60 km north of Sulaymaniyah, framed by Zagros peaks. Floating restaurants, boat tours and lakeside chalets.',
    image: 'assets/images/place_dukan_lake.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Lake_Dukan',
    lat: 35.9533,
    lng: 44.9558,
  ),
  TouristPlace(
    id: 'ahmed-awa-suli',
    title: 'Ahmed Awa',
    cityId: 'sulaymaniyah',
    categoryId: 'nature',
    about:
        'A waterfall and resort village on the Iranian border — cool stream-fed restaurants under plane trees.',
    image: 'assets/images/place_ahmed_awa.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Ahmadawa',
    lat: 35.2347,
    lng: 46.1342,
  ),
  TouristPlace(
    id: 'sara-zanta',
    title: 'Sara Forest (Zanta)',
    cityId: 'sulaymaniyah',
    categoryId: 'nature',
    about:
        'Pine and oak forest near Penjwen, popular for car-camping and cherry-picking in season.',
    image: 'assets/images/wiki_zanta.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Zanta',
  ),
  TouristPlace(
    id: 'pira-magroon',
    title: 'Pira Magroon',
    cityId: 'sulaymaniyah',
    categoryId: 'nature',
    about:
        '3,168-m peak west of Sulaymaniyah, snow-capped half the year. Long ridge hike with panoramic views over Dukan Lake and Halabja.',
    image: 'assets/images/place_pira_magroon.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Pira_Magrun',
    lat: 35.6750,
    lng: 45.2417,
  ),
  TouristPlace(
    id: 'dore-canyon',
    title: 'Dore Canyon',
    cityId: 'sulaymaniyah',
    categoryId: 'nature',
    about:
        'A narrow limestone canyon north of the city with shaded swimming pools fed by spring water — a hidden summer favourite.',
    image: 'assets/images/wiki_dore_canyon.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Dore_Canyon',
  ),
  TouristPlace(
    id: 'kani-bast',
    title: 'Kani Bast Spring',
    cityId: 'sulaymaniyah',
    categoryId: 'nature',
    about:
        'Cold-water spring and picnic site — clear pools, weekend stalls and shaded oak walks.',
    image: 'assets/images/wiki_kani_bast.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Kani_Bast',
  ),
  TouristPlace(
    id: 'qaradagh',
    title: 'Qaradagh Mountain',
    cityId: 'sulaymaniyah',
    categoryId: 'nature',
    about:
        'The "Black Mountain" south of Sulaymaniyah — sites of the 1988 Anfal campaign now memorial trails through wildflower meadows.',
    image: 'assets/images/wiki_qaradagh.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Qaradagh',
  ),

  // ───────────────────────────── DUHOK ─────────────────────────────

  // Historical
  TouristPlace(
    id: 'amedi',
    title: 'Amedi (Amadiyah)',
    cityId: 'duhok',
    categoryId: 'historical',
    about:
        'A 5,000-year-old town perched on a flat-topped mountain at 1,400 m, encircled by sheer cliffs. The Bahdinan Gate carries Assyrian reliefs.',
    image: 'assets/images/place_amedi.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Amadiya',
    lat: 37.0911,
    lng: 43.4886,
  ),
  TouristPlace(
    id: 'akre-duhok',
    title: 'Akre Old Town',
    cityId: 'duhok',
    categoryId: 'historical',
    about:
        'Ancient stone town on the slopes of Akre mountain, world-famous for its Newroz celebration when thousands of torch-bearers climb the cliffs at dusk on 21 March.',
    image: 'assets/images/wiki_akre.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Aqrah',
    lat: 36.7414,
    lng: 43.8900,
  ),
  TouristPlace(
    id: 'khinis-reliefs',
    title: 'Khinis Reliefs',
    cityId: 'duhok',
    categoryId: 'historical',
    about:
        'Massive 7th-century-BCE rock reliefs of Sennacherib carved into a cliff above the Gomel river — Assyrian warriors and gods carrying the king on their shoulders.',
    image: 'assets/images/place_khinis.jpg',
    wikimediaUrl:
        'https://en.wikipedia.org/wiki/Khinis_(archaeological_site)',
    lat: 36.7867,
    lng: 43.3500,
  ),
  TouristPlace(
    id: 'duhok-museum',
    title: 'Duhok Museum',
    cityId: 'duhok',
    categoryId: 'historical',
    about:
        'Provincial museum showing artifacts from the Bahdinan emirate, Yezidi material culture, and prehistoric finds from Shanidar.',
    image: 'assets/images/place_duhok_museum.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Duhok',
    lat: 36.8669,
    lng: 42.9886,
  ),
  TouristPlace(
    id: 'sumail',
    title: 'Sumail Town',
    cityId: 'duhok',
    categoryId: 'historical',
    about:
        'Site of the 1933 Simele massacre and a small archaeological mound — now a quiet town on the Mosul road.',
    image: 'assets/images/place_sumail.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Simele',
    lat: 36.8447,
    lng: 42.8483,
  ),

  // Religion
  TouristPlace(
    id: 'lalish',
    title: 'Lalish Temple',
    cityId: 'duhok',
    categoryId: 'religion',
    about:
        'The holiest site of the Yazidi religion, hidden in a forested valley — the white-stoned Sheikh Adi shrine, sacred springs, and ribbon-tied pillars. Visitors must remove shoes and never step on doorways.',
    image: 'assets/images/place_lalish.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Lalish',
    lat: 36.7722,
    lng: 43.3111,
  ),
  TouristPlace(
    id: 'mar-mattai',
    title: 'Mar Mattai Monastery',
    cityId: 'duhok',
    categoryId: 'religion',
    about:
        'A 4th-century Syriac Orthodox monastery clinging to Mount Alfaf — one of the world\'s oldest Christian monasteries with an Aramaic manuscript library.',
    image: 'assets/images/place_mar_mattai.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Mar_Mattai_Monastery',
    lat: 36.4775,
    lng: 43.4019,
  ),
  TouristPlace(
    id: 'rabban-hormizd',
    title: 'Rabban Hormizd Monastery',
    cityId: 'duhok',
    categoryId: 'religion',
    about:
        'A 7th-century Chaldean monastery carved into the cliffs above Alqosh — site of the tomb of patriarch Rabban Hormizd and the Alqosh manuscript collection.',
    image: 'assets/images/place_rabban_hormizd.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Rabban_Hormizd_Monastery',
    lat: 36.7372,
    lng: 43.0958,
  ),
  TouristPlace(
    id: 'mar-yousef-duhok',
    title: 'Mar Yousef Cathedral (Duhok)',
    cityId: 'duhok',
    categoryId: 'religion',
    about:
        'The Chaldean Catholic cathedral of Duhok, central to the city\'s Christian community.',
    image: 'assets/images/place_mar_yousef_duhok.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Duhok',
  ),

  // Food
  TouristPlace(
    id: 'mar-yacoub',
    title: 'Mar Yacoub Restaurant',
    cityId: 'duhok',
    categoryId: 'food',
    about:
        'Mountain-spring restaurant in Sulav serving river trout, kebab and traditional kishk soup on wooden platforms over a stream.',
    image: 'assets/images/food_mar_yacoub.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Kurdish_cuisine',
  ),
  TouristPlace(
    id: 'duhok-bazaar-sweets',
    title: 'Duhok Bazaar Sweets',
    cityId: 'duhok',
    categoryId: 'food',
    about:
        'The old bazaar\'s shereen alleys — kunafa, mun-u-naki nougat, and rosewater zlebia made on tin trays.',
    image: 'assets/images/food_duhok_bazaar.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Iraqi_cuisine',
  ),
  TouristPlace(
    id: 'sulav-trout',
    title: 'Sulav Trout Houses',
    cityId: 'duhok',
    categoryId: 'food',
    about:
        'A line of family-run restaurants in Sulav resort grilling trout straight from the mountain hatchery, served with bulgur pilaf and yoghurt.',
    image: 'assets/images/food_sulav_trout.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Trout',
  ),

  // Activity
  TouristPlace(
    id: 'duhok-dam',
    title: 'Duhok Dam Lake',
    cityId: 'duhok',
    categoryId: 'activity',
    about:
        'Earth-fill dam wrapping the city to the north — popular for sunset walks, paddle-boats and the long lakeside promenade.',
    image: 'assets/images/place_duhok_dam.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Duhok_Dam',
    lat: 36.8800,
    lng: 42.9967,
  ),
  TouristPlace(
    id: 'sulav-resort',
    title: 'Sulav Resort',
    cityId: 'duhok',
    categoryId: 'activity',
    about:
        'Mountain resort 80 km from Duhok, gateway to Amedi — chalets, mountain-spring pools, and oak forests.',
    image: 'assets/images/place_sulav.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Sulav',
    lat: 37.0828,
    lng: 43.4867,
  ),
  TouristPlace(
    id: 'zawita',
    title: 'Zawita Resort',
    cityId: 'duhok',
    categoryId: 'activity',
    about:
        'Pine forest resort 20 km east of Duhok — picnic platforms, weekend markets, oak-fed stream pools.',
    image: 'assets/images/place_zawita.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Zawita',
    lat: 36.9011,
    lng: 43.1647,
  ),
  TouristPlace(
    id: 'bamarni',
    title: 'Bamarni Plateau',
    cityId: 'duhok',
    categoryId: 'activity',
    about:
        'A small plateau airstrip and meadow at 1,200 m, surrounded by walnut orchards. Famous for paragliding and Newroz festivals.',
    image: 'assets/images/place_bamarni.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Bamarni',
    lat: 37.1167,
    lng: 43.2667,
  ),
  TouristPlace(
    id: 'jiyan-park',
    title: 'Jiyan Park',
    cityId: 'duhok',
    categoryId: 'activity',
    about:
        'Duhok\'s main urban park, with cable cars to a hilltop café, kid-friendly rides and an outdoor stage.',
    image: 'assets/images/place_jiyan_park.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Duhok',
  ),

  // Nature
  TouristPlace(
    id: 'sulav-nature',
    title: 'Sulav',
    cityId: 'duhok',
    categoryId: 'nature',
    about:
        'Cool, oak-shaded mountain valley below Amedi with countless springs feeding small ponds and trout streams. The classic Duhok summer escape.',
    image: 'assets/images/hd_valley.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Sulav',
  ),
  TouristPlace(
    id: 'gara-mountain',
    title: 'Gara Mountain',
    cityId: 'duhok',
    categoryId: 'nature',
    about:
        'A long limestone ridge running across Duhok, peaking at 2,212 m. Home to wild mountain goats and ancient Christian caves.',
    image: 'assets/images/wiki_gara_mountain.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Gara_Mountain',
    lat: 37.0167,
    lng: 43.5333,
  ),
  TouristPlace(
    id: 'bamo',
    title: 'Bamo Mountain',
    cityId: 'duhok',
    categoryId: 'nature',
    about:
        'A peak on the Iraq-Iran border south of Halabja, often grouped with mountain treks from Duhok routes.',
    image: 'assets/images/wiki_bamo.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Bamo_Mountain',
  ),
  TouristPlace(
    id: 'shanidar-cave',
    title: 'Shanidar Cave',
    cityId: 'duhok',
    categoryId: 'nature',
    about:
        'A massive limestone cave in the Bradost mountains where 10 Neanderthal skeletons were excavated — including the famous "flower burial."',
    image: 'assets/images/wiki_shanidar_cave.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Shanidar_Cave',
    lat: 36.8333,
    lng: 44.2167,
  ),
  TouristPlace(
    id: 'atrush',
    title: 'Atrush Valley',
    cityId: 'duhok',
    categoryId: 'nature',
    about:
        'Quiet farming valley north of Duhok with vineyards, IDP-camp village markets, and a small Yazidi shrine.',
    image: 'assets/images/place_atrush.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Atrush',
  ),
  TouristPlace(
    id: 'mangesh',
    title: 'Mangesh',
    cityId: 'duhok',
    categoryId: 'nature',
    about:
        'Christian highland village near Akre with stone-arched houses and walnut orchards.',
    image: 'assets/images/place_mangesh.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Mangesh',
  ),

  // ───────────────────────────── HALABJA ─────────────────────────────

  // Historical
  TouristPlace(
    id: 'halabja-monument',
    title: 'Halabja Monument & Peace Museum',
    cityId: 'halabja',
    categoryId: 'historical',
    about:
        'A monumental hands-and-flame sculpture surrounded by a peace garden — built to honour the 5,000 Kurds killed in the 1988 chemical attack.',
    image: 'assets/images/place_halabja_monument.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Halabja_Monument_and_Peace_Museum',
    lat: 35.1772,
    lng: 45.9869,
  ),
  TouristPlace(
    id: 'old-halabja',
    title: 'Old Halabja Town',
    cityId: 'halabja',
    categoryId: 'historical',
    about:
        'Reconstructed neighbourhoods around the monument, with murals, bronze statues of victims and the preserved house of Omeri Khawer (a father shielding his son).',
    image: 'assets/images/place_old_halabja.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Halabja',
  ),
  TouristPlace(
    id: 'hawraman-villages',
    title: 'Hawraman Heritage Villages',
    cityId: 'halabja',
    categoryId: 'historical',
    about:
        'A UNESCO-listed cultural landscape of stepped stone villages — Hawraman Takht, Bistana — where rooftops are neighbours\' courtyards.',
    image: 'assets/images/place_hawraman.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Hawraman',
    lat: 35.2111,
    lng: 46.3222,
  ),

  // Religion
  TouristPlace(
    id: 'khanaqa-halabja',
    title: 'Khanaqa Mosque (Halabja)',
    cityId: 'halabja',
    categoryId: 'religion',
    about:
        'Halabja\'s central mosque and a refuge during the 1988 attack — the courtyard has a memorial plaque listing victim names.',
    image: 'assets/images/place_khanaqa_halabja.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Halabja',
  ),
  TouristPlace(
    id: 'hawrami-shrine',
    title: 'Hawrami Sufi Shrines',
    cityId: 'halabja',
    categoryId: 'religion',
    about:
        'Pre-Islamic and Sufi shrines scattered across Hawraman villages — the most famous at Bistana with views across the Sirwan valley.',
    image: 'assets/images/place_hawrami_shrine.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Hawraman',
  ),

  // Food
  TouristPlace(
    id: 'hawrami-pomegranate',
    title: 'Hawrami Pomegranate',
    cityId: 'halabja',
    categoryId: 'food',
    about:
        'Halabja\'s pomegranates are considered Kurdistan\'s best — turned into rob (molasses) and used in fesenjan stews. Roadside stalls sell baskets in autumn.',
    image: 'assets/images/food_pomegranate.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Pomegranates',
  ),
  TouristPlace(
    id: 'halabja-sweets',
    title: 'Halabja Sweets',
    cityId: 'halabja',
    categoryId: 'food',
    about:
        'Sumac-pomegranate fruit leather (basoq) and saffron baklava sold at the bazaar gates — Halabja\'s most-loved souvenir.',
    image: 'assets/images/food_halabja_sweets.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Iraqi_cuisine',
  ),
  TouristPlace(
    id: 'hawrami-cuisine',
    title: 'Hawrami Mountain Cuisine',
    cityId: 'halabja',
    categoryId: 'food',
    about:
        'Lamb cooked in clay pots with sumac, walnut bread, and sour-cherry-and-mutton stews — eaten on terraces over the Sirwan.',
    image: 'assets/images/food_hawrami.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Kurdish_cuisine',
  ),

  // Activity
  TouristPlace(
    id: 'ahmed-awa-halabja',
    title: 'Ahmed Awa Resort',
    cityId: 'halabja',
    categoryId: 'activity',
    about:
        'A waterfall and chain of restaurants on the Iranian border — wading streams, weekend stalls, kebab on stone slabs over the rapids.',
    image: 'assets/images/place_ahmed_awa.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Ahmadawa',
    lat: 35.2347,
    lng: 46.1342,
  ),
  TouristPlace(
    id: 'hawraman-trek',
    title: 'Hawraman Trekking',
    cityId: 'halabja',
    categoryId: 'activity',
    about:
        'Multi-day trekking through stepped villages connected by old donkey paths — best in spring (poppies) and autumn (red oaks).',
    image: 'assets/images/place_hawraman_trek.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Hawraman',
  ),
  TouristPlace(
    id: 'sirwan-river',
    title: 'Sirwan River Excursions',
    cityId: 'halabja',
    categoryId: 'activity',
    about:
        'River-rafting and picnic-platform restaurants along the Sirwan, especially in spring snow-melt.',
    image: 'assets/images/place_sirwan.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Diyala_River',
  ),

  // Nature
  TouristPlace(
    id: 'hawraman-mountains',
    title: 'Hawraman Mountains',
    cityId: 'halabja',
    categoryId: 'nature',
    about:
        'The Zagros range running across the bridge of the Iran-Iraq border, with terraced villages, oak forests and snow until June. Some of the most photogenic landscapes in the Middle East.',
    image: 'assets/images/place_hawraman.jpg',
    wikimediaUrl: 'https://commons.wikimedia.org/wiki/Category:Hawraman',
    lat: 35.2042,
    lng: 46.3300,
  ),
  TouristPlace(
    id: 'ahmed-awa-waterfall',
    title: 'Ahmed Awa Waterfall',
    cityId: 'halabja',
    categoryId: 'nature',
    about:
        'A natural cascade tumbling out of a forested gorge — chest-deep pools, smoke from charcoal grills, families on rugs in the spray.',
    image: 'assets/images/place_ahmed_awa.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Ahmadawa',
  ),
  TouristPlace(
    id: 'darbandikhan',
    title: 'Darbandikhan Lake',
    cityId: 'halabja',
    categoryId: 'nature',
    about:
        'A reservoir framed by limestone cliffs on the Sirwan — popular for boating, lakeside cafés and the dam scenic overlook.',
    image: 'assets/images/wiki_darbandikhan.jpg',
    wikimediaUrl:
        'https://commons.wikimedia.org/wiki/Category:Darbandikhan',
    lat: 35.1167,
    lng: 45.7000,
  ),
  TouristPlace(
    id: 'pira-magroon-halabja',
    title: 'Pira Magroon (Halabja side)',
    cityId: 'halabja',
    categoryId: 'nature',
    about:
        'Approached from Halabja\'s south side, this 3,168-m peak offers a less-trodden alpine route with poppy meadows and wild iris in May.',
    image: 'assets/images/place_pira_magroon.jpg',
    wikimediaUrl: 'https://en.wikipedia.org/wiki/Pira_Magrun',
  ),
  TouristPlace(
    id: 'shar-bazher',
    title: 'Shar Bazher',
    cityId: 'halabja',
    categoryId: 'nature',
    about:
        'Border-zone valley north of Halabja with dramatic gorges and old Kurdish nomadic pasturelands.',
    image: 'assets/images/place_shar_bazher.jpg',
    wikimediaUrl:
        'https://en.wikipedia.org/wiki/Halabja_Governorate',
  ),
  TouristPlace(
    id: 'daraban',
    title: 'Daraban Valley',
    cityId: 'halabja',
    categoryId: 'nature',
    about:
        'A quiet limestone valley near the Iranian border with cold springs, wild figs and 100-year-old oaks.',
    image: 'assets/images/place_daraban.jpg',
    wikimediaUrl:
        'https://en.wikipedia.org/wiki/Halabja_Governorate',
  ),
];
