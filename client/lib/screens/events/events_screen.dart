import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
import 'package:termproject/config/api_config.dart';
import 'package:termproject/services/theme_service.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  List<dynamic> _events = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    try {
      final response = await http.get(Uri.parse('$kBaseUrl/api/events/'));
      if (response.statusCode == 200) {
        setState(() {
          _events = jsonDecode(response.body);
          _loading = false;
        });
      } else {
        setState(() { _loading = false; _error = 'Failed to load events.'; });
      }
    } catch (_) {
      setState(() { _loading = false; _error = 'Connection error.'; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Glow Blobs ──────────────────────────────────────────
          _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.1), -100, 100, 400),
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.1), 300, 400, 300),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ───────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.arrow_back_ios_new_rounded, color: KurdishHeritageColors.zer, size: 18),
                              ),
                            ),
                            const Text(
                              'TRADITIONS',
                              style: TextStyle(
                                color: KurdishHeritageColors.zer,
                                fontWeight: FontWeight.w900,
                                fontSize: 14,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Upcoming\nEvents',
                          style: TextStyle(
                            color: isDark ? Colors.white : KurdishHeritageColors.res,
                            fontWeight: FontWeight.w900,
                            fontSize: 36,
                            height: 1.1,
                            letterSpacing: -1.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Experience the heartbeat of Kurdistan',
                          style: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Events List ──────────────────────────────────────────────
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 40, 24, 150),
                  sliver: _loading
                      ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer)))
                      : _error != null
                          ? SliverFillRemaining(child: Center(child: Text(_error!, style: const TextStyle(color: Colors.grey))))
                          : _events.isEmpty
                              ? const SliverFillRemaining(child: Center(child: Text('No cultural events scheduled.', style: TextStyle(color: Colors.grey))))
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, i) => _buildEventCard(_events[i], isDark),
                                    childCount: _events.length,
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowBlob(Color color, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event, bool isDark) {
    final type = (event['event_type'] ?? 'CULTURE').toUpperCase();
    final typeColor = _getTypeColor(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: typeColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: typeColor, letterSpacing: 1)),
              ),
              if (event['location'] != null)
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3)),
                    const SizedBox(width: 4),
                    Text(event['location'], style: TextStyle(fontSize: 12, color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), fontWeight: FontWeight.bold)),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(event['title'] ?? '', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : KurdishHeritageColors.res, letterSpacing: -0.5)),
          if (event['description'] != null) ...[
            const SizedBox(height: 12),
            Text(event['description'], style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54, height: 1.6)),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              Icon(Icons.calendar_today_rounded, size: 14, color: KurdishHeritageColors.zer),
              const SizedBox(width: 8),
              Text(
                event['end_date'] != null ? '${event['start_date']} — ${event['end_date']}' : event['start_date'],
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : KurdishHeritageColors.res.withOpacity(0.7)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'FOOD': return KurdishHeritageColors.sor;
      case 'MUSIC': return const Color(0xFF1E3A8A);
      case 'CULTURE': return KurdishHeritageColors.kesk;
      default: return KurdishHeritageColors.zer;
    }
  }
}
