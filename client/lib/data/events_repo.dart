import 'api_client.dart';
import 'models.dart';

class EventsRepo {
  EventsRepo({ApiClient? client}) : _client = client ?? ApiClient();
  final ApiClient _client;

  Future<List<ApiEvent>> list({String? eventType}) async {
    final data = await _client.getJson(
      '/api/events/',
      query: eventType == null ? null : {'event_type': eventType},
    ) as List;
    return data
        .map((e) => ApiEvent.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
