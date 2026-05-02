// Polished cinematic Events screen.
// Drop into: lib/screens/events/events_screen.dart
 
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:go_router/go_router.dart';
 
import '../../config/api_config.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
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
      final response = await http.get(Uri.parse('$kBaseUrl/api/events/')).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _events = jsonDecode(response.body);
            _loading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _loading = false;
            _error = 'Failed to load events.';
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Connection error.';
        });
      }
    }
  }
 
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildGlowBlob(KurdishHeritageColors.sor.withOpacity(0.08), -100, 100, 400),
              _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.08), 300, 400, 300),
 
              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PressScale(
                                  onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                                  child: Glass(
                                    radius: 999,
                                    padding: const EdgeInsets.all(10),
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
                            RevealText(
                              'Upcoming\nEvents',
                              style: TextStyle(
                                color: ink,
                                fontWeight: FontWeight.w900,
                                fontSize: 44,
                                height: 1.05,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Experience live cultural festivals and events',
                              style: TextStyle(
                                color: ink.withOpacity(0.5),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
 
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 150),
                      sliver: _loading
                          ? const SliverFillRemaining(child: Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer)))
                          : _error != null
                              ? SliverFillRemaining(child: Center(child: Text(_error!, style: TextStyle(color: ink.withOpacity(0.4)))) )
                              : _events.isEmpty
                                  ? SliverFillRemaining(child: Center(child: Text('No cultural events scheduled.', style: TextStyle(color: ink.withOpacity(0.4)))))
                                  : SliverList(
                                      delegate: SliverChildBuilderDelegate(
                                        (context, i) => ScrollReveal(
                                          duration: Duration(milliseconds: Motion.md.inMilliseconds + (i.clamp(0, 8) * 40)),
                                          child: _EventCard(event: _events[i], isDark: isDark),
                                        ),
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
      },
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
}
 
class _EventCard extends StatelessWidget {
  final Map<String, dynamic> event;
  final bool isDark;
  const _EventCard({required this.event, required this.isDark});
 
  @override
  Widget build(BuildContext context) {
    final type = (event['event_type'] ?? 'CULTURE').toString().toUpperCase();
    final typeColor = _getTypeColor(type);
    final id = event['id'];
    final imageUrl = event['image_url'] as String?;
    final hasUrl = imageUrl != null && imageUrl.trim().isNotEmpty;
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: PressScale(
        onTap: id == null ? null : () => context.push('/events/$id'),
        child: Glass(
          radius: 30,
          opacity: isDark ? 0.05 : 0.03,
          borderOpacity: isDark ? 0.1 : 0.05,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(29)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Hero(
                    tag: 'event-cover-$id',
                    child: hasUrl
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            fadeInDuration: Motion.sm,
                            placeholder: (_, __) => _Placeholder(type: type, color: typeColor),
                            errorWidget: (_, __, ___) => _Placeholder(type: type, color: typeColor),
                          )
                        : _Placeholder(type: type, color: typeColor),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: typeColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: typeColor,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                        if (event['location'] != null)
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 14, color: ink.withOpacity(0.35)),
                              const SizedBox(width: 4),
                              Text(
                                '${event['location']}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: ink.withOpacity(0.4),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      event['title']?.toString() ?? '',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: ink,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (event['description'] != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        event['description'].toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: ink.withOpacity(0.6),
                          height: 1.5,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today_rounded, size: 14, color: KurdishHeritageColors.zer),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            event['end_date'] != null 
                              ? '${event['start_date']} — ${event['end_date']}' 
                              : '${event['start_date']}',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: ink.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_ios_rounded, size: 14, color: ink.withOpacity(0.2)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
 
class _Placeholder extends StatelessWidget {
  final String type;
  final Color color;
  const _Placeholder({required this.type, required this.color});
 
  @override
  Widget build(BuildContext context) {
    IconData ic = Icons.celebration_rounded;
    if (type == 'FOOD') ic = Icons.restaurant_rounded;
    if (type == 'MUSIC') ic = Icons.music_note_rounded;
 
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [KurdishHeritageColors.res, color.withOpacity(0.8)],
        ),
      ),
      child: Center(child: Icon(ic, size: 48, color: Colors.white.withOpacity(0.8))),
    );
  }
}
