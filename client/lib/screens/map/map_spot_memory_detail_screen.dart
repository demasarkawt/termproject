import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../models/map_spot_memory.dart';
import '../../services/map_spot_memory_store.dart';
import '../../services/theme_service.dart';

/// Full-screen gallery + title, description, and “my thoughts” for one memory.
class MapSpotMemoryDetailScreen extends StatefulWidget {
  const MapSpotMemoryDetailScreen({super.key, required this.memoryId});

  final String memoryId;

  @override
  State<MapSpotMemoryDetailScreen> createState() => _MapSpotMemoryDetailScreenState();
}

class _MapSpotMemoryDetailScreenState extends State<MapSpotMemoryDetailScreen> {
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  MapSpotMemory? get _memory {
    try {
      return MapSpotMemoryStore.items.firstWhere((e) => e.id == widget.memoryId);
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmDelete(MapSpotMemory m) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete this memory?'),
        content: const Text('This removes the pin and photos from this device.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    try {
      final docs = await getApplicationDocumentsDirectory();
      final dir = Directory(p.join(docs.path, 'spot_memories', m.id));
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {}

    await MapSpotMemoryStore.remove(m.id);
    if (!mounted) return;
    context.pop();
  }

  String _formatDate(DateTime d) {
    const mo = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${mo[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;
    final m = _memory;

    if (m == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => context.pop()),
        ),
        body: const Center(child: Text('Memory not found.')),
      );
    }

    final images = m.imagePaths.where((path) => File(path).existsSync()).toList();
    final topPad = MediaQuery.paddingOf(context).top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: images.isEmpty ? 220 : 320,
                  width: double.infinity,
                  child: images.isEmpty
                      ? ColoredBox(
                          color: KurdishHeritageColors.zer.withValues(alpha: 0.35),
                          child: const Center(child: Icon(Icons.photo_camera_rounded, size: 72, color: Colors.white54)),
                        )
                      : PageView.builder(
                          controller: _pageCtrl,
                          itemCount: images.length,
                          itemBuilder: (ctx, i) => Image.file(
                            File(images[i]),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => ColoredBox(
                              color: KurdishHeritageColors.zer.withValues(alpha: 0.35),
                              child: const Center(
                                child: Icon(Icons.broken_image_outlined, size: 64, color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  top: topPad + 4,
                  left: 8,
                  child: Material(
                    color: Colors.black38,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                      onPressed: () => context.pop(),
                    ),
                  ),
                ),
                Positioned(
                  top: topPad + 4,
                  right: 8,
                  child: Material(
                    color: Colors.black38,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                      onPressed: () => _confirmDelete(m),
                    ),
                  ),
                ),
                if (images.length > 1)
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: SmoothPageIndicator(
                        controller: _pageCtrl,
                        count: images.length,
                        effect: const WormEffect(
                          dotHeight: 8,
                          dotWidth: 8,
                          activeDotColor: Colors.white,
                          dotColor: Color(0x88FFFFFF),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                m.title,
                style: TextStyle(
                  fontSize: 26,
                  height: 1.2,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : KurdishHeritageColors.res,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 12),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(_formatDate(m.createdAt), style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Colors.grey.shade600)),
                  const SizedBox(width: 16),
                  Icon(Icons.place_rounded, size: 16, color: KurdishHeritageColors.zer),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${m.lat.toStringAsFixed(5)}, ${m.lng.toStringAsFixed(5)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: Colors.grey.shade700),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (m.description.isNotEmpty)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(22, 8, 22, 12),
              sliver: SliverToBoxAdapter(
                child: _SectionCard(
                  icon: Icons.notes_rounded,
                  title: 'Description',
                  child: Text(
                    m.description,
                    style: TextStyle(
                      height: 1.5,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white70 : KurdishHeritageColors.res.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ),
            ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 40),
            sliver: SliverToBoxAdapter(
              child: _SectionCard(
                icon: Icons.auto_awesome_rounded,
                title: 'My thoughts',
                highlight: true,
                child: Text(
                  m.thoughts.isEmpty
                      ? 'No notes yet — next time, jot what made this spot special.'
                      : m.thoughts,
                  style: TextStyle(
                    height: 1.55,
                    fontSize: 16,
                    fontStyle: m.thoughts.isEmpty ? FontStyle.italic : FontStyle.normal,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.amber.shade50 : KurdishHeritageColors.res.withValues(alpha: 0.92),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
    this.highlight = false,
  });

  final IconData icon;
  final String title;
  final Widget child;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeService().isDark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: highlight
            ? KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.18 : 0.2)
            : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.grey.shade100),
        border: Border.all(
          color: highlight ? KurdishHeritageColors.zer.withValues(alpha: 0.45) : Colors.transparent,
        ),
        boxShadow: highlight
            ? [BoxShadow(color: KurdishHeritageColors.zer.withValues(alpha: 0.12), blurRadius: 16, offset: const Offset(0, 4))]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: KurdishHeritageColors.zer),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  letterSpacing: 0.4,
                  color: isDark ? Colors.white70 : KurdishHeritageColors.res.withValues(alpha: 0.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
