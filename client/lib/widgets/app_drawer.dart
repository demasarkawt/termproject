import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:termproject/constants/app_branding.dart';
import '../services/user_session.dart';
import '../services/theme_service.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Stack(
        children: [
          // Background blur
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: isDark 
                  ? KurdishHeritageColors.res.withOpacity(0.8) 
                  : KurdishHeritageColors.spi.withOpacity(0.9),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _Header(isDark: isDark, onClose: () => Navigator.of(context).pop()),
                
                // Heritage Pattern Divider
                const _HeritagePatternDivider(),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                    children: [
                      _SectionTitle('Travel Hub', isDark),
                      const SizedBox(height: 12),
                      _Tile(
                        icon: Icons.home_rounded,
                        title: 'Home',
                        subtitle: AppBranding.homeTileSubtitleRegions,
                        accent: KurdishHeritageColors.sor,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/home');
                        },
                      ),
                      _Tile(
                        icon: Icons.bookmark_rounded,
                        title: 'Saved Places',
                        subtitle: 'Your saved tours',
                        accent: KurdishHeritageColors.kesk,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/favorites');
                        },
                      ),
                      _Tile(
                        icon: Icons.map_rounded,
                        title: 'Map View',
                        subtitle: 'Interactive exploration',
                        accent: KurdishHeritageColors.zer,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/explore');
                        },
                      ),

                      const SizedBox(height: 24),
                      _SectionTitle('Cultural Services', isDark),
                      const SizedBox(height: 12),
                      _Tile(
                        icon: Icons.auto_awesome_rounded,
                        title: 'AI Travel Guide',
                        subtitle: 'Trip ideas & visits',
                        accent: const Color(0xFF1E3A8A),
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/ai');
                        },
                      ),
                      _Tile(
                        icon: Icons.event_note_rounded,
                        title: 'Cultural Events',
                        subtitle: 'Upcoming festivals',
                        accent: KurdishHeritageColors.xweli,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.go('/events');
                        },
                      ),
                    ],
                  ),
                ),

                const _Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool isDark;
  final VoidCallback onClose;
  const _Header({required this.isDark, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              border: Border.all(color: KurdishHeritageColors.zer, width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.asset('assets/images/KGO.png', width: 50, height: 50, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppBranding.appName,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: isDark ? Colors.white : KurdishHeritageColors.res,
                  ),
                ),
                Text(
                  AppBranding.drawerSubtitle,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: KurdishHeritageColors.zer,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _HeritagePatternDivider extends StatelessWidget {
  const _HeritagePatternDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          for (int i = 0; i < 5; i++)
            _Diamond(color: i % 2 == 0 ? KurdishHeritageColors.sor : KurdishHeritageColors.kesk),
        ],
      ),
    );
  }
}

class _Diamond extends StatelessWidget {
  final Color color;
  const _Diamond({required this.color});

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: 0.785,
      child: Container(
        width: 10,
        height: 10,
        margin: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;

  const _Tile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: isDark ? Colors.white.withOpacity(0.03) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: isDark ? Colors.white : KurdishHeritageColors.res,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.white54 : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  final bool isDark;
  const _SectionTitle(this.text, this.isDark);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.w900,
          fontSize: 11,
          letterSpacing: 2,
          color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'v1.2 Travelo',
                style: TextStyle(color: isDark ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3), fontSize: 12, fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () async {
                  await UserSession.clear();
                  if (context.mounted) context.go('/signin');
                },
                child: Text(
                  'LOGOUT',
                  style: TextStyle(color: KurdishHeritageColors.sor, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
