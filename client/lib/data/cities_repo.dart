import 'api_client.dart';
import 'models.dart';

class CitiesRepo {
  CitiesRepo({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<ApiCity>> list() async {
    final data = await _client.getJson('/api/cities/') as List;
    return data
        .map((e) => ApiCity.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<ApiCity> get(int id) async {
    final data =
        await _client.getJson('/api/cities/$id') as Map<String, dynamic>;
    return ApiCity.fromJson(data);
  }
}
