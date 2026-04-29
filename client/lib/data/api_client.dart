import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;
  ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  ApiClient({http.Client? client, this.timeout = const Duration(seconds: 10)})
      : _http = client ?? http.Client();

  final http.Client _http;
  final Duration timeout;

  Future<dynamic> getJson(String path, {Map<String, dynamic>? query}) async {
    final uri = Uri.parse('$kBaseUrl$path').replace(
      queryParameters: query?.map((k, v) => MapEntry(k, '$v')),
    );
    try {
      final res = await _http.get(uri).timeout(timeout);
      if (res.statusCode < 200 || res.statusCode >= 300) {
        throw ApiException(res.statusCode, res.body);
      }
      if (res.body.isEmpty) return null;
      return json.decode(res.body);
    } on TimeoutException {
      throw ApiException(408, 'Request to $uri timed out');
    }
  }
}
