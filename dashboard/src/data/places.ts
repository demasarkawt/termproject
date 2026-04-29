export interface Place {
  id: string;
  name: string;
  city: string;
  category: string;
  rating: number;
  image: string;
  isPremium: boolean;
}

export const places: Place[] = [
  // Erbil
  { id: 'erbil-h-01', name: 'Citadel of Erbil', city: 'Erbil', category: 'Historical', rating: 4.9, image: '/assets/images/wiki_citadel_erbil.jpg', isPremium: true },
  { id: 'erbil-h-02', name: 'Qaysari Bazaar', city: 'Erbil', category: 'Historical', rating: 4.8, image: '/assets/images/wiki_qaysari_bazaar.jpg', isPremium: false },
  { id: 'erbil-h-03', name: 'Mudhafaria Minaret', city: 'Erbil', category: 'Historical', rating: 4.7, image: '/assets/images/wiki_mudhafaria_minaret.jpg', isPremium: false },
  { id: 'erbil-n-01', name: 'Sami Abdulrahman Park', city: 'Erbil', category: 'Nature', rating: 4.8, image: '/assets/images/wiki_sami_abdulrahman.jpg', isPremium: false },
  { id: 'erbil-w-01', name: 'Bekhal Waterfall', city: 'Erbil', category: 'Waterfalls', rating: 4.9, image: '/assets/images/wiki_bekhal_waterfall.jpg', isPremium: true },
  { id: 'erbil-w-02', name: 'Gali Ali Beg Water Area', city: 'Erbil', category: 'Waterfalls', rating: 4.9, image: '/assets/images/wiki_gali_ali_beg.jpg', isPremium: true },
  { id: 'erbil-r-01', name: 'Jalil Khayat Mosque', city: 'Erbil', category: 'Religious', rating: 4.9, image: '/assets/images/place_mosque.png', isPremium: false },
  { id: 'erbil-f-01', name: 'Machko Chaikhana', city: 'Erbil', category: 'Food', rating: 4.9, image: '/assets/images/cha.jpeg', isPremium: false },

  // Sulaymaniyah
  { id: 'sulay-h-01', name: 'Amna Suraka (Red Prison)', city: 'Sulaymaniyah', category: 'Historical', rating: 4.9, image: '/assets/images/wiki_amna_suraka.jpg', isPremium: true },
  { id: 'sulay-h-02', name: 'Sulaimaniyah Bazaar', city: 'Sulaymaniyah', category: 'Historical', rating: 4.7, image: '/assets/images/place_sulaymaniyah_bazaar.jpg', isPremium: false },
  { id: 'sulay-n-01', name: 'Dukan Lake', city: 'Sulaymaniyah', category: 'Nature', rating: 4.8, image: '/assets/images/place_dukan_lake.jpg', isPremium: true },
  { id: 'sulay-w-01', name: 'Ahmed Awa Waterfall', city: 'Sulaymaniyah', category: 'Waterfalls', rating: 4.8, image: '/assets/images/place_ahmed_awa.jpg', isPremium: false },
  { id: 'sulay-a-01', name: 'Azmar Mountain Viewpoint', city: 'Sulaymaniyah', category: 'Activities', rating: 4.9, image: '/assets/images/hd_mountains.jpg', isPremium: false },

  // Duhok
  { id: 'duhok-h-01', name: 'Amedi (Amediye) old town', city: 'Duhok', category: 'Historical', rating: 5.0, image: '/assets/images/place_amedi.jpg', isPremium: true },
  { id: 'duhok-n-01', name: 'Duhok Dam', city: 'Duhok', category: 'Nature', rating: 4.6, image: '/assets/images/place_duhok_dam.jpg', isPremium: false },
  { id: 'duhok-r-01', name: 'Lalish (Yazidi Holy Temple)', city: 'Duhok', category: 'Religious', rating: 4.9, image: '/assets/images/place_lalish.jpg', isPremium: true },
  { id: 'duhok-f-01', name: 'Kebab Kawa', city: 'Duhok', category: 'Food', rating: 4.7, image: '/assets/images/hd_bazaar.jpg', isPremium: false },

  // Halabja
  { id: 'halabja-h-01', name: 'Halabja Monument & Memorial', city: 'Halabja', category: 'Historical', rating: 4.8, image: '/assets/images/place_halabja_monument.jpg', isPremium: false },
  { id: 'halabja-n-01', name: 'Hawraman', city: 'Halabja', category: 'Nature', rating: 4.9, image: '/assets/images/place_hawraman.jpg', isPremium: true },
];

export const cities = [
  { id: 'erbil', name: 'Erbil', description: 'Capital of Kurdistan Region' },
  { id: 'sulaymaniyah', name: 'Sulaymaniyah', description: 'Cultural and artistic hub' },
  { id: 'duhok', name: 'Duhok', description: 'Gateway to mountain nature' },
  { id: 'halabja', name: 'Halabja', description: 'City of peace and beauty' },
];

export const events = [
  { id: 'e1', title: 'Citadel Flavors Expo', location: 'Erbil Citadel', category: 'Food', date: 'Sep 20', month: 'Sep', day: '20' },
  { id: 'e2', title: 'Mountain Melodies', location: 'Sulaymaniyah', category: 'Music', date: 'Oct 05', month: 'Oct', day: '05' },
  { id: 'e3', title: 'Pomegranate Festival', location: 'Halabja', category: 'Culture', date: 'Nov 01', month: 'Nov', day: '01' },
  { id: 'e4', title: 'Newroz Fire Festival', location: 'All Cities', category: 'Culture', date: 'Mar 21', month: 'Mar', day: '21' },
];
