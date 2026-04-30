import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'user_session.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/api/users/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userData = data['user'];
      await UserSession.save(
        id: userData['id'],
        name: userData['name'],
        level: userData['level'] ?? 1,
        token: data['access_token'],
        email: userData['email'],
      );
      return data;
    } else {
      throw Exception(_parseError(response.body));
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$kBaseUrl/api/users/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final userData = data['user'];
      await UserSession.save(
        id: userData['id'],
        name: userData['name'],
        level: userData['level'] ?? 1,
        token: data['access_token'],
        email: userData['email'],
      );
      return data;
    } else {
      throw Exception(_parseError(response.body));
    }
  }

  static String _parseError(String body) {
    try {
      final data = jsonDecode(body);
      if (data['detail'] is String) return data['detail'];
      if (data['detail'] is List) return data['detail'][0]['msg'];
      return 'Authentication failed';
    } catch (_) {
      return 'Authentication failed';
    }
  }
}
