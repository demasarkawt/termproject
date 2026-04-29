import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_drawer.dart';
import '../../services/theme_service.dart';

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
      case 0: context.go('/home'); break;
      case 1: context.go('/explore'); break;
      case 2: context.go('/ai'); break;
      case 3: context.go('/events'); break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

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

              // Theme & map: top-left so profile (and other) top-right actions stay clear.
              SafeArea(
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10, left: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _GlobalActionBtn(
                          icon: isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          onTap: () => ThemeService().toggleTheme(),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 10),
                        _GlobalActionBtn(
                          icon: Icons.map_rounded,
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
          bottomNavigationBar: HeritageBottomNav(
            index: index,
            onChanged: _goIndex,
          ),
        );
      },
    );
  }
}

class _GlobalActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool isDark;

  const _GlobalActionBtn({
    required this.icon,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Material(
          color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08),
          child: InkWell(
            onTap: onTap,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.12),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 20,
                color: KurdishHeritageColors.zer,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HeritageBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const HeritageBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  /// Events accent — earth tone from the heritage palette (replaces generic blue).
  static const Color _eventsAccent = Color(0xFF6D4C41);

  static const items = <_HeritageItem>[
    _HeritageItem(Icons.home_rounded, 'Home', KurdishHeritageColors.sor),
    _HeritageItem(Icons.explore_rounded, 'Explore', KurdishHeritageColors.kesk),
    _HeritageItem(Icons.auto_awesome_rounded, 'AI', KurdishHeritageColors.zer),
    _HeritageItem(Icons.calendar_today_rounded, 'Events', _eventsAccent),
    _HeritageItem(Icons.person_rounded, 'Profile', KurdishHeritageColors.xweli),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 110 + bottomPadding,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Background Bar (The brown strip from the image)
          ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: Container(
                height: 64,
                decoration: BoxDecoration(
                  color: KurdishHeritageColors.xweli.withValues(alpha: isDark ? 0.88 : 0.92),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: isDark ? 0.15 : 0.22),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.14),
                      blurRadius: isDark ? 20 : 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Connecting Line
          Positioned(
            left: 50,
            right: 50,
            child: Container(
              height: 1.5,
              color: KurdishHeritageColors.zer.withValues(alpha: 0.4),
            ),
          ),

          // Nav Items (Diamonds)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final isSelected = i == index;
              return GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: _DiamondNavBtn(
                  item: items[i],
                  isSelected: isSelected,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DiamondNavBtn extends StatefulWidget {
  final _HeritageItem item;
  final bool isSelected;

  const _DiamondNavBtn({
    required this.item,
    required this.isSelected,
  });

  @override
  State<_DiamondNavBtn> createState() => _DiamondNavBtnState();
}

class _DiamondNavBtnState extends State<_DiamondNavBtn> with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.isSelected) {
      _pulseCtrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(_DiamondNavBtn oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseCtrl.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _pulseCtrl
        ..stop()
        ..reset();
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedScale(
      duration: const Duration(milliseconds: 400),
      scale: widget.isSelected ? 1.1 : 1.0,
      curve: Curves.elasticOut,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          // Subtle Parallax/Tilt effect when selected
          final pulseValue = widget.isSelected ? _pulseCtrl.value : 0.0;
          final offset = Offset(0, -pulseValue * 3);

          return Transform.translate(
            offset: offset,
            child: SizedBox(
              width: 60, // Fixed width for each item to prevent horizontal shifts
              child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Outer Diamond (Parallax Glow)
                    if (widget.isSelected)
                      Transform.rotate(
                        angle: 0.785,
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: widget.item.color.withValues(
                                  alpha: 0.28 * _pulseCtrl.value,
                                ),
                                blurRadius: 18 * _pulseCtrl.value,
                                spreadRadius: 3 * _pulseCtrl.value,
                              )
                            ],
                          ),
                        ),
                      ),
                    
                    // Main Diamond
                    Transform.rotate(
                      angle: 0.785398,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.item.color,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: widget.isSelected ? [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 10,
                              offset: const Offset(4, 4),
                            )
                          ] : [],
                        ),
                      ),
                    ),
                    // Inner White Diamond
                    Transform.rotate(
                      angle: 0.785398,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    // Icon — dark glyphs read reliably on saturated jewel tones.
                    Icon(
                      widget.item.icon,
                      size: 20,
                      color: widget.isSelected
                          ? Colors.black.withValues(alpha: 0.87)
                          : Colors.black.withValues(alpha: isDark ? 0.5 : 0.42),
                    ),
                  ],
                ),
                // Fixed height label container to prevent overflow/layout shifts
                SizedBox(
                  height: 20,
                  child: Center(
                    child: widget.isSelected
                        ? Text(
                            widget.item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
          );
        },
      ),
    );
  }
}

class _HeritageItem {
  final IconData icon;
  final String label;
  final Color color;
  const _HeritageItem(this.icon, this.label, this.color);
}
