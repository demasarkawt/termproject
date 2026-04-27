// lib/services/weather_service.dart
// Uses the completely free, no-API-key Open-Meteo API for real-time weather.
// Docs: https://open-meteo.com/en/docs

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CityWeather {
  final String city;
  final double tempC;
  final String description;
  final int weatherCode;
  final double windSpeed;
  final int humidity;

  const CityWeather({
    required this.city,
    required this.tempC,
    required this.description,
    required this.weatherCode,
    required this.windSpeed,
    required this.humidity,
  });
}

class WeatherService {
  // GPS coordinates for all four cities
  static const _cities = {
    'Erbil':           {'lat': 36.1901, 'lon': 44.0091},
    'Sulaymaniyah':    {'lat': 35.5600, 'lon': 45.4350},
    'Duhok':           {'lat': 36.8679, 'lon': 42.9891},
    'Halabja':         {'lat': 35.1733, 'lon': 45.9862},
  };

  static const _baseUrl = 'https://api.open-meteo.com/v1/forecast';

  /// Cache to avoid hammering the API every rebuild
  static final Map<String, CityWeather> _cache = {};
  static DateTime? _lastFetch;

  static bool get _cacheValid =>
      _lastFetch != null &&
      DateTime.now().difference(_lastFetch!) < const Duration(minutes: 15);

  static void clearCache() {
    _cache.clear();
    _lastFetch = null;
  }

  static Future<List<CityWeather>> fetchAll() async {
    if (_cacheValid && _cache.length == _cities.length) {
      return _cache.values.toList();
    }

    final results = <CityWeather>[];

    for (final entry in _cities.entries) {
      final city = entry.key;
      final lat = entry.value['lat']!;
      final lon = entry.value['lon']!;

      try {
        final uri = Uri.parse(_baseUrl).replace(queryParameters: {
          'latitude': lat.toString(),
          'longitude': lon.toString(),
          'current': 'temperature_2m,weathercode,windspeed_10m,relativehumidity_2m',
          'wind_speed_unit': 'kmh',
          'timezone': 'Asia/Baghdad',
        });

        final response = await http.get(
          uri,
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 8));

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final current = data['current'] as Map<String, dynamic>;

          final code = (current['weathercode'] as num).toInt();
          final temp = (current['temperature_2m'] as num).toDouble();
          final wind = (current['windspeed_10m'] as num).toDouble();
          final humidity = (current['relativehumidity_2m'] as num).toInt();

          final weather = CityWeather(
            city: city,
            tempC: temp,
            description: _descriptionFromCode(code),
            weatherCode: code,
            windSpeed: wind,
            humidity: humidity,
          );

          _cache[city] = weather;
          results.add(weather);
        }
      } catch (_) {
        // Fallback if network fails
        results.add(CityWeather(
          city: city,
          tempC: double.nan,
          description: 'Unavailable',
          weatherCode: -1,
          windSpeed: 0,
          humidity: 0,
        ));
      }
    }

    _lastFetch = DateTime.now();
    return results;
  }

  /// Maps WMO Weather Codes to human-readable descriptions
  static String _descriptionFromCode(int code) {
    if (code == 0) return 'Clear sky';
    if (code == 1) return 'Mainly clear';
    if (code == 2) return 'Partly cloudy';
    if (code == 3) return 'Overcast';
    if (code >= 45 && code <= 48) return 'Foggy';
    if (code >= 51 && code <= 55) return 'Drizzle';
    if (code >= 56 && code <= 57) return 'Freezing drizzle';
    if (code >= 61 && code <= 65) return 'Rain';
    if (code >= 66 && code <= 67) return 'Freezing rain';
    if (code >= 71 && code <= 77) return 'Snow';
    if (code >= 80 && code <= 82) return 'Rain showers';
    if (code >= 85 && code <= 86) return 'Snow showers';
    if (code >= 95 && code <= 99) return 'Thunderstorm';
    return 'Partly cloudy';
  }

  /// Maps WMO code to a matching Flutter icon
  static IconData iconFromCode(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny_rounded;
    if (code == 2) return Icons.wb_cloudy_outlined;
    if (code == 3) return Icons.cloud_rounded;
    if (code >= 45 && code <= 48) return Icons.foggy;
    if (code >= 51 && code <= 67) return Icons.grain_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 82) return Icons.umbrella_rounded;
    if (code >= 95 && code <= 99) return Icons.thunderstorm_rounded;
    return Icons.wb_cloudy_rounded;
  }

  /// Maps city to accent color based on weather feel
  static Color colorFromCode(int code) {
    if (code == 0 || code == 1) return const Color(0xFFF59E0B); // sunny gold
    if (code == 2 || code == 3) return const Color(0xFF64748B); // cloudy gray
    if (code >= 51 && code <= 67) return const Color(0xFF2563EB); // rainy blue
    if (code >= 71 && code <= 77) return const Color(0xFF7DD3FC); // snow light blue
    if (code >= 95 && code <= 99) return const Color(0xFF7C3AED); // thunder purple
    return const Color(0xFF1F5E37); // default green
  }
}
