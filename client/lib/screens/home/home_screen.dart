// lib/screens/home/home_screen.dart
// ─────────────────────────────────────────────────────────────────────────────
// Kurdish Cultural Home Screen
// Colours: deep green · Kurdish-sun gold · flag red · warm cream
// Motifs:  Şems sun · kilim diamond borders · mountain silhouette
// ─────────────────────────────────────────────────────────────────────────────
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:termproject/services/user_session.dart';
import '../../theme/kurdish_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedInterest = 1;
  late final AnimationController _sunCtrl;

  @override
  void initState() {
    super.initState();
    _sunCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 40),
    )..repeat();
  }

  @override
  void dispose() {
    _sunCtrl.dispose();
    super.dispose();
  }

  // ── Interest categories ────────────────────────────────────────────────────
  static const _interests = [
    _Interest('🏔️', 'Nature',    '/explore'),
    _Interest('🏛️', 'Culture',   '/explore'),
    _Interest('🍽️', 'Food',      '/activities'),
    _Interest('💧', 'Waterfalls','/explore'),
    _Interest('🛕', 'Heritage',  '/explore'),
  ];

  // ── City cards ────────────────────────────────────────────────────────────
  static const _cities = [
    _City('Erbil',         'Citadel & Bazaars', 'assets/images/erbil.jpg',          '/city/erbil'),
    _City('Sulaymaniyah',  'Mountains & Arts',  'assets/images/sulaymaniyah.jpg',   '/city/sulaymaniyah'),
    _City('Duhok',         'Lakes & Valleys',   'assets/images/duhok.jpg',          '/city/duhok'),
    _City('Halabja',       'Memorial & Nature', 'assets/images/halabja.jpg',        '/city/halabja'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final name = UserSession.userName ?? 'Explorer';

    return Scaffold(
      backgroundColor: KColors.kCream,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ─── 1. KURDISH HERO HEADER ──────────────────────────────────────
          SliverToBoxAdapter(child: _buildHero(size, name)),

          // ─── 2. KILIM DIVIDER ────────────────────────────────────────────
          const SliverToBoxAdapter(child: SizedBox(height: 4)),
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: KilimDivider(color: KColors.kGold),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 20)),

          // ─── 3. INTERESTS ROW ─────────────────────────────────────────────
          SliverToBoxAdapter(child: _buildSectionTitle('Explore By Interest', Icons.compass_calibration_outlined)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildInterests()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── 4. CITIES GRID ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSectionTitle('Kurdistan Cities', Icons.location_city_rounded, padded: false),
                  GestureDetector(
                    onTap: () => context.go('/explore'),
                    child: const Text(
                      'SEE ALL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: KColors.kGold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildCitiesRow()),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── 5. KILIM DIVIDER ─────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: KilimDivider(color: KColors.kRed),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // ─── 6. FEATURED EXPERIENCES ──────────────────────────────────────
          SliverToBoxAdapter(child: _buildSectionTitle('Featured Experiences', Icons.star_rounded)),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),
          SliverToBoxAdapter(child: _buildExperiences()),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),

      // ─── FAB: Plan my trip (Kurdish gold) ──────────────────────────────
      floatingActionButton: GestureDetector(
        onTap: () => context.go('/ai'),
        child: Container(
          height: 54,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [KColors.kGold, KColors.kSaffron],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: KColors.kGold.withValues(alpha: 0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const KurdishSun(size: 22, color: Colors.white),
              const SizedBox(width: 8),
              const Text(
                'PLAN MY TRIP',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Hero Section ───────────────────────────────────────────────────────────
  Widget _buildHero(Size size, String name) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Dark green background with mountain silhouette
        Container(
          width: double.infinity,
          height: size.height * 0.38,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [KColors.kDarkGreen, Color(0xFF1A6B3A)],
            ),
          ),
          child: Stack(
            children: [
              // Mountain silhouette
              Positioned.fill(
                child: CustomPaint(painter: _MountainPainter()),
              ),
              // Geometric kilim pattern overlay (subtle)
              Positioned(
                bottom: 0, left: 0, right: 0,
                child: SizedBox(
                  height: 8,
                  child: CustomPaint(
                    painter: KilimBorderPainter(
                      color: KColors.kGold.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Rotating Kurdish Şems sun (background decoration)
        Positioned(
          top: -30,
          right: -30,
          child: AnimatedBuilder(
            animation: _sunCtrl,
            builder: (_, __) => Transform.rotate(
              angle: _sunCtrl.value * 2 * math.pi,
              child: const KurdishSun(
                size: 180,
                color: KColors.kGold,
                opacity: 0.12,
              ),
            ),
          ),
        ),

        // Content overlay
        Positioned.fill(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: KColors.kGold.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: KColors.kGold.withValues(alpha: 0.4),
                              ),
                            ),
                            child: const KurdishSun(size: 20, color: KColors.kGold),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Kurdistan Go',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: KColors.kGold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go('/map'),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            color: KColors.kGold,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Kurdish greeting text
                  const Text(
                    'خوش هاتی',    // "Welcome" in Sorani Kurdish
                    style: TextStyle(
                      fontSize: 15,
                      color: KColors.kGoldLight,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Welcome, $name!',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Discover the Zagros heartland — Kurdistan awaits.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white60,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Kurdish flag stripe
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: const KurdishFlagStripe(height: 5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Section Title ──────────────────────────────────────────────────────────
  Widget _buildSectionTitle(String title, IconData icon, {bool padded = true}) {
    final w = Padding(
      padding: padded
          ? const EdgeInsets.symmetric(horizontal: 20)
          : EdgeInsets.zero,
      child: Row(
        children: [
          Icon(icon, color: KColors.kSaffron, size: 18),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: KColors.kDarkGreen,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
    return padded ? w : w;
  }

  // ── Interest Icons Row ─────────────────────────────────────────────────────
  Widget _buildInterests() {
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemCount: _interests.length,
        itemBuilder: (_, i) {
          final it = _interests[i];
          final isSelected = _selectedInterest == i;
          return GestureDetector(
            onTap: () {
              setState(() => _selectedInterest = i);
              context.go(it.route);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 68,
              decoration: BoxDecoration(
                color: isSelected ? KColors.kDarkGreen : KColors.kWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? KColors.kGold : KColors.kDivider,
                  width: isSelected ? 2 : 1,
                ),
                boxShadow: isSelected
                    ? [BoxShadow(
                        color: KColors.kGold.withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(it.emoji, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 4),
                  Text(
                    it.label,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? KColors.kGold : KColors.kStone,
                      letterSpacing: 0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Cities Row ─────────────────────────────────────────────────────────────
  Widget _buildCitiesRow() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemCount: _cities.length,
        itemBuilder: (_, i) => _CityCard(city: _cities[i]),
      ),
    );
  }

  // ── Experiences ────────────────────────────────────────────────────────────
  Widget _buildExperiences() {
    final items = [
      _Experience('Kurdish Mountain Hiking', 'Rawanduz Canyon', KColors.kGreen,
          'assets/images/hd_mountains.jpg', Icons.terrain_rounded),
      _Experience('Local Cuisine & Bazaars', 'Qaysari Market', KColors.kSaffron,
          'assets/images/hd_bazaar.jpg', Icons.restaurant_rounded),
      _Experience('Sacred Heritage Sites', 'Lalish & Mosques', KColors.kRed,
          'assets/images/hd_mosque.jpg', Icons.account_balance_rounded),
    ];

    return Column(
      children: items.map((e) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: _ExperienceCard(exp: e),
      )).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// City Card Widget
// ─────────────────────────────────────────────────────────────────────────────
class _CityCard extends StatelessWidget {
  final _City city;
  const _CityCard({required this.city});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(city.route),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Image
              Image.asset(city.image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: KColors.kDarkGreen)),

              // Gradient overlay
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xDD0E3D20)],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),

              // Gold top-left accent corner
              Positioned(
                top: 8, left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: KColors.kGold.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const KurdishSun(size: 12, color: Colors.white),
                ),
              ),

              // Text at bottom
              Positioned(
                bottom: 10, left: 10, right: 10,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city.name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      city.subtitle,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Experience Card
// ─────────────────────────────────────────────────────────────────────────────
class _ExperienceCard extends StatelessWidget {
  final _Experience exp;
  const _ExperienceCard({required this.exp});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go('/activities'),
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: exp.color.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(exp.image, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: exp.color)),

              // Colour overlay
              Container(
                color: exp.color.withValues(alpha: 0.65),
              ),

              // Kurdish kilim top border
              Positioned(
                top: 0, left: 0, right: 0,
                child: SizedBox(
                  height: 5,
                  child: CustomPaint(
                    painter: KilimBorderPainter(
                      color: KColors.kGold.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Icon(exp.icon, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          exp.title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          exp.subtitle,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white.withValues(alpha: 0.6), size: 14),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Mountain silhouette painter (Zagros mountains)
// ─────────────────────────────────────────────────────────────────────────────
class _MountainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, size.height * 0.7)
      ..lineTo(size.width * 0.12, size.height * 0.35)
      ..lineTo(size.width * 0.22, size.height * 0.55)
      ..lineTo(size.width * 0.35, size.height * 0.25)
      ..lineTo(size.width * 0.48, size.height * 0.48)
      ..lineTo(size.width * 0.60, size.height * 0.18)
      ..lineTo(size.width * 0.72, size.height * 0.42)
      ..lineTo(size.width * 0.83, size.height * 0.28)
      ..lineTo(size.width * 0.92, size.height * 0.45)
      ..lineTo(size.width, size.height * 0.38)
      ..lineTo(size.width, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _MountainPainter _) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// Data classes
// ─────────────────────────────────────────────────────────────────────────────
class _Interest {
  final String emoji, label, route;
  const _Interest(this.emoji, this.label, this.route);
}

class _City {
  final String name, subtitle, image, route;
  const _City(this.name, this.subtitle, this.image, this.route);
}

class _Experience {
  final String title, subtitle, image;
  final Color color;
  final IconData icon;
  const _Experience(this.title, this.subtitle, this.color, this.image, this.icon);
}
