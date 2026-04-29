import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../services/theme_service.dart';

/// Compact "16°C ☀" pill that fetches `/api/weather` once per location and
/// caches per (city_id) or (lat,lng) for the rest of the session.
class WeatherChip extends StatefulWidget {
  final int? cityId;
  final double? lat;
  final double? lng;
  final bool dense;

  const WeatherChip({
    super.key,
    this.cityId,
    this.lat,
    this.lng,
    this.dense = false,
  }) : assert(
          cityId != null || (lat != null && lng != null),
          'Pass cityId or lat+lng',
        );

  @override
  State<WeatherChip> createState() => _WeatherChipState();
}

class _WeatherChipState extends State<WeatherChip> {
  static final Map<String, _CachedWeather> _cache = {};
  static const _ttl = Duration(minutes: 8);

  _Weather? _data;
  bool _failed = false;

  String get _key => widget.cityId != null
      ? 'c:${widget.cityId}'
      : 'g:${widget.lat!.toStringAsFixed(3)},${widget.lng!.toStringAsFixed(3)}';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final cached = _cache[_key];
    if (cached != null && DateTime.now().difference(cached.fetchedAt) < _ttl) {
      setState(() => _data = cached.data);
      return;
    }
    try {
      final qp = <String, String>{};
      if (widget.cityId != null) qp['city_id'] = widget.cityId.toString();
      if (widget.lat != null) qp['lat'] = widget.lat.toString();
      if (widget.lng != null) qp['lng'] = widget.lng.toString();

      final uri = Uri.parse('$kBaseUrl/api/weather').replace(
        queryParameters: qp,
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode >= 400) throw Exception('HTTP ${resp.statusCode}');
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      final data = _Weather(
        tempC: (json['temperature_c'] as num?)?.toDouble(),
        code: json['weather_code'] as int? ?? 0,
        description: json['description'] as String? ?? '',
      );
      _cache[_key] = _CachedWeather(data, DateTime.now());
      if (!mounted) return;
      setState(() => _data = data);
    } catch (_) {
      if (!mounted) return;
      setState(() => _failed = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_failed || _data == null || _data!.tempC == null) {
      return const SizedBox.shrink();
    }

    final dense = widget.dense;
    final pad = dense
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 10, vertical: 5);
    final fontSize = dense ? 11.0 : 12.0;
    final iconSize = dense ? 12.0 : 14.0;

    return Container(
      padding: pad,
      decoration: BoxDecoration(
        color: KurdishHeritageColors.zer.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(KurdishHeritageRadii.pill),
        border: Border.all(
          color: KurdishHeritageColors.zer.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _iconFor(_data!.code),
            size: iconSize,
            color: KurdishHeritageColors.zer,
          ),
          const SizedBox(width: 4),
          Text(
            '${_data!.tempC!.round()}°C',
            style: TextStyle(
              color: KurdishHeritageColors.zer,
              fontWeight: FontWeight.w700,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(int code) {
    if (code == 0 || code == 1) return Icons.wb_sunny_rounded;
    if (code == 2 || code == 3) return Icons.cloud_rounded;
    if (code == 45 || code == 48) return Icons.foggy;
    if (code >= 51 && code <= 57) return Icons.grain_rounded;
    if (code >= 61 && code <= 67) return Icons.water_drop_rounded;
    if (code >= 71 && code <= 77) return Icons.ac_unit_rounded;
    if (code >= 80 && code <= 86) return Icons.water_drop_rounded;
    if (code >= 95) return Icons.flash_on_rounded;
    return Icons.cloud_rounded;
  }
}

class _Weather {
  final double? tempC;
  final int code;
  final String description;
  _Weather({required this.tempC, required this.code, required this.description});
}

class _CachedWeather {
  final _Weather data;
  final DateTime fetchedAt;
  _CachedWeather(this.data, this.fetchedAt);
}
