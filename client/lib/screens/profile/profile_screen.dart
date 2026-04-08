import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1F5E37);
    const backgroundLight = Color(0xFFF8F9FB);
    const textDark = Color(0xFF1E1E1E);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                    Row(
                      children: const [
                        Icon(Icons.settings_outlined, color: Colors.black54),
                        SizedBox(width: 16),
                        Icon(Icons.wb_sunny_outlined, color: Colors.green), // Assuming standard green
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),

                // Avatar
                Stack(
                  alignment: Alignment.bottomCenter,
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: const DecorationImage(
                          image: AssetImage('assets/images/sulaymaniyah.jpg'), // using placeholder
                          fit: BoxFit.cover,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          )
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: -10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFA726),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Level 14',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name
                const Text(
                  'Aveen å awrami',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    fontFamily: 'serif',
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'KURDISTAN EXPLORER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 20),

                // Stats
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatCol('12', 'PLACES VISITED'),
                    Container(width: 1, height: 30, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 20)),
                    _buildStatCol('4', 'ACTIVITIES DONE'),
                  ],
                ),
                const SizedBox(height: 10),
                _buildStatCol('8', 'REVIEWS'),
                
                const SizedBox(height: 30),

                // My Trips Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'My Trips',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: textDark,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFA726),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Upcoming',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            child: Text(
                              'Past',
                              style: TextStyle(fontSize: 10, color: Colors.black54),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // My Trips Card
                Container(
                  width: double.infinity,
                  height: 160,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: const DecorationImage(
                      image: AssetImage('assets/images/duhok.jpg'), // Placeholder
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                        colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFA726),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SEP 12 - 15, 2024',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'Majestic\nRawanduz\nExpedition',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'serif',
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: const [
                                Icon(Icons.location_on_outlined, color: Colors.white70, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Soran District, Kurdistan',
                                  style: TextStyle(fontSize: 11, color: Colors.white70),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: InkWell(
                            onTap: () {},
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: primaryGreen,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'View\nDetails',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),

                // Saved Collections Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Saved Collections',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'serif',
                        color: textDark,
                      ),
                    ),
                    Row(
                      children: const [
                        Text('View All', style: TextStyle(color: primaryGreen, fontSize: 12, fontWeight: FontWeight.bold)),
                        Icon(Icons.arrow_forward_rounded, color: primaryGreen, size: 14),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 16),

                // Saved Collections Horizontal List
                SizedBox(
                  height: 180,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildCollectionCard('Sacred Sites', '8 ITEMS', 'assets/images/erbil.jpg'), // Replace img
                      const SizedBox(width: 12),
                      _buildCollectionCard('Mountain Retreats', '14 ITEMS', 'assets/images/shanadar.JPEG'),
                      const SizedBox(width: 12),
                      _buildCollectionCard('Local Flavors', '5 ITEMS', 'assets/images/cha.JPEG'),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Regional Badges
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Regional Badges',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'serif',
                          color: textDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBadge(Icons.castle_outlined, 'CITADEL MASTER', '5/5', const Color(0xFFFBE9E7), const Color(0xFFD84315)),
                          _buildBadge(Icons.landscape_outlined, 'PEAK CLIMBER', '3/5', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBadge(Icons.water_drop_outlined, 'RIVER SEEKER', 'LOCKED', Colors.grey.shade100, Colors.grey),
                          _buildBadge(Icons.menu_book_outlined, 'LORE KEEPER', 'NEW', const Color(0xFFFFEBEE), const Color(0xFFC62828)),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('NEXT MILESTONE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black54)),
                          Text('75%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryGreen)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.75,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(primaryGreen),
                          minHeight: 6,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          'Visit one more site in Sulaymaniyah to unlock "River Seeker"',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 9, color: Colors.black45),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Settings List
                _buildMenuItem(Icons.person_outline, 'Personal Information'),
                const SizedBox(height: 12),
                _buildMenuItem(Icons.payment_outlined, 'Payment Methods'),
                const SizedBox(height: 12),
                _buildMenuItem(Icons.security_outlined, 'Privacy & Security'),
                const SizedBox(height: 12),
                
                // Logout Button
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFFBE9E7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout_outlined, color: Color(0xFFD84315)),
                    title: const Text(
                      'Logout',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFFD84315)),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFD84315)),
                    onTap: () {},
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String val, String label) {
    return Column(
      children: [
        Text(val, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCollectionCard(String title, String subtitle, String img) {
    return SizedBox(
      width: 120,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: AssetImage(img),
                  fit: BoxFit.cover,
                ),
              ),
              alignment: Alignment.topRight,
              padding: const EdgeInsets.all(8),
              child: const Icon(Icons.favorite, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1E1E1E)),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String title, String subtitle, Color bgColor, Color iconColor) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
        Text(subtitle, style: const TextStyle(fontSize: 8, color: Colors.grey)),
      ],
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2)),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
