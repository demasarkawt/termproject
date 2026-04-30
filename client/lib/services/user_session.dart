import 'package:shared_preferences/shared_preferences.dart';

/// Stores and retrieves the logged-in user's data across sessions.
class UserSession {
  static const _keyId = 'user_id';
  static const _keyName = 'user_name';
  static const _keyLevel = 'user_level';
  static const _keyToken = 'user_token';
  static const _keyEmail = 'user_email';
  static const _keyAvatar = 'avatar_path';

  static int? _id;
  static String? _name;
  static int? _level;
  static String? _token;
  static String? _email;
  static String? _avatarPath;

  static int? get userId => _id;
  static String? get userName => _name;
  static int? get userLevel => _level;
  static String? get token => _token;
  static String? get userEmail => _email;
  /// Local profile photo path (device storage); not synced to server.
  static String? get avatarLocalPath => _avatarPath;
  static bool get isLoggedIn => _token != null && _id != null;

  /// Call once at app startup to restore a previous session.
  static Future<bool> load() async {
    final prefs = await SharedPreferences.getInstance();
    _id = prefs.getInt(_keyId);
    _name = prefs.getString(_keyName);
    _level = prefs.getInt(_keyLevel);
    _token = prefs.getString(_keyToken);
    _email = prefs.getString(_keyEmail);
    _avatarPath = prefs.getString(_keyAvatar);
    return isLoggedIn;
  }

  /// Save session after login or register.
  static Future<void> save({
    required int id,
    required String name,
    required int level,
    required String token,
    String? email,
  }) async {
    _id = id;
    _name = name;
    _level = level;
    _token = token;
    if (email != null) _email = email;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyId, id);
    await prefs.setString(_keyName, name);
    await prefs.setInt(_keyLevel, level);
    await prefs.setString(_keyToken, token);
    if (email != null) await prefs.setString(_keyEmail, email);
  }

  /// After PATCH /me from server.
  static Future<void> updateLocalProfile({String? name, String? email}) async {
    final prefs = await SharedPreferences.getInstance();
    if (name != null) {
      _name = name;
      await prefs.setString(_keyName, name);
    }
    if (email != null) {
      _email = email;
      await prefs.setString(_keyEmail, email);
    }
  }

  static Future<void> setAvatarLocalPath(String? path) async {
    _avatarPath = path;
    final prefs = await SharedPreferences.getInstance();
    if (path == null || path.isEmpty) {
      await prefs.remove(_keyAvatar);
    } else {
      await prefs.setString(_keyAvatar, path);
    }
  }

  /// Clear session on logout.
  static Future<void> clear() async {
    _id = null;
    _name = null;
    _level = null;
    _token = null;
    _email = null;
    _avatarPath = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  /// Auth header for API requests.
  static Map<String, String> get authHeaders => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

}
