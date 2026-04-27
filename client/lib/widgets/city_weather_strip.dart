// lib/widgets/city_weather_strip.dart
// Premium live-weather widget for Kurdistan Go.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../services/weather_service.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Public widget
// ─────────────────────────────────────────────────────────────────────────────
class CityWeatherStrip extends StatefulWidget {
  const CityWeatherStrip({super.key});

  @override
  State<CityWeatherStrip> createState() => _CityWeatherStripState();
}

class _CityWeatherStripState extends State<CityWeatherStrip>
    with SingleTickerProviderStateMixin {
  List<CityWeather>? _weather;
  bool _loading = true;
  late final AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _load();
  }

  @override
  void dispose() {
    _shimmerCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final data = await WeatherService.fetchAll();
      if (mounted) setState(() { _weather = data; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Header row ────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              // Pulsing dot
              _PulseDot(),
              const SizedBox(width: 8),
              const Text(
                'Live Weather',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF22C55E).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFF22C55E).withOpacity(0.25),
                  ),
                ),
                child: const Text(
                  'REAL-TIME',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF16A34A),
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  WeatherService.clearCache();
                  _load();
                },
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F5E37).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    size: 16,
                    color: Color(0xFF1F5E37),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Cards ─────────────────────────────────────────────────────────
        SizedBox(
          height: 148,
          child: _loading
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 4,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _ShimmerCard(
                    animation: _shimmerCtrl,
                  ),
                )
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: (_weather ?? []).length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, i) => _WeatherCard(
                    weather: _weather![i],
                  ),
                ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Premium Weather Card
// ─────────────────────────────────────────────────────────────────────────────
class _WeatherCard extends StatelessWidget {
  final CityWeather weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    final isNaN = weather.tempC.isNaN;
    final color = WeatherService.colorFromCode(weather.weatherCode);
    final icon = WeatherService.iconFromCode(weather.weatherCode);
    final gradients = _gradientsForCode(weather.weatherCode);

    return Container(
      width: 152,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradients,
        ),
        boxShadow: [
          BoxShadow(
            color: gradients.first.withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Large decorative icon in background
          Positioned(
            top: -10,
            right: -10,
            child: Icon(
              icon,
              size: 90,
              color: Colors.white.withOpacity(0.10),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // City name
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        weather.city.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.80),
                          letterSpacing: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // Temperature — big hero number
                Text(
                  isNaN ? '—°' : '${weather.tempC.round()}°',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 48,
                    color: Colors.white,
                    height: 1.0,
                    letterSpacing: -2,
                  ),
                ),

                // Condition text
                Text(
                  weather.description,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.85),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                // Stats row
                if (!isNaN)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.air_rounded,
                          size: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${weather.windSpeed.round()}km/h',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          width: 1,
                          height: 10,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        Icon(
                          Icons.water_drop_rounded,
                          size: 11,
                          color: Colors.white.withOpacity(0.8),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${weather.humidity}%',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _gradientsForCode(int code) {
    if (code == 0 || code == 1) {
      // Sunny — warm golden-orange
      return const [Color(0xFFF97316), Color(0xFFFBBF24)];
    }
    if (code == 2) {
      // Partly cloudy — teal-blue
      return const [Color(0xFF0EA5E9), Color(0xFF38BDF8)];
    }
    if (code == 3) {
      // Overcast — steel blue-gray
      return const [Color(0xFF475569), Color(0xFF64748B)];
    }
    if (code >= 45 && code <= 48) {
      // Fog — muted lavender
      return const [Color(0xFF7C3AED), Color(0xFFA78BFA)];
    }
    if (code >= 51 && code <= 67) {
      // Rain — deep blue
      return const [Color(0xFF1D4ED8), Color(0xFF2563EB)];
    }
    if (code >= 71 && code <= 77) {
      // Snow — icy light blue
      return const [Color(0xFF0284C7), Color(0xFF7DD3FC)];
    }
    if (code >= 80 && code <= 82) {
      // Showers — navy
      return const [Color(0xFF1E40AF), Color(0xFF3B82F6)];
    }
    if (code >= 95 && code <= 99) {
      // Thunder — deep purple
      return const [Color(0xFF4C1D95), Color(0xFF7C3AED)];
    }
    // Default — Kurdistan green
    return const [Color(0xFF1F5E37), Color(0xFF16A34A)];
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shimmer loading card
// ─────────────────────────────────────────────────────────────────────────────
class _ShimmerCard extends StatelessWidget {
  final AnimationController animation;
  const _ShimmerCard({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        final shimmer = math.sin(animation.value * 2 * math.pi) * 0.5 + 0.5;
        return Container(
          width: 152,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color.lerp(
                  const Color(0xFFE2E8F0),
                  const Color(0xFFF1F5F9),
                  shimmer,
                )!,
                Color.lerp(
                  const Color(0xFFF1F5F9),
                  const Color(0xFFE2E8F0),
                  shimmer,
                )!,
              ],
            ),
          ),
          padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _shimmerLine(width: 70, height: 10),
              _shimmerLine(width: 52, height: 40),
              _shimmerLine(width: 90, height: 10),
              _shimmerLine(width: 110, height: 24, radius: 999),
            ],
          ),
        );
      },
    );
  }

  Widget _shimmerLine({
    required double width,
    required double height,
    double radius = 8,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated pulsing green dot
// ─────────────────────────────────────────────────────────────────────────────
class _PulseDot extends StatefulWidget {
  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
    _scale = Tween<double>(begin: 0.8, end: 1.4).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFF22C55E),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF22C55E).withOpacity(0.5),
              blurRadius: 6,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}
