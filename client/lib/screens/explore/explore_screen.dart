import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'ai_search_bottom_sheet.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedFilter;
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1F5E37);
    const backgroundLight = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
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
                      const Icon(Icons.wb_sunny_outlined, color: Colors.green),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    child: Column(
                      children: [
                        // Map Section
                        SizedBox(
                          height: 300,
                          child: Stack(
                            children: [
                              // Map Background Placeholder (Topographic effect)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade300,
                                  image: const DecorationImage(
                                    image: AssetImage('assets/images/sulaymaniyah.jpg'), // using as placeholder
                                    fit: BoxFit.cover,
                                    colorFilter: ColorFilter.mode(Colors.grey, BlendMode.saturation),
                                  ),
                                ),
                              ),
                              Container(color: Colors.white.withOpacity(0.5)),

                              // Search Bar inside map
                              Positioned(
                                top: 20,
                                left: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: () => showModalBottomSheet(
                                    context: context,
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => const AiSearchBottomSheet(),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(30),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.search, color: Colors.grey, size: 20),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            'Search heritage sites, waterfalls, canyons...',
                                            style: TextStyle(fontSize: 12, color: Colors.grey.shade500, height: 1.2),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => context.go('/ai'),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: const [
                                                Icon(Icons.auto_awesome, color: Colors.white, size: 14),
                                                SizedBox(width: 4),
                                                Text('Ask AI', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // Pins (tappable)
                              _buildMapPin(context, 100, 150, 'Duhok', 'duhok'),
                              _buildMapPin(context, 160, 220, 'Erbil Citadel', 'erbil'),
                              _buildMapPin(context, 200, 240, 'Sulaymaniyah', 'sulaymaniyah'),

                              // List View Toggle
                              Positioned(
                                bottom: 20,
                                right: 20,
                                child: GestureDetector(
                                  onTap: () => _scrollCtrl.animateTo(
                                    320,
                                    duration: const Duration(milliseconds: 400),
                                    curve: Curves.easeOut,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
                                      ],
                                    ),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.list, size: 16, color: primaryGreen),
                                        SizedBox(width: 6),
                                        Text('LIST VIEW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, color: primaryGreen)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Chips
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () => setState(() => _selectedFilter = null),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: BoxDecoration(color: const Color(0xFFFFA726), borderRadius: BorderRadius.circular(20)),
                                  child: Row(
                                    children: const [
                                      Icon(Icons.tune, size: 14, color: Color(0xFF422006)),
                                      SizedBox(width: 4),
                                      Text('Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF422006))),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip('Erbil'),
                              const SizedBox(width: 8),
                              _buildFilterChip('Sulaymaniyah'),
                            ],
                          ),
                        ),

                        // List of Places
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              GestureDetector(onTap: () => context.go('/place/rawanduz-canyon'), child: _buildCanyonCard()),
                              const SizedBox(height: 20),
                              GestureDetector(onTap: () => context.go('/city/erbil'), child: _buildCitadelCard()),
                              const SizedBox(height: 20),
                              GestureDetector(onTap: () => context.go('/city/erbil'), child: _buildBekhalCard()),
                              const SizedBox(height: 20),
                              GestureDetector(onTap: () => context.go('/city/erbil'), child: _buildMountCard()),
                              const SizedBox(height: 100), // FAB padding
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Floating Action Button
            Positioned(
              bottom: 20,
              right: 20,
              child: GestureDetector(
                onTap: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => const AiSearchBottomSheet(),
                ),
                child: Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFA726),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: const Color(0xFFFFA726).withOpacity(0.4), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.qr_code_scanner, color: Color(0xFF422006)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPin(BuildContext context, double top, double left, String name, String cityId) {
    return Positioned(
      top: top,
      left: left,
      child: GestureDetector(
        onTap: () => context.go('/city/$cityId'),
        child: Column(
          children: [
            const Icon(Icons.location_on, color: Color(0xFF1F5E37), size: 30),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
              ),
              child: Text(name, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = isSelected ? null : label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1F5E37) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildCanyonCard() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(image: AssetImage('assets/images/shanadar.JPEG'), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.8), Colors.transparent],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFFFA726), borderRadius: BorderRadius.circular(12)),
                  child: const Text('SPRING PEAK', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: Colors.blue.shade300, borderRadius: BorderRadius.circular(12)),
                  child: const Text('NATURE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: const [
                Icon(Icons.star, color: Color(0xFFFFA726), size: 14),
                SizedBox(width: 4),
                Text('4.9 (1.2k reviews)  •  40 km away', style: TextStyle(color: Colors.white70, fontSize: 10)),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Rawanduz\nCanyon',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, fontFamily: 'serif', color: Colors.white, height: 1.1),
            ),
            const SizedBox(height: 6),
            const Text(
              'Experience the breathtaking depths\nof Kurdistan\'s most iconic\ngeological wonder, featuring\nwinding roads and emerald rivers.',
              style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.3),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCitadelCard() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(image: AssetImage('assets/images/qallat.JPEG'), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.black.withOpacity(0.4),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(color: Color(0xFF1F5E37), shape: BoxShape.circle),
                child: const Icon(Icons.bookmark_outline, color: Colors.white, size: 16),
              ),
            ),
            const Spacer(),
            Row(
              children: const [
                Icon(Icons.star, color: Color(0xFFFFA726), size: 14),
                SizedBox(width: 4),
                Text('4.8', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Erbil Citadel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'serif', color: Colors.white),
            ),
            const SizedBox(height: 6),
            const Text(
              'UNESCO World Heritage Site. One of the\noldest continuously inhabited places on\nEarth.',
              style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.3),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white30),
              ),
              child: const Text(
                'VIEW HISTORY',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBekhalCard() {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: const DecorationImage(image: AssetImage('assets/images/halabja.jpg'), fit: BoxFit.cover),
      ),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.95),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('Bekhal Falls', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37))),
                  SizedBox(height: 4),
                  Text('Soran Region', style: TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
              const Text('Free Access', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFFDA8A00))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMountCard() {
    return Container(
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF1E3A4C), // Deep blue
      ),
      child: Stack(
        children: [
          // Graphic representation of cable car and mountain
          Positioned(
            top: 40,
            right: 40,
            child: Icon(Icons.cable, color: Colors.white24, size: 100), // placeholder for graphic
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  child: const Text('PREMIUM', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37))),
                ),
                const Spacer(),
                const Text(
                  'Mount Korek',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'serif', color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Summer escape & Winter skiing',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
