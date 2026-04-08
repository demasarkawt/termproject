import 'package:flutter/material.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1F5E37);
    const backgroundLight = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                            Text('Kurdistan Go', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryGreen)),
                          ],
                        ),
                        Row(
                          children: const [
                            Icon(Icons.search, color: Colors.black54),
                            SizedBox(width: 16),
                            Icon(Icons.wb_sunny_outlined, color: Colors.green),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Signature Dolma Banner
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      height: 240,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        image: const DecorationImage(
                          image: AssetImage('assets/images/cha.JPEG'), // using cha.JPEG as placeholder
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.black.withOpacity(0.4),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: const Color(0xFFFFA726), borderRadius: BorderRadius.circular(12)),
                              child: const Text('DISH OF THE DAY', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Signature\nDolma',
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, fontFamily: 'serif', color: Colors.white, height: 1.1),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'The heart of every Kurdish feast,\nslow-cooked for twelve hours with\naromatic spices and sumac.',
                              style: TextStyle(color: Colors.white70, fontSize: 10, height: 1.3),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(20)),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Text('Where to try it', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward, color: Colors.white, size: 16),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Dish Explorer Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Dish Explorer', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                            SizedBox(height: 2),
                            Text('Stories behind the flavors', style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                              child: const Icon(Icons.chevron_left, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(color: Colors.grey.shade200, shape: BoxShape.circle),
                              child: const Icon(Icons.chevron_right, size: 16),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Horizontal Dish Cards
                  SizedBox(
                    height: 250,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      clipBehavior: Clip.none,
                      children: [
                        _buildDishCard('Mastawa', 'A refreshing mountain yogurt soup\ninfused with dried mint and wild mountain\nherbs.', 'assets/images/erbil.jpg'),
                        const SizedBox(width: 16),
                        _buildDishCard('Tea Culture', 'More than a drink, it\'s a symbol of Kurdish\nhospitality served after every meal.', 'assets/images/sulaymaniyah.jpg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Filters
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        _buildFilterPill('Open Now', true),
                        const SizedBox(width: 8),
                        _buildFilterPill('Erbil', false),
                        const SizedBox(width: 8),
                        _buildFilterPill('Sulaymaniyah', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Switch to Map Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: const [
                        Icon(Icons.map_outlined, color: primaryGreen, size: 16),
                        SizedBox(width: 4),
                        Text('Switch to Map', style: TextStyle(color: primaryGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Restaurant List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildRestaurantCard(
                          'Citadel View\nDining',
                          'Fine Dining • Erbil',
                          'Traditional Oven',
                          '\$\$\$',
                          '4.9',
                          'assets/images/qallat.JPEG',
                        ),
                        const SizedBox(height: 16),
                        _buildRestaurantCard(
                          'Lali Tea House',
                          'Tea & Snacks • Sulaymaniyah',
                          'Outdoor Seating',
                          '\$\$',
                          '4.7',
                          'assets/images/cha.JPEG',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // Eat Like a Local Header
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text('Eat Like a Local', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'serif')),
                  ),
                  const SizedBox(height: 16),

                  // Eat Like a Local Cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        _buildLocalCard('Morning Markets', 'Best breakfast spots in the Bazaar', 'assets/images/shanadar.JPEG'),
                        const SizedBox(height: 16),
                        _buildLocalCard('Riverside Grills', 'Where locals go for summer weekends', 'assets/images/duhok.jpg'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 100), // padding for FAB
                ],
              ),
            ),
            
            // FAB
            Positioned(
              bottom: 20,
              right: 20,
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: primaryGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.filter_list, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDishCard(String title, String desc, String img) {
    return SizedBox(
      width: 220,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
            ),
            alignment: Alignment.topRight,
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.5), shape: BoxShape.circle),
              child: const Icon(Icons.bookmark_border, size: 16, color: Colors.white),
            ),
          ),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'serif')),
          const SizedBox(height: 4),
          Text(desc, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.3), maxLines: 3, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildFilterPill(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFFFA726) : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? const Color(0xFF422006) : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildRestaurantCard(String title, String subtitle, String tag, String price, String rating, String img) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, fontFamily: 'serif', height: 1.2)),
                    Row(
                      children: [
                        Text(rating, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        const Icon(Icons.star, color: Color(0xFFFFA726), size: 12),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(4)),
                      child: Text(tag, style: const TextStyle(fontSize: 9, color: Color(0xFF1F5E37), fontWeight: FontWeight.bold)),
                    ),
                    Text(price, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocalCard(String title, String subtitle, String img) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.black.withOpacity(0.4),
        ),
        alignment: Alignment.bottomLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'serif', color: Colors.white)),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 10, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
