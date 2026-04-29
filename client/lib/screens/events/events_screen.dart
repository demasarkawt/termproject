import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
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
        setState(() {
          _loading = false;
          _error = 'Failed to load events.';
        });
      }
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Connection error.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final isDark = ThemeService().isDark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildGlowBlob(KurdishHeritageColors.sor.withValues(alpha: 0.1), -100, 100, 400),
              _buildGlowBlob(KurdishHeritageColors.kesk.withValues(alpha: 0.1), 300, 400, 300),

              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
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
                                      color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: KurdishHeritageColors.zer, size: 18),
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
                              'Experience live events near your routes',
                              style: TextStyle(
                                color: isDark ? Colors.white.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.5),
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

  Widget _buildEventCard(Map<String, dynamic> event, bool isDark) {
    final type = (event['event_type'] ?? 'CULTURE').toString().toUpperCase();
    final typeColor = _getTypeColor(type);
    final id = event['id'];
    final imageUrl = event['image_url'] as String?;
    final hasUrl = imageUrl != null && imageUrl.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(30),
          onTap: id == null ? null : () => context.push('/events/$id'),
          child: Ink(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
            ),
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
                              fadeInDuration: const Duration(milliseconds: 240),
                              placeholder: (_, __) => _CardImagePlaceholder(type: type, typeColor: typeColor),
                              errorWidget: (_, __, ___) => _CardImagePlaceholder(type: type, typeColor: typeColor),
                            )
                          : _CardImagePlaceholder(type: type, typeColor: typeColor),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(10)),
                            child: Text(type, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: typeColor, letterSpacing: 1)),
                          ),
                          if (event['location'] != null)
                            Flexible(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.location_on_rounded, size: 14, color: isDark ? Colors.white.withValues(alpha: 0.35) : Colors.black.withValues(alpha: 0.35)),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      '${event['location']}',
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? Colors.white.withValues(alpha: 0.38) : Colors.black.withValues(alpha: 0.38),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        event['title']?.toString() ?? '',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : KurdishHeritageColors.res, letterSpacing: -0.5),
                      ),
                      if (event['description'] != null && event['description'].toString().trim().isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text(
                          event['description'].toString(),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54, height: 1.55),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_rounded, size: 14, color: KurdishHeritageColors.zer),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event['end_date'] != null ? '${event['start_date']} — ${event['end_date']}' : '${event['start_date']}',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : KurdishHeritageColors.res.withValues(alpha: 0.75)),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: KurdishHeritageColors.zer),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'FOOD':
        return KurdishHeritageColors.sor;
      case 'MUSIC':
        return const Color(0xFF1E3A8A);
      case 'CULTURE':
        return KurdishHeritageColors.kesk;
      default:
        return KurdishHeritageColors.zer;
    }
  }
}

class _CardImagePlaceholder extends StatelessWidget {
  const _CardImagePlaceholder({required this.type, required this.typeColor});

  final String type;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    IconData ic;
    switch (type) {
      case 'FOOD':
        ic = Icons.restaurant_rounded;
        break;
      case 'MUSIC':
        ic = Icons.music_note_rounded;
        break;
      default:
        ic = Icons.celebration_rounded;
    }
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KurdishHeritageColors.res.withValues(alpha: 0.92),
            typeColor.withValues(alpha: 0.82),
          ],
        ),
      ),
      child: Center(child: Icon(ic, size: 56, color: Colors.white.withValues(alpha: 0.88))),
    );
  }
}
