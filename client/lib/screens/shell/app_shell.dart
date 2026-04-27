// lib/screens/shell/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../theme/kurdish_theme.dart';
import '../../widgets/app_drawer.dart';

final GlobalKey<ScaffoldState> rootScaffoldKey = GlobalKey<ScaffoldState>();

class AppShell extends StatefulWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _indexFromLocation(String loc) {
    if (loc.startsWith('/home'))    return 0;
    if (loc.startsWith('/explore')) return 1;
    if (loc.startsWith('/ai'))      return 2;
    if (loc.startsWith('/events'))  return 3;
    if (loc.startsWith('/profile')) return 4;
    return 0;
  }

  void _goIndex(int i) {
    switch (i) {
      case 0: context.go('/home');    break;
      case 1: context.go('/explore'); break;
      case 2: context.go('/ai');      break;
      case 3: context.go('/events');  break;
      case 4: context.go('/profile'); break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _indexFromLocation(location);

    return Scaffold(
      key: rootScaffoldKey,
      drawer: const AppDrawer(),
      body: SizedBox.expand(child: widget.child),
      bottomNavigationBar: _KurdishBottomNav(
        index: index,
        onChanged: _goIndex,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Kurdish Cultural Bottom Navigation Bar
// Deep green background · Gold active · Red accent dot · Şems sun for AI tab
// ─────────────────────────────────────────────────────────────────────────────
class _KurdishBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;
  const _KurdishBottomNav({required this.index, required this.onChanged});

  static const _items = <_NavItem>[
    _NavItem(Icons.home_rounded,            'Home',    false),
    _NavItem(Icons.explore_rounded,         'Explore', false),
    _NavItem(Icons.auto_awesome_rounded,    'AI',      true),  // sun-style
    _NavItem(Icons.calendar_month_rounded,  'Events',  false),
    _NavItem(Icons.person_rounded,          'Profile', false),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(12, 6, 12, 6 + bottom),
      decoration: BoxDecoration(
        color: KColors.kDarkGreen,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Kurdish flag stripe at top of nav bar
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: SizedBox(
              height: 3,
              child: Row(
                children: [
                  Expanded(child: Container(color: KColors.kGreen)),
                  Expanded(child: Container(
                    color: KColors.kGold,
                    child: null,
                  )),
                  Expanded(child: Container(color: KColors.kRed)),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final isSelected = i == index;
              return _NavBtn(
                item: item,
                isSelected: isSelected,
                onTap: () => onChanged(i),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;
  const _NavBtn({required this.item, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? KColors.kGold.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: KColors.kGold.withValues(alpha: 0.4), width: 1)
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // AI tab uses the Kurdish Şems sun icon
            item.isSun && isSelected
                ? const KurdishSun(size: 26, color: KColors.kGold)
                : Icon(
                    item.icon,
                    size: 22,
                    color: isSelected ? KColors.kGold : Colors.white54,
                  ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected ? KColors.kGold : Colors.white54,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool isSun;
  const _NavItem(this.icon, this.label, this.isSun);
}
