import 'dart:convert';

/// FastAPI returns `detail` as a [String] (HTTPException) or a [List] of
/// validation objects `{loc, msg, type}` (422). Passing a [List] to [Text]
/// throws and surfaces as a generic "network" error in many auth screens.
String messageFromFastApiBody(String body) {
  try {
    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) return 'Request failed';
    final detail = decoded['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) {
      final first = detail.first;
      if (first is Map && first['msg'] is String) {
        return first['msg'] as String;
      }
    }
    return 'Request failed';
  } catch (_) {
    return 'Request failed';
  }
}
