import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/map_spot_memory.dart';

/// Persists geo-tagged memories (JSON + local image paths).
class MapSpotMemoryStore {
  MapSpotMemoryStore._();
  static const _key = 'map_spot_memories_v1';

  static List<MapSpotMemory> _cache = [];
  static final ValueNotifier<int> revision = ValueNotifier<int>(0);

  static Future<void> hydrate() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) {
      _cache = [];
      revision.value++;
      return;
    }
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      _cache = list.map((e) => MapSpotMemory.fromJson(Map<String, dynamic>.from(e as Map))).toList(growable: false);
    } catch (_) {
      _cache = [];
    }
    revision.value++;
  }

  static List<MapSpotMemory> get items => List.unmodifiable(_cache);

  static Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(_cache.map((e) => e.toJson()).toList(growable: false));
    await prefs.setString(_key, raw);
    revision.value++;
  }

  static Future<void> upsert(MapSpotMemory m) async {
    final copy = [..._cache];
    final i = copy.indexWhere((e) => e.id == m.id);
    if (i >= 0) {
      copy[i] = m;
    } else {
      copy.add(m);
    }
    _cache = copy;
    await _persist();
  }

  static Future<void> remove(String id) async {
    _cache = _cache.where((e) => e.id != id).toList(growable: false);
    await _persist();
  }
}
