import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:termproject/config/api_config.dart';
import 'package:termproject/services/theme_service.dart';

class EventDetailScreen extends StatefulWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  Map<String, dynamic>? _event;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final id = int.tryParse(widget.eventId);
    if (id == null) {
      setState(() {
        _loading = false;
        _error = 'Invalid event.';
      });
      return;
    }
    try {
      final res = await http.get(Uri.parse('$kBaseUrl/api/events/$id'));
      if (!mounted) return;
      if (res.statusCode == 200) {
        setState(() {
          _event = jsonDecode(res.body) as Map<String, dynamic>;
          _loading = false;
          _error = null;
        });
      } else if (res.statusCode == 404) {
        setState(() {
          _loading = false;
          _error = 'This event is no longer available.';
        });
      } else {
        setState(() {
          _loading = false;
          _error = 'Could not load event.';
        });
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
      listenable: ThemeService(),
      builder: (context, _) {
        final isDark = ThemeService().isDark;
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildGlowBlob(KurdishHeritageColors.kesk.withValues(alpha: 0.12), -80, -40, 360),
              _buildGlowBlob(KurdishHeritageColors.sor.withValues(alpha: 0.08), 220, 520, 320),
              SafeArea(
                child: Stack(
                  children: [
                    _loading
                        ? const Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer))
                        : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: isDark ? Colors.white70 : KurdishHeritageColors.res)),
                                  const SizedBox(height: 24),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: KurdishHeritageColors.zer, foregroundColor: KurdishHeritageColors.res),
                                    onPressed: () => context.pop(),
                                    child: const Text('Go back'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _event == null
                            ? const SizedBox.shrink()
                            : CustomScrollView(
                                physics: const BouncingScrollPhysics(),
                                slivers: [
                                  SliverToBoxAdapter(child: _buildHero(_event!, isDark)),
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 48),
                                    sliver: SliverToBoxAdapter(child: _buildBody(_event!, isDark)),
                                  ),
                                ],
                              ),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: Material(
                        color: Colors.black.withValues(alpha: _loading ? 0.4 : 0.35),
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                          onPressed: () => context.pop(),
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

  Widget _buildHero(Map<String, dynamic> event, bool isDark) {
    final type = (event['event_type'] ?? 'CULTURE').toString().toUpperCase();
    final typeColor = _getTypeColor(type);
    final id = event['id'];
    final imageUrl = event['image_url'] as String?;
    final hasUrl = imageUrl != null && imageUrl.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(32), bottomRight: Radius.circular(32)),
      child: SizedBox(
        height: 280,
        width: double.infinity,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: 'event-cover-$id',
              child: Material(
                color: Colors.transparent,
                child: hasUrl
                    ? CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        fadeInDuration: const Duration(milliseconds: 280),
                        placeholder: (_, __) => Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [
                              KurdishHeritageColors.res.withValues(alpha: 0.95),
                              typeColor.withValues(alpha: 0.85),
                            ]),
                          ),
                          child: const Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer)),
                        ),
                        errorWidget: (_, __, ___) => _ImagePlaceholder(type: type, typeColor: typeColor),
                      )
                    : _ImagePlaceholder(type: type, typeColor: typeColor),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.55),
                    Colors.black.withValues(alpha: 0.05),
                  ],
                  stops: const [0.0, 0.55],
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 28,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.95), borderRadius: BorderRadius.circular(10)),
                    child: Text(type, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    event['title']?.toString() ?? '',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                      color: Colors.white,
                      height: 1.05,
                      shadows: [Shadow(blurRadius: 12, color: Colors.black54)],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(Map<String, dynamic> event, bool isDark) {
    final dateLine = event['end_date'] != null
        ? '${event['start_date']} — ${event['end_date']}'
        : '${event['start_date'] ?? ''}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _infoRow(Icons.calendar_month_rounded, 'Dates', dateLine, isDark),
        const SizedBox(height: 16),
        if (event['location'] != null) ...[
          _infoRow(Icons.location_on_rounded, 'Where', '${event['location']}', isDark),
          const SizedBox(height: 24),
        ],
        Text(
          'About',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: isDark ? Colors.white.withValues(alpha: 0.45) : Colors.black.withValues(alpha: 0.45),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _descriptionText(event),
          style: TextStyle(
            fontSize: 16,
            height: 1.65,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white.withValues(alpha: 0.9) : KurdishHeritageColors.res.withValues(alpha: 0.88),
          ),
        ),
      ],
    );
  }

  Widget _infoRow(IconData icon, String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : KurdishHeritageColors.zer.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: KurdishHeritageColors.zer, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: isDark ? Colors.white.withValues(alpha: 0.42) : Colors.black.withValues(alpha: 0.42),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: isDark ? Colors.white : KurdishHeritageColors.res,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlowBlob(Color color, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: color, blurRadius: 90, spreadRadius: 40)],
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

String _descriptionText(Map<String, dynamic> event) {
  final raw = event['description'];
  final s = raw == null ? '' : raw.toString().trim();
  if (s.isEmpty) {
    return 'No description has been published for this event yet.';
  }
  return s;
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder({required this.type, required this.typeColor});

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
            KurdishHeritageColors.res.withValues(alpha: 0.94),
            typeColor.withValues(alpha: 0.88),
          ],
        ),
      ),
      child: Center(
        child: Icon(ic, size: 88, color: Colors.white.withValues(alpha: 0.92)),
      ),
    );
  }
}
