import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:termproject/services/user_session.dart';
import '../../services/weather_service.dart';
import '../../widgets/place_image.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedInterest = 1;
  Map<String, CityWeather> _weatherMap = {};

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final list = await WeatherService.fetchAll();
      if (mounted) {
        setState(() {
          _weatherMap = {for (final w in list) w.city: w};
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1F5E37);
    const backgroundLight = Color(0xFFF9FAFB);
    const textDark = Color(0xFF1E1E1E);

    return Scaffold(

      backgroundColor: backgroundLight,
      body: Stack(
        children: [
          // Background Gradient (Peach top right)
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFFF3E0).withOpacity(0.8),
                    backgroundLight.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  // Top Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: const [
                          Icon(Icons.location_on_outlined, color: primaryGreen),
                          SizedBox(width: 4),
                          Text(
                            'Kurdistan Go',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go('/map'),
                        child: const Icon(Icons.wb_sunny_outlined, color: Colors.green),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Welcome Text
                  Text(
                    'Welcome to\nKurdistan, ${UserSession.userName ?? 'Explorer'}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      fontFamily: 'serif',
                      color: textDark,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your luxury journey through the Zagros\nheartland starts here.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Explore Cities (weather embedded in cards)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Explore Cities',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                          color: textDark,
                        ),
                      ),
                      if (_weatherMap.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF22C55E).withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFF22C55E).withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 5, height: 5,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF22C55E),
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Live weather',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF16A34A),
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        const SizedBox(
                          width: 14, height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF1F5E37)),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Top Locations Horizontal Scroll
                  SizedBox(
                    height: 320,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/city/erbil'),
                          child: _buildMainLocationCard(
                            'Erbil',
                            'The ancient heart of Kurdistan,\nhome to the Citadel and vibrant bazaars.',
                            'assets/images/erbil.jpg',
                            _weatherMap['Erbil'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => context.go('/city/sulaymaniyah'),
                          child: _buildMainLocationCard(
                            'Sulaymaniyah',
                            'The cultural capital, surrounded by beautiful mountains.',
                            'assets/images/sulaymaniyah.jpg',
                            _weatherMap['Sulaymaniyah'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => context.go('/city/duhok'),
                          child: _buildMainLocationCard(
                            'Duhok',
                            'Stunning valleys, ancient temples, and lakeside views.',
                            'assets/images/duhok.jpg',
                            _weatherMap['Duhok'],
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => context.go('/city/halabja'),
                          child: _buildMainLocationCard(
                            'Halabja',
                            'A city of resilience, nature, and the Hawraman mountains.',
                            'assets/images/halabja.jpg',
                            _weatherMap['Halabja'],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Discover by Interest
                  const Text(
                    'Discover by Interest',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'serif',
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInterestIcon(context, 'NATURE',    Icons.landscape_outlined,      0),
                      _buildInterestIcon(context, 'CULTURE',   Icons.castle_outlined,         1),
                      _buildInterestIcon(context, 'FOOD',      Icons.restaurant_outlined,     2),
                      _buildInterestIcon(context, 'ADVENTURE', Icons.directions_walk_outlined, 3),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Trending Experiences
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Trending\nExperiences',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'serif',
                              color: textDark,
                              height: 1.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Curated journeys for the modern explorer',
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: () => context.go('/explore'),
                        child: const Text(
                          'SEE\nALL',
                          textAlign: TextAlign.right,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Trending Experiences Cards
                  SizedBox(
                    height: 240,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      clipBehavior: Clip.none,
                      children: [
                        GestureDetector(
                          onTap: () => context.go('/activities'),
                          child: _buildExperienceCard(
                            'assets/images/duhok.jpg',
                            'Hiking in Barzan',
                            'Full Day',
                            '\$120',
                            '4.9',
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () => context.go('/activities'),
                          child: _buildExperienceCard(
                            'assets/images/cha.JPEG',
                            'Traditional Food',
                            'Evening',
                            '\$65',
                            '4.8',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // padding for floating action button & bottom nav
                ],
              ),
            ),
          ),
          
          // Floating Action Button
          Positioned(
            bottom: 20,
            right: 20,
            child: GestureDetector(
              onTap: () => context.go('/ai'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFA726),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFFFFA726).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: const [
                    Icon(Icons.auto_awesome, color: Color(0xFF422006), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'PLAN MY TRIP',
                      style: TextStyle(
                        color: Color(0xFF422006),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard(String city, IconData icon, String temp) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(city, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 4),
          Icon(icon, color: const Color(0xFFDA8A00), size: 24),
          const SizedBox(height: 4),
          Text(temp, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E1E1E))),
        ],
      ),
    );
  }

  Widget _buildMainLocationCard(
      String title, String subtitle, String img, [CityWeather? weather]) {
    final weatherColor = weather != null
        ? WeatherService.colorFromCode(weather.weatherCode)
        : const Color(0xFF1F5E37);
    final weatherIcon = weather != null
        ? WeatherService.iconFromCode(weather.weatherCode)
        : Icons.wb_sunny_rounded;

    return Container(
      width: 240,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // City photo
          Positioned.fill(
            child: PlaceImage(
              imagePath: img,
              title: title,
              fit: BoxFit.cover,
            ),
          ),

          // Dark gradient overlay (bottom)
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.75),
                    Colors.black.withOpacity(0.10),
                    Colors.transparent,
                  ],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
          ),

          // ── TOP-RIGHT: Live weather badge ─────────────────────────────
          Positioned(
            top: 12,
            right: 12,
            child: AnimatedOpacity(
              opacity: weather != null ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                decoration: BoxDecoration(
                  // white frosted glass look
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.40),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Weather icon — large and coloured
                    Icon(
                      weatherIcon,
                      size: 22,
                      color: weatherColor,
                    ),
                    const SizedBox(width: 5),
                    // Temperature — big white bold
                    Text(
                      weather != null && !weather.tempC.isNaN
                          ? '${weather.tempC.round()}°'
                          : '—',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── BOTTOM: City name + description ───────────────────────────
          Positioned(
            left: 16, right: 16, bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (weather != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      weather.description,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: weatherColor,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                    color: Colors.white,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.75),
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                // Explore pill
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'Explore',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white, size: 14),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInterestIcon(BuildContext context, String label, IconData icon, int index) {
    final isSelected = _selectedInterest == index;
    final destinations = ['/explore', '/explore', '/activities', '/activities'];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedInterest = index);
        context.go(destinations[index]);
      },
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFFFA726) : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: isSelected ? const Color(0xFF422006) : Colors.grey.shade800,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(String img, String title, String duration, String price, String rating) {
    return SizedBox(
      width: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(
                image: AssetImage(img),
                fit: BoxFit.cover,
              ),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star, color: Color(0xFFFFA726), size: 12),
                  const SizedBox(width: 4),
                  Text(rating, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              fontFamily: 'serif',
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.access_time, size: 12, color: Colors.grey),
              const SizedBox(width: 4),
              Text(duration, style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('•', style: TextStyle(color: Colors.grey, fontSize: 10)),
              ),
              Text(price, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37))),
            ],
          ),
        ],
      ),
    );
  }
}
