import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../widgets/app_drawer.dart';

// ✅ Used by Home (and any screen) to open drawer
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
    if (loc.startsWith('/activities')) return 2;
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
        context.go('/activities');
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

    return Scaffold(
      key: rootScaffoldKey,
      drawer: const AppDrawer(),
      body: SizedBox.expand(child: widget.child),

      // Custom 5-item bottom bar
      bottomNavigationBar: KurdistanBottomNav(
        index: index,
        onChanged: _goIndex,
      ),
    );
  }
}

// -------------------- Kurdistan custom Bottom Nav --------------------

class KurdistanBottomNav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const KurdistanBottomNav({
    super.key,
    required this.index,
    required this.onChanged,
  });

  static const items = <_NavItem>[
    _NavItem(Icons.home_outlined, 'HOME'),
    _NavItem(Icons.explore_outlined, 'EXPLORE'),
    _NavItem(Icons.castle_outlined, 'ACTIVITIES'),
    _NavItem(Icons.calendar_month_outlined, 'EVENTS'),
    _NavItem(Icons.person_outline, 'PROFILE'),
  ];

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (i) {
          final isSelected = i == index;
          return _NavBtn(
            item: items[i],
            isSelected: isSelected,
            onTap: () => onChanged(i),
          );
        }),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final _NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavBtn({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFA726) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              item.icon,
              size: 24,
              color: isSelected ? const Color(0xFF422006) : Colors.grey.shade600,
            ),
            const SizedBox(height: 4),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? const Color(0xFF422006) : Colors.grey.shade600,
                letterSpacing: 0.5,
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
  const _NavItem(this.icon, this.label);
}
