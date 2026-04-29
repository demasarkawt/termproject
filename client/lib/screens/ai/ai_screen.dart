import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/api_config.dart';
import '../../services/theme_service.dart';
import '../../data/place_repo.dart';

class AiScreen extends StatefulWidget {
  const AiScreen({super.key});

  @override
  State<AiScreen> createState() => _AiScreenState();
}

class _AiScreenState extends State<AiScreen> {
  final TextEditingController _moodController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _interestsController = TextEditingController();

  bool _isMoodLoading = false;
  bool _isTripLoading = false;

  List<dynamic> _moodResults = [];
  String? _tripItinerary;
  String? _tripCity;

  bool _hasMoodSearched = false;
  bool _hasTripPlanned = false;

  static const _suggestedPrompts = [
    'Quiet nature spot',
    'Historical site',
    'Family-friendly',
    'Adventure',
    'Waterfalls',
    'Mountain view',
  ];

  static const _cities = ['Erbil', 'Sulaymaniyah', 'Duhok', 'Halabja'];

  Future<void> _searchByMood() async {
    final prompt = _moodController.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isMoodLoading = true;
      _hasMoodSearched = true;
      _moodResults = [];
    });

    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/ai/mood-search'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        setState(() {
          _moodResults = jsonDecode(response.body);
          _isMoodLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('AI Mood API failed: $e');
    }

    // ✅ LOCAL FALLBACK
    final query = prompt.toLowerCase();
    final localMatches = PlaceRepo.all.where((p) {
      if (query == 'all' || query == 'everything' || query == '*' || query.isEmpty) return true;

      return p.title.toLowerCase().contains(query) || 
             p.about.toLowerCase().contains(query) ||
             p.cityId.toLowerCase().contains(query) ||
             p.categoryId.toLowerCase().contains(query);
    }).map((p) => {
      'name': p.title,
      'category': p.categoryId,
      'description': p.about,
    }).toList();

    // Limit to top results to keep it clean
    if (localMatches.length > 20) {
      localMatches.shuffle();
      localMatches.removeRange(10, localMatches.length);
    }

    setState(() {
      _moodResults = localMatches;
      _isMoodLoading = false;
    });
  }

  Future<void> _planTrip() async {
    final city = _cityController.text.trim();
    final interests = _interestsController.text.trim();
    if (city.isEmpty || interests.isEmpty) {
      _showError('Please enter a city and your interests.');
      return;
    }

    setState(() {
      _isTripLoading = true;
      _hasTripPlanned = true;
      _tripItinerary = null;
      _tripCity = city;
    });

    try {
      final response = await http.post(
        Uri.parse('$kBaseUrl/api/ai/trip-planner'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'city': city, 'interests': interests}),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tripItinerary = data['itinerary'];
          _isTripLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('AI Planner API failed: $e');
    }

    // ✅ LOCAL FALLBACK (Curated Static Itineraries)
    String fallback = 'A perfect day in $city exploring $interests:\n\n';
    if (city.toLowerCase() == 'erbil') {
      fallback += '• 09:00: Breakfast at the Citadel tea house.\n• 11:00: Explore the Textile Museum.\n• 13:00: Lunch at Abu Afif.\n• 15:00: Walk through Minaret Park.\n• 18:00: Sunset views from Sami Abdulrahman Park.';
    } else if (city.toLowerCase() == 'sulaymaniyah') {
      fallback += '• 09:00: Morning tea at Lali Coffee.\n• 11:00: Amna Suraka (Red Security Museum).\n• 14:00: Picnic at Goyzha Mountain.\n• 16:00: Shopping at the Bazaar.\n• 19:00: Dinner at Salim Street.';
    } else if (city.toLowerCase() == 'duhok') {
      fallback += '• 08:00: Drive to Amedi Village.\n• 11:00: Discover the ancient city gates.\n• 13:00: Lunch overlooking the valley.\n• 15:00: Visit Gali Sherana waterfalls.\n• 17:00: Evening at Duhok Dam.';
    } else {
      fallback += '• 10:00: Visit the local heritage museum.\n• 12:00: Lunch with traditional Kurdish dishes.\n• 14:00: Scenic walk through the old town.\n• 16:00: Sunset at the best local viewpoint.';
    }

    setState(() {
      _tripItinerary = fallback;
      _isTripLoading = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: KurdishHeritageColors.sor),
    );
  }

  @override
  void dispose() {
    _moodController.dispose();
    _cityController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // ── Background Glow Blobs ──────────────────────────────────────────
          _buildGlowBlob(const Color(0xFF1E3A8A).withOpacity(0.1), -100, 100, 400),
          _buildGlowBlob(KurdishHeritageColors.kesk.withOpacity(0.1), 300, 400, 300),

          SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // ── Header ───────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI ASSISTANT',
                          style: TextStyle(
                            color: KurdishHeritageColors.zer,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: 32),
                        Text(
                          'Curated by Mercury 2',
                          style: TextStyle(
                            color: isDark ? Colors.white : KurdishHeritageColors.res,
                            fontWeight: FontWeight.w900,
                            fontSize: 36,
                            letterSpacing: -1.5,
                          ),
                        ),
                        Text(
                          'Your intelligent Travelo trip companion',
                          style: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.5) : Colors.black.withOpacity(0.5),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Mood Search Section ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('SEARCH BY MOOD', isDark),
                        const SizedBox(height: 16),
                        _buildGlassSearchBar(isDark),
                        const SizedBox(height: 16),
                        _buildSuggestedPrompts(isDark),
                      ],
                    ),
                  ),
                ),

                if (_hasMoodSearched)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _buildPlaceCard(_moodResults[i], isDark),
                        childCount: _moodResults.length,
                      ),
                    ),
                  ),

                // ── Trip Planner Section ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('DAY PLANNER', isDark),
                        const SizedBox(height: 16),
                        _buildCityPicker(isDark),
                        const SizedBox(height: 16),
                        _buildInterestField(isDark),
                        const SizedBox(height: 20),
                        _buildPlanButton(isDark),
                      ],
                    ),
                  ),
                ),

                if (_hasTripPlanned)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 150),
                    sliver: SliverToBoxAdapter(
                      child: _buildTripResultsCard(isDark),
                    ),
                  ),
                
                if (!_hasTripPlanned)
                  const SliverToBoxAdapter(child: SizedBox(height: 150)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlowBlob(Color color, double left, double top, double size) {
    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(title, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: KurdishHeritageColors.zer));
  }

  Widget _buildGlassSearchBar(bool isDark) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _moodController,
              style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res),
              decoration: InputDecoration(
                hintText: 'Describe your mood...',
                border: InputBorder.none,
                hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24)),
              ),
              onSubmitted: (_) => _searchByMood(),
            ),
          ),
          GestureDetector(
            onTap: _searchByMood,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(color: KurdishHeritageColors.zer, shape: BoxShape.circle),
              child: _isMoodLoading
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestedPrompts(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _suggestedPrompts.map((p) => GestureDetector(
        onTap: () {
          _moodController.text = p;
          _searchByMood();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
          ),
          child: Text(p, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : KurdishHeritageColors.res)),
        ),
      )).toList(),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(place['name'] ?? '', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: isDark ? Colors.white : KurdishHeritageColors.res))),
              if (place['category'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: KurdishHeritageColors.kesk.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(place['category'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: KurdishHeritageColors.kesk)),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(place['description'] ?? '', style: TextStyle(fontSize: 13, color: isDark ? Colors.white60 : Colors.black54, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildCityPicker(bool isDark) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _cities.map((city) => GestureDetector(
        onTap: () => setState(() => _cityController.text = city),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _cityController.text == city ? KurdishHeritageColors.zer : (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cityController.text == city ? Colors.white.withOpacity(0.2) : (isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05))),
          ),
          child: Text(city, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _cityController.text == city ? Colors.white : (isDark ? Colors.white70 : KurdishHeritageColors.res))),
        ),
      )).toList(),
    );
  }

  Widget _buildInterestField(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.1)),
      ),
      child: TextField(
        controller: _interestsController,
        style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res),
        decoration: InputDecoration(
          hintText: 'Interests (e.g. food, mountains, history)',
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24)),
        ),
      ),
    );
  }

  Widget _buildPlanButton(bool isDark) {
    return GestureDetector(
      onTap: _planTrip,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          color: KurdishHeritageColors.sor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: KurdishHeritageColors.sor.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
        ),
        alignment: Alignment.center,
        child: _isTripLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('PLAN MY JOURNEY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
      ),
    );
  }

  Widget _buildTripResultsCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : KurdishHeritageColors.xweli.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome_rounded, color: KurdishHeritageColors.zer),
              const SizedBox(width: 12),
              Text('$_tripCity Itinerary', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: isDark ? Colors.white : KurdishHeritageColors.res)),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            _tripItinerary ?? '',
            style: TextStyle(fontSize: 15, color: isDark ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.7), height: 1.7),
          ),
        ],
      ),
    );
  }
}
