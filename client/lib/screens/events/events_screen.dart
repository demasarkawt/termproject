import 'package:flutter/material.dart';

class EventsScreen extends StatelessWidget {
  const EventsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF1F5E37);
    const backgroundLight = Color(0xFFF9FAFB);

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: SingleChildScrollView(
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    const Text('IMMERSIVE TRADITIONS', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryGreen, letterSpacing: 1.2)),
                    const SizedBox(height: 8),
                    const Text(
                      'Upcoming\nEvents &\nFestivals',
                      style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, fontFamily: 'serif', height: 1.1),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Experience the pulse of the Zagros\nmountains. From the ancient fire\nfestivals of Newroz to the vibrant harvest\ncelebrations of the valleys.',
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
                    ),
                    const SizedBox(height: 24),

                    // Upcoming Pomegranate Festival Banner
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: Color(0xFFFFA726), shape: BoxShape.circle),
                            child: const Icon(Icons.flash_on, color: Colors.white, size: 12),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('UPCOMING', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey)),
                              Text('Pomegranate Festival', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Calendar Widget placeholder
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Icon(Icons.chevron_left, color: Colors.grey),
                              const Text('March 2024', style: TextStyle(fontWeight: FontWeight.w900, fontFamily: 'serif', fontSize: 16)),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: List.generate(
                              ['S','M','T','W','T','F','S'].length,
                              (index) => Text(['S','M','T','W','T','F','S'][index], style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Placeholder for days grid, showing only 1 row to mimic the selected 20-21 range
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              const Text('17', style: TextStyle(color: Colors.black54)),
                              const Text('18', style: TextStyle(color: Colors.black54)),
                              const Text('19', style: TextStyle(color: Colors.black54)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFFF3E0),
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
                                ),
                                child: const Text('20', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF422006))),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                decoration: BoxDecoration(
                                  color: primaryGreen.withOpacity(0.2),
                                  borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                                ),
                                child: const Text('21', style: TextStyle(fontWeight: FontWeight.bold, color: primaryGreen)),
                              ),
                              const Text('22', style: TextStyle(color: Colors.black54)),
                              const Text('23', style: TextStyle(color: Colors.black54)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Filter by City
                    Row(
                      children: [
                        const Text('Filter by city:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(width: 8),
                        _buildFilterPill('All Cities', true),
                        const SizedBox(width: 8),
                        _buildFilterPill('Erbil', false),
                        const SizedBox(width: 8),
                        _buildFilterPill('Sul...', false),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Filter by Type
                    Row(
                      children: [
                        const Text('Type:', style: TextStyle(fontSize: 10, color: Colors.grey)),
                        const SizedBox(width: 8),
                        _buildTypePill(Icons.music_note, 'Music'),
                        const SizedBox(width: 8),
                        _buildTypePill(Icons.restaurant, 'Food'),
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Countdown Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E1C14), // Dark brown
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildCountdownCol('12', 'DAYS'),
                              _buildCountdownCol('08', 'HRS'),
                              _buildCountdownCol('45', 'MIN'),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(color: primaryGreen, borderRadius: BorderRadius.circular(12)),
                                  child: const Text('RSVP\nNow', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.calendar_today, color: Colors.white, size: 16),
                                      SizedBox(width: 8),
                                      Text('Add to\nCalendar', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Event Card 1
                    _buildEventCard(
                      'Citadel Flavors Expo',
                      'A two-day sensory journey through\nKurdish recipes and traditions at the\nheart of Erbil.',
                      'FOOD & CULTURE',
                      'assets/images/cha.JPEG', // placeholder
                    ),
                    const SizedBox(height: 24),

                    // Event Card 2
                    _buildEventCard(
                      'Mountain Melodies',
                      'Where traditional Kurdish instruments\nmeet modern jazz under the stars of\nSulaymaniyah.',
                      'MUSIC',
                      'assets/images/sulaymaniyah.jpg', // placeholder
                      buttonLabel: 'Get Tickets'
                    ),
                    const SizedBox(height: 24),

                    // Host Festival Promo Card
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: primaryGreen,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Host Your Own\nVillage Festival',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, fontFamily: 'serif', color: Colors.white, height: 1.1),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Are you organizing a\ncommunity event? List it on\nKurdistan Go to reach\nthousands of travelers and\nheritage enthusiasts.',
                            style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 11, height: 1.4),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                decoration: BoxDecoration(color: const Color(0xFFFFA726), borderRadius: BorderRadius.circular(12)),
                                child: const Text('Submit\nEvent', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF422006))),
                              ),
                              const SizedBox(width: 16),
                              const Text('Guidelines ->', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.asset('assets/images/erbil.jpg', height: 100, width: double.infinity, fit: BoxFit.cover),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // FAB padding
                  ],
                ),
              ),
            ],
          ),
        ),
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

  Widget _buildTypePill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10, color: Colors.black87, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildCountdownCol(String val, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
          child: Text(val, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 8, color: Colors.white70, letterSpacing: 1.5)),
      ],
    );
  }

  Widget _buildEventCard(String title, String desc, String tag, String img, {String buttonLabel = 'View Details'}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              image: DecorationImage(image: AssetImage(img), fit: BoxFit.cover),
            ),
            padding: const EdgeInsets.all(12),
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Text(tag, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37))),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, fontFamily: 'serif')),
                const SizedBox(height: 8),
                Text(desc, style: const TextStyle(fontSize: 10, color: Colors.grey, height: 1.4)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Fake face pile
                    Row(
                      children: [
                        _buildFacePile(),
                        const SizedBox(width: 8),
                        const Text('102 Going', style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12)),
                      child: Text(buttonLabel, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFacePile() {
    return SizedBox(
      width: 50,
      height: 20,
      child: Stack(
        children: [
          Positioned(left: 0, child: _faceCircle()),
          Positioned(left: 10, child: _faceCircle()),
          Positioned(left: 20, child: _faceCircle(isOrange: true)),
        ],
      ),
    );
  }

  Widget _faceCircle({bool isOrange = false}) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: isOrange ? const Color(0xFFFFA726) : Colors.grey.shade400,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }
}
