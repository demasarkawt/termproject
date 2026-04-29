import 'map_travel_poi.dart';

/// Curated travel POIs around **Erbil** (hotels, dining, fuel, key sights).
/// Names/locations follow common listings and map data used across travel guides;
/// coordinates approximate OpenStreetMap placements for routing previews.
const List<TravelPoi> kMapTravelPoisSeed = [
  // Hotels & stays
  TravelPoi(
    id: 'tp-divan-erbil',
    name: 'Divan Hotel Erbil',
    kind: TravelPoiKind.hotel,
    lat: 36.19197,
    lon: 44.01286,
    address: 'Gulan Street area',
  ),
  TravelPoi(
    id: 'tp-rotana-erbil',
    name: 'Erbil Rotana',
    kind: TravelPoiKind.hotel,
    lat: 36.17362,
    lon: 43.96704,
    address: '60m Street corridor',
  ),
  TravelPoi(
    id: 'tp-cristal-erbil',
    name: 'Cristal Erbil Hotel',
    kind: TravelPoiKind.hotel,
    lat: 36.1649,
    lon: 44.0098,
    address: 'North Erbil',
  ),
  TravelPoi(
    id: 'tp-millennium-erbil',
    name: 'Copthorne Hotel Baranan',
    kind: TravelPoiKind.hotel,
    lat: 36.1882,
    lon: 43.9985,
    address: 'Near Sami Park',
  ),
  TravelPoi(
    id: 'tp-noble-erbil',
    name: 'Noble Hotel',
    kind: TravelPoiKind.hotel,
    lat: 36.184,
    lon: 44.008,
    address: 'Central Erbil',
  ),

  // Restaurants & cafés
  TravelPoi(
    id: 'tp-abu-shihab',
    name: 'Abu Shihab Restaurant',
    kind: TravelPoiKind.restaurant,
    lat: 36.1928,
    lon: 44.0035,
    address: 'Traditional grills',
  ),
  TravelPoi(
    id: 'tp-machko',
    name: 'Machko Chaikhana',
    kind: TravelPoiKind.restaurant,
    lat: 36.1895,
    lon: 44.0048,
    address: 'Tea house classics',
  ),
  TravelPoi(
    id: 'tp-nali-saray',
    name: 'Nali Saray Restaurant',
    kind: TravelPoiKind.restaurant,
    lat: 36.186,
    lon: 44.013,
    address: 'Local Kurdish fare',
  ),
  TravelPoi(
    id: 'tp-dawa2',
    name: 'Dawa 2 Restaurant',
    kind: TravelPoiKind.restaurant,
    lat: 36.181,
    lon: 44.019,
    address: 'Family dining',
  ),
  TravelPoi(
    id: 'tp-kebab-yasin',
    name: 'Kebab Yasin',
    kind: TravelPoiKind.restaurant,
    lat: 36.1905,
    lon: 43.997,
    address: 'Quick kebab stop',
  ),
  TravelPoi(
    id: 'tp-italian-village',
    name: 'Italian Village Restaurant',
    kind: TravelPoiKind.restaurant,
    lat: 36.1768,
    lon: 43.982,
    address: 'International options',
  ),
  TravelPoi(
    id: 'tp-chai-60',
    name: '60m Street Shawarma Row',
    kind: TravelPoiKind.restaurant,
    lat: 36.1745,
    lon: 43.971,
    address: 'Late-night eats',
  ),

  // Fuel & road trip
  TravelPoi(
    id: 'tp-shell-gulan',
    name: 'Shell — Gulan Road',
    kind: TravelPoiKind.fuel,
    lat: 36.194,
    lon: 44.015,
    address: 'Fuel & convenience',
  ),
  TravelPoi(
    id: 'tp-total-ring',
    name: 'Total Energies — Ring Road',
    kind: TravelPoiKind.fuel,
    lat: 36.168,
    lon: 43.995,
    address: 'West approach',
  ),
  TravelPoi(
    id: 'tp-petrol-ankawa',
    name: 'Fuel station — Ankawa',
    kind: TravelPoiKind.fuel,
    lat: 36.227,
    lon: 43.982,
    address: 'Near airport road',
  ),
  TravelPoi(
    id: 'tp-fuel-100m',
    name: 'Gas station — 100m Street',
    kind: TravelPoiKind.fuel,
    lat: 36.179,
    lon: 43.988,
    address: 'Central fill-up',
  ),

  // Iconic sights (duplicate awareness with PlaceRepo — still shown as travel pins)
  TravelPoi(
    id: 'tp-citadel-pin',
    name: 'Erbil Citadel (UNESCO)',
    kind: TravelPoiKind.sight,
    lat: 36.19125,
    lon: 43.9929,
    address: 'Historic citadel mound',
  ),
  TravelPoi(
    id: 'tp-qaysari',
    name: 'Qaysari Bazaar entrance',
    kind: TravelPoiKind.sight,
    lat: 36.1918,
    lon: 43.9926,
    address: 'Souqs & textiles',
  ),
  TravelPoi(
    id: 'tp-jalil-mosque',
    name: 'Jalil Khayat Mosque',
    kind: TravelPoiKind.sight,
    lat: 36.1824,
    lon: 43.997,
    address: 'Landmark mosque',
  ),
  TravelPoi(
    id: 'tp-sami-park',
    name: 'Sami Abdulrahman Park',
    kind: TravelPoiKind.sight,
    lat: 36.1872,
    lon: 44.0058,
    address: 'Green city park',
  ),

  // Shopping / malls (travel utility)
  TravelPoi(
    id: 'tp-family-mall',
    name: 'Family Mall',
    kind: TravelPoiKind.shop,
    lat: 36.178,
    lon: 44.021,
    address: 'Retail & food court',
  ),
  TravelPoi(
    id: 'tp-mega-mall',
    name: 'Megal Mall Erbil',
    kind: TravelPoiKind.shop,
    lat: 36.171,
    lon: 44.028,
    address: 'Shopping stop',
  ),
];
