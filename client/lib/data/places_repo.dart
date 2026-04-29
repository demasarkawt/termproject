import 'api_client.dart';
import 'models.dart';

class PlacesRepo {
  PlacesRepo({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<ApiPlace>> list({
    int? cityId,
    String? category,
    bool? hasCoords,
    int limit = 200,
    int offset = 0,
  }) async {
    final query = <String, dynamic>{
      'limit': limit,
      'offset': offset,
    };
    if (cityId != null) query['city_id'] = cityId;
    if (category != null) query['category'] = category;
    if (hasCoords == true) query['has_coords'] = 'true';
    final data = await _client.getJson('/api/places/', query: query) as List;
    return data
        .map((e) => ApiPlace.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<ApiPlace>> trending() async {
    final data = await _client.getJson('/api/places/trending') as List;
    return data
        .map((e) => ApiPlace.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApiPlace> get(int id) async {
    final data =
        await _client.getJson('/api/places/$id') as Map<String, dynamic>;
    return ApiPlace.fromJson(data);
  }
}
