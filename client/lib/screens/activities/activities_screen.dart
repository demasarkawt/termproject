// Polished cinematic Activities screen — Focused on Kurdish Cuisine & Gastronomy.
// Drop into: lib/screens/activities/activities_screen.dart
 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
 
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
class ActivitiesScreen extends StatefulWidget {
  const ActivitiesScreen({super.key});
 
  @override
  State<ActivitiesScreen> createState() => _ActivitiesScreenState();
}
 
class _ActivitiesScreenState extends State<ActivitiesScreen> {
  String _activeFilter = 'Open Now';
 
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Top Bar ──
                  SliverToBoxAdapter(
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(24, 80, 24, 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            PressScale(
                              onTap: () => context.canPop() ? context.pop() : context.go('/home'),
                              child: Glass(
                                radius: 999,
                                padding: const EdgeInsets.all(10),
                                child: Icon(Icons.arrow_back_ios_new_rounded, color: KurdishHeritageColors.zer, size: 18),
                              ),
                            ),
                            const Text(
                              'GASTRONOMY',
                              style: TextStyle(
                                color: KurdishHeritageColors.zer,
                                fontWeight: FontWeight.w900,
                                fontSize: 13,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
 
                  // ── Dish of the Day Banner ──
                  SliverToBoxAdapter(
                    child: ScrollReveal(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: PressScale(
                          onTap: () => context.push('/explore'),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: Container(
                              height: 300,
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.asset('assets/images/cha.JPEG', fit: BoxFit.cover),
                                  const DecoratedBox(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [Colors.transparent, Color(0xDD000000)],
                                        stops: [0.3, 1],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(28),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                          decoration: BoxDecoration(
                                            color: KurdishHeritageColors.zer,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'DISH OF THE DAY',
                                            style: TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5),
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        const RevealText(
                                          'Signature\nDolma',
                                          style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: Colors.white, height: 1.05),
                                        ),
                                        const SizedBox(height: 10),
                                        Text(
                                          'Slow-cooked grape leaves stuffed with spiced rice\nand herbs, the heart of Kurdish hospitality.',
                                          style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13, height: 1.4),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            const Text('EXPLORE FLAVORS', style: TextStyle(color: KurdishHeritageColors.zer, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 2)),
                                            const SizedBox(width: 10),
                                            Container(width: 30, height: 1.5, color: KurdishHeritageColors.zer),
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
                      ),
                    ),
                  ),
 
                  // ── Dish Explorer Horizontal ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Dish Explorer', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: ink)),
                          Text('Stories behind the mountain flavors', style: TextStyle(fontSize: 14, color: ink.withOpacity(0.5))),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 260,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          _DishCard(
                            title: 'Mastawa', 
                            desc: 'Refreshing mountain yogurt soup with dried mint and herbs.', 
                            img: 'assets/images/erbil.jpg',
                            stagger: 0,
                          ),
                          _DishCard(
                            title: 'Tea Culture', 
                            desc: 'A symbol of Kurdish hospitality served in traditional glasses.', 
                            img: 'assets/images/sulaymaniyah.jpg',
                            stagger: 1,
                          ),
                        ],
                      ),
                    ),
                  ),
 
                  // ── Filters & Map Toggle ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 12),
                      child: Row(
                        children: [
                          _buildFilterPill('Open Now', isDark),
                          const SizedBox(width: 10),
                          _buildFilterPill('Erbil', isDark),
                          const SizedBox(width: 10),
                          PressScale(
                            onTap: () => context.go('/map'),
                            child: Row(
                              children: [
                                const Icon(Icons.map_outlined, color: KurdishHeritageColors.kesk, size: 16),
                                const SizedBox(width: 6),
                                const Text('MAP', style: TextStyle(color: KurdishHeritageColors.kesk, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
 
                  // ── Restaurant List ──
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 12),
                        _RestaurantCard(
                          title: 'Citadel View Dining',
                          subtitle: 'Fine Dining • Erbil',
                          tag: 'Traditional Oven',
                          price: '\$\$\$',
                          rating: '4.9',
                          img: 'assets/images/qallat.JPEG',
                          route: '/city/erbil',
                        ),
                        const SizedBox(height: 16),
                        _RestaurantCard(
                          title: 'Lali Tea House',
                          subtitle: 'Tea & Snacks • Sulaymaniyah',
                          tag: 'Outdoor Seating',
                          price: '\$\$',
                          rating: '4.7',
                          img: 'assets/images/cha.JPEG',
                          route: '/city/sulaymaniyah',
                        ),
                      ]),
                    ),
                  ),
 
                  const SliverToBoxAdapter(child: SizedBox(height: 140)),
                ],
              ),
 
              // ── Floating Filter Button ──
              Positioned(
                bottom: 30,
                right: 24,
                child: PressScale(
                  onTap: () => _showFilterSheet(context),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: KurdishHeritageColors.res,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 18, offset: const Offset(0, 8)),
                      ],
                    ),
                    child: const Icon(Icons.filter_list_rounded, color: KurdishHeritageColors.zer),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
 
  Widget _buildFilterPill(String label, bool isDark) {
    final active = _activeFilter == label;
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
    return PressScale(
      onTap: () => setState(() => _activeFilter = label),
      child: AnimatedContainer(
        duration: Motion.sm,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: active ? KurdishHeritageColors.zer : ink.withOpacity(0.05),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: active ? Colors.white : ink.withOpacity(0.6),
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
 
  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Glass(
        radius: 32,
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('REFINE SEARCH', style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 3)),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: ['Open Now', 'Erbil', 'Sulaymaniyah', 'Duhok', 'Budget', 'Premium']
                  .map((f) => PressScale(
                        onTap: () {
                          setState(() => _activeFilter = f);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: KurdishHeritageColors.zer.withOpacity(0.3)),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(f, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
 
class _DishCard extends StatelessWidget {
  final String title;
  final String desc;
  final String img;
  final int stagger;
  const _DishCard({required this.title, required this.desc, required this.img, required this.stagger});
 
  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      duration: Duration(milliseconds: Motion.md.inMilliseconds + stagger * 40),
      child: PressScale(
        child: Container(
          width: 220,
          margin: const EdgeInsets.only(right: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(img, height: 160, width: 220, fit: BoxFit.cover),
              ),
              const SizedBox(height: 14),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
 
class _RestaurantCard extends StatelessWidget {
  final String title, subtitle, tag, price, rating, img, route;
  const _RestaurantCard({
    required this.title, required this.subtitle, required this.tag,
    required this.price, required this.rating, required this.img, required this.route,
  });
 
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
    return PressScale(
      onTap: () => context.push(route),
      child: Glass(
        radius: 24,
        padding: const EdgeInsets.all(12),
        opacity: isDark ? 0.05 : 0.03,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(img, width: 90, height: 90, fit: BoxFit.cover),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, height: 1.2)),
                      ),
                      Row(
                        children: [
                          Text(rating, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900)),
                          const SizedBox(width: 2),
                          const Icon(Icons.star_rounded, color: KurdishHeritageColors.zer, size: 14),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: ink.withOpacity(0.5))),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: KurdishHeritageColors.kesk.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                        child: const Text(
                          'LOCAL FAVORITE', 
                          style: TextStyle(fontSize: 9, color: KurdishHeritageColors.kesk, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                      Text(price, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: ink.withOpacity(0.4))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
