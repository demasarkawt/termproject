import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves the logged-in user's data across sessions.
class UserSession {
  static const _keyId = 'user_id';
  static const _keyName = 'user_name';
  static const _keyLevel = 'user_level';
  static const _keyToken = 'user_token';

  static int? _id;
  static String? _name;
  static int? _level;
  static String? _token;

  static int? get userId => _id;
  static String? get userName => _name;
  static int? get userLevel => _level;
  static String? get token => _token;
  static bool get isLoggedIn => _token != null && _id != null;

  /// Call once at app startup to restore a previous session.
  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt(_keyId);
    _name = prefs.getString(_keyName);
    _level = prefs.getInt(_keyLevel);
    _token = prefs.getString(_keyToken);
    return isLoggedIn;
  }

  /// Save session after login or register.
  static Future<void> save({
    required int id,
    required String name,
    required int level,
    required String token,
  }) async {
    _id = id;
    _name = name;
    _level = level;
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setInt(_keyLevel, level);
    await prefs.setString(_keyToken, token);
  }

  /// Clear session on logout.
  static Future<void> clear() async {
    _id = null;
    _name = null;
    _level = null;
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Auth header for API requests.
  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };
}
