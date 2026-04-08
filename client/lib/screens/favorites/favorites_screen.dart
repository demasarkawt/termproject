import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  // TEMP demo data (later connect to real favorites)
  final _items = <_FavPlace>[
    const _FavPlace(
      id: 'erbil-citadel',
      title: 'Citadel of Erbil',
      subtitle: 'Historical • Erbil',
      image: 'assets/images/citadel1.jpg',
      rating: 4.9,
    ),
    const _FavPlace(
      id: 'rawanduz',
      title: 'Rawanduz Canyon',
      subtitle: 'Nature • Erbil',
      image: 'assets/images/rawanduz1.jpg',
      rating: 4.8,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FFFB),
      appBar: AppBar(
        title: const Text('Saved Places'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Clear (demo)',
            onPressed: () => setState(() => _items.clear()),
            icon: const Icon(Icons.delete_outline_rounded),
          ),
        ],
      ),
      body: Stack(
        children: [
          // soft background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF7FFFB), Color(0xFFD6F9FF)],
                ),
              ),
            ),
          ),

          // content
          SafeArea(
            child: _items.isEmpty
                ? _EmptyState(
              title: 'No saved places yet',
              subtitle: 'Tap the heart icon on any place to save it here.',
              icon: Icons.bookmark_border_rounded,
              onGoHome: () => context.go('/home'),
            )
                : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final p = _items[i];
                return _FavCard(
                  place: p,
                  onOpen: () => context.go('/place/${p.id}'),
                  onRemove: () => setState(() => _items.removeAt(i)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FavPlace {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  final double rating;

  const _FavPlace({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.rating,
  });
}

class _FavCard extends StatelessWidget {
  final _FavPlace place;
  final VoidCallback onOpen;
  final VoidCallback onRemove;

  const _FavCard({
    required this.place,
    required this.onOpen,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          // image
          Positioned.fill(
            child: Image.asset(place.image, fit: BoxFit.cover),
          ),

          // dark gradient for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.10),
                    Colors.black.withOpacity(0.65),
                  ],
                ),
              ),
            ),
          ),

          // glass info
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GlassPill(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            place.rating.toStringAsFixed(1),
                            style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    _GlassIconBtn(icon: Icons.close_rounded, onTap: onRemove),
                  ],
                ),
                const Spacer(),
                Text(
                  place.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  place.subtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white.withOpacity(0.88),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 46,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onOpen,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F766E),
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      elevation: 10,
                    ),
                    child: const Text('Open', style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassPill extends StatelessWidget {
  final Widget child;
  const _GlassPill({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.18),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: Colors.white.withOpacity(0.22)),
          ),
          child: child,
        ),
      ),
    );
  }
}

class _GlassIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Material(
          color: Colors.white.withOpacity(0.16),
          child: InkWell(
            onTap: onTap,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Icon(icon, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onGoHome;

  const _EmptyState({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.75),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
                boxShadow: const [
                  BoxShadow(blurRadius: 26, offset: Offset(0, 16), color: Color(0x22000000)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0F766E),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 46,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onGoHome,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F766E),
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                        elevation: 10,
                      ),
                      child: const Text('Explore Cities', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
