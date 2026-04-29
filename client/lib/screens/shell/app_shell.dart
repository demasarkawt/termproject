import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_branding.dart';
import '../../widgets/app_drawer.dart';
import '../../services/theme_service.dart';
import '../../services/user_session.dart';
import '../../theme/trip_planner_theme.dart';

final GlobalKey<ScaffoldState> rootScaffoldKey = GlobalKey<ScaffoldState>();

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indexFromLocation(String loc) {
    if (loc.startsWith('/home')) return 0;
    if (loc.startsWith('/explore')) return 1;
    if (loc.startsWith('/ai')) return 2;
    if (loc.startsWith('/events')) return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  void _goIndex(int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/explore');
        break;
      case 2:
        context.go('/ai');
        break;
      case 3:
        context.go('/events');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);
    final homeMode = location.startsWith('/home');

    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final isDark = ThemeService().isDark;

        return Scaffold(
          key: rootScaffoldKey,
          extendBody: true,
          drawer: const AppDrawer(),
          body: Stack(
            children: [
              widget.child,
              if (homeMode)
                SafeArea(
                  bottom: false,
                  child: _TripPlannerHomeHeader(
                    isDark: isDark,
                  ),
                )
              else
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8, left: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _GlobalActionBtn(
                            icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            semanticLabel: 'Toggle light or dark appearance',
                            tooltip: 'Appearance',
                            onTap: () => ThemeService().toggleTheme(),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 12),
                          _GlobalActionBtn(
                            icon: Icons.map_rounded,
                            semanticLabel: 'Open map',
                            tooltip: 'Map',
                            onTap: () => context.go('/map'),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: TraveloBottomNav(
            index: index,
            onChanged: _goIndex,
          ),
        );
      },
    );
  }
}

/// Matches Trip Planner chrome: avatar · centered title · search · overflow menu.
class _TripPlannerHomeHeader extends StatelessWidget {
  const _TripPlannerHomeHeader({
    required this.isDark,
  });

  final bool isDark;

  String _initials() {
    final raw = UserSession.userName?.trim();
    if (raw == null || raw.isEmpty) return 'T';
    final parts = raw.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
    if (parts.isEmpty) return 'T';
    if (parts.length == 1) {
      final s = parts.single;
      return s.isNotEmpty ? s[0].toUpperCase() : 'T';
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final titleColor = isDark ? Colors.white : TripPlannerTheme.headlineBrown;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 4, 0),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Material(
              color: isDark ? const Color(0xFF2C2C2E) : TripPlannerTheme.canvasSecondary,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => context.go('/profile'),
                child: SizedBox(
                  height: 44,
                  width: 44,
                  child: Center(
                    child: Text(
                      _initials(),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: titleColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Text(
                AppBranding.appName,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.inter(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.35,
                  color: titleColor,
                ),
              ),
            ),
            IconButton(
              onPressed: () => context.go('/explore'),
              tooltip: 'Search & explore',
              icon: Icon(
                Icons.search_rounded,
                color: titleColor.withValues(alpha: 0.88),
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More',
              icon: Icon(
                Icons.more_horiz_rounded,
                color: titleColor.withValues(alpha: 0.75),
              ),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              onSelected: (v) {
                switch (v) {
                  case 'map':
                    context.go('/map');
                    break;
                  case 'theme':
                    ThemeService().toggleTheme();
                    break;
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'map', child: Text('Map')),
                PopupMenuItem(value: 'theme', child: Text('Appearance')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// iOS-style chrome: 48pt hit target, blur-filled capsule, semantic labels.
class _GlobalActionBtn extends StatelessWidget {
  const _GlobalActionBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.semanticLabel,
    this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;
  final String semanticLabel;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    // Solid frosted capsules read more clearly than heavy blur over photo + sheet backgrounds.
    final stroke = isDark
        ? Colors.white.withValues(alpha: 0.32)
        : const Color(0xFF3C3C43).withValues(alpha: 0.22);
    final fill = isDark
        ? const Color(0xFF1C1C1E).withValues(alpha: 0.78)
        : Colors.white.withValues(alpha: 0.92);
    final iconColor = isDark ? Colors.white : const Color(0xFF1C1C1E);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Tooltip(
        message: tooltip ?? semanticLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: fill,
                border: Border.all(color: stroke, width: 1.25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                icon,
                size: 24,
                color: iconColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Frosted bottom bar with raised center AI control (iOS-friendly tap targets).
class TraveloBottomNav extends StatelessWidget {
  const TraveloBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  static final _icons = <IconData>[
    Icons.home_rounded,
    Icons.explore_rounded,
    Icons.auto_awesome_rounded,
    Icons.event_rounded,
    Icons.person_rounded,
  ];

  static const _labels = ['Home', 'Explore', 'AI', 'Events', 'Profile'];

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripSelected =
        isDark ? const Color(0xFFEAD8A9) : TripPlannerTheme.brownPrimary;
    final unselected = isDark
        ? Colors.white.withValues(alpha: 0.45)
        : Colors.black.withValues(alpha: 0.45);

    return Padding(
      padding: EdgeInsets.fromLTRB(12, 0, 12, 10 + bottomInset),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xD91C1C1E)
                  : Colors.white.withValues(alpha: 0.86),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.black.withValues(alpha: 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                  blurRadius: 28,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: _ShellTab(
                    icon: _icons[0],
                    label: _labels[0],
                    selected: index == 0,
                    onTap: () => onChanged(0),
                    selectedColor: tripSelected,
                    unselectedColor: unselected,
                  ),
                ),
                Expanded(
                  child: _ShellTab(
                    icon: _icons[1],
                    label: _labels[1],
                    selected: index == 1,
                    onTap: () => onChanged(1),
                    selectedColor: tripSelected,
                    unselectedColor: unselected,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 2, right: 2, bottom: 2),
                  child: Transform.translate(
                    offset: const Offset(0, -14),
                    child: _ShellAiTab(
                      selected: index == 2,
                      onTap: () => onChanged(2),
                    ),
                  ),
                ),
                Expanded(
                  child: _ShellTab(
                    icon: _icons[3],
                    label: _labels[3],
                    selected: index == 3,
                    onTap: () => onChanged(3),
                    selectedColor: tripSelected,
                    unselectedColor: unselected,
                  ),
                ),
                Expanded(
                  child: _ShellTab(
                    icon: _icons[4],
                    label: _labels[4],
                    selected: index == 4,
                    onTap: () => onChanged(4),
                    selectedColor: tripSelected,
                    unselectedColor: unselected,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellTab extends StatelessWidget {
  const _ShellTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    final c = selected ? selectedColor : unselectedColor;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 52,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(icon, size: 24, color: c),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    color: c,
                    letterSpacing: -0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ShellAiTab extends StatelessWidget {
  const _ShellAiTab({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Semantics(
      button: true,
      selected: selected,
      label: 'Travelo AI assistant',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            elevation: selected ? 10 : 6,
            shadowColor: TripPlannerTheme.brownPrimary.withValues(alpha: 0.45),
            shape: const CircleBorder(),
            color: TripPlannerTheme.brownPrimary,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Ink(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  size: 30,
                  color: Colors.white.withValues(alpha: 0.95),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'AI',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: selected
                  ? (isDark ? const Color(0xFFEAD8A9) : TripPlannerTheme.brownPrimary)
                  : (isDark ? Colors.white54 : Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
