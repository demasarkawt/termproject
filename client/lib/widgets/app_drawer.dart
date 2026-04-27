// lib/widgets/app_drawer.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/user_session.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // ✅ Background blur (behind the drawer)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 26, sigmaY: 26),
              child: Container(
                color: Colors.black.withOpacity(0.10),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: _Glass(
                radius: 30,
                // a bit less blur INSIDE so text stays sharp
                blur: 14,
                // ✅ more visible panel
                tint: Colors.white.withOpacity(0.30),
                borderColor: Colors.white.withOpacity(0.35),
                shadow: const [
                  BoxShadow(
                    blurRadius: 55,
                    offset: Offset(0, 24),
                    color: Color(0x26000000),
                  ),
                ],
                // ✅ extra “readability” layer
                readabilityFill: Colors.white.withOpacity(0.22),
                child: Column(
                  children: [
                    _Header(onClose: () => Navigator.of(context).pop()),
                    const SizedBox(height: 10),

                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.fromLTRB(12, 6, 12, 14),
                        children: [
                          const _SectionTitle('Main'),
                          const SizedBox(height: 10),

                          _Tile(
                            icon: Icons.home_rounded,
                            title: 'Home',
                            subtitle: 'Cities & categories',
                            onTap: () {
                              Navigator.of(context).pop();
                              context.go('/home');
                            },
                          ),
                          _Tile(
                            icon: Icons.bookmark_rounded,
                            title: 'Saved',
                            subtitle: 'Your favorite places',
                            onTap: () {
                              Navigator.of(context).pop();
                              context.go('/favorites');
                            },
                          ),
                          _Tile(
                            icon: Icons.map_rounded,
                            title: 'Map',
                            subtitle: 'Explore on the map',
                            onTap: () {
                              Navigator.of(context).pop();
                              context.go('/map');
                            },
                          ),
                          _Tile(
                            icon: Icons.person_rounded,
                            title: 'Profile',
                            subtitle: 'Account & settings',
                            onTap: () {
                              Navigator.of(context).pop();
                              context.go('/profile');
                            },
                          ),

                          const SizedBox(height: 18),
                          const _SectionTitle('Shortcuts'),
                          const SizedBox(height: 10),

                          _CityChips(
                            onCityTap: (id) {
                              Navigator.of(context).pop();
                              context.go('/city/$id');
                            },
                          ),

                          const SizedBox(height: 20),
                          const _SectionTitle('Support'),
                          const SizedBox(height: 10),

                          _Tile(
                            icon: Icons.info_rounded,
                            title: 'About',
                            subtitle: 'App information',
                            onTap: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('About page coming soon')),
                              );
                            },
                          ),
                          _Tile(
                            icon: Icons.help_rounded,
                            title: 'Help',
                            subtitle: 'FAQ & contact',
                            onTap: () {
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Help page coming soon')),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    const _BottomBar(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final double blur;
  final Color tint;
  final Color borderColor;
  final List<BoxShadow> shadow;

  // ✅ makes text readable without killing the glass effect
  final Color readabilityFill;

  const _Glass({
    required this.child,
    required this.radius,
    required this.blur,
    required this.tint,
    required this.borderColor,
    required this.shadow,
    required this.readabilityFill,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: borderColor),
            boxShadow: shadow,
          ),
          child: Stack(
            children: [
              // readability layer
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(color: readabilityFill),
                  ),
                ),
              ),
              // subtle highlight
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.20),
                          Colors.white.withOpacity(0.06),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onClose;
  const _Header({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/images/KGO.png',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.black.withOpacity(0.05)),
                ),
                child: const Icon(Icons.image, color: Color(0xFF0F766E)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kurdistan GO',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Color(0xFF0B1F1E),
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Explore, save, and plan',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF415463),
                  ),
                ),
              ],
            ),
          ),
          _CircleGlassBtn(
            icon: Icons.close_rounded,
            onTap: onClose,
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: _Glass(
        radius: 22,
        blur: 10,
        tint: Colors.white.withOpacity(0.26),
        borderColor: Colors.white.withOpacity(0.34),
        shadow: const [
          BoxShadow(
            blurRadius: 18,
            offset: Offset(0, 10),
            color: Color(0x14000000),
          )
        ],
        readabilityFill: Colors.white.withOpacity(0.18),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F766E).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.black.withOpacity(0.05)),
                    ),
                    child: Icon(icon, color: const Color(0xFF0F766E)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: Color(0xFF0B1F1E),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: Color(0xFF415463),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: Color(0xFF0F766E)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CityChips extends StatelessWidget {
  final void Function(String cityId) onCityTap;
  const _CityChips({required this.onCityTap});

  @override
  Widget build(BuildContext context) {
    final cities = const [
      ('erbil', 'Erbil'),
      ('sulaymaniyah', 'Sulaymaniyah'),
      ('duhok', 'Duhok'),
      ('halabja', 'Halabja'),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in cities)
          _Chip(label: c.$2, onTap: () => onCityTap(c.$1)),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 999,
      blur: 10,
      tint: Colors.white.withOpacity(0.22),
      borderColor: Colors.white.withOpacity(0.32),
      shadow: const [],
      readabilityFill: Colors.white.withOpacity(0.14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 12,
                color: Color(0xFF0F766E),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w900,
        fontSize: 11,
        letterSpacing: 1.2,
        color: Color(0xFF465A6A),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: _Glass(
              radius: 18,
              blur: 10,
              tint: Colors.white.withOpacity(0.22),
              borderColor: Colors.white.withOpacity(0.32),
              shadow: const [],
              readabilityFill: Colors.white.withOpacity(0.14),
              child: const SizedBox(
                height: 44,
                child: Center(
                  child: Text(
                    'v1.0',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF465A6A),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _CircleGlassBtn(
            icon: Icons.logout_rounded,
            onTap: () async {
              Navigator.of(context).pop();
              await UserSession.clear();
              if (context.mounted) context.go('/signin');
            },
          ),
        ],
      ),
    );
  }
}

class _CircleGlassBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleGlassBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 999,
      blur: 10,
      tint: Colors.white.withOpacity(0.22),
      borderColor: Colors.white.withOpacity(0.32),
      shadow: const [],
      readabilityFill: Colors.white.withOpacity(0.14),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, color: const Color(0xFF0F766E)),
          ),
        ),
      ),
    );
  }
}
