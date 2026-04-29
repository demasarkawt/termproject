import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:termproject/constants/app_branding.dart';
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
    return ListenableBuilder(
      listenable: ThemeService(),
      builder: (context, _) {
        final isDark = ThemeService().isDark;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              _buildGlowBlob(const Color(0xFF1E3A8A).withValues(alpha: 0.12), -100, 80, 420),
              _buildGlowBlob(KurdishHeritageColors.zer.withValues(alpha: 0.08), 260, 380, 340),

              SafeArea(
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(child: _buildAiHeroCard(isDark)),

                    // ── Mood Search Section ─────────────────────────────────────
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
                        child: _buildMoodComposer(isDark),
                      ),
                    ),

                    if (_hasMoodSearched)
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
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
                        padding: const EdgeInsets.fromLTRB(20, 40, 20, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('DAY PLANNER'),
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
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 150),
                        sliver: SliverToBoxAdapter(
                          child: _buildTripResultsCard(isDark),
                        ),
                      ),

                    if (!_hasTripPlanned) const SliverToBoxAdapter(child: SizedBox(height: 150)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildAiHeroCard(bool isDark) {
    final surfaceBorder = isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.07);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [const Color(0xFF1A2850), const Color(0xFF0D1526), const Color(0xFF121a2e)]
                : [const Color(0xFFEEF3FB), const Color(0xFFF8F4FF), const Color(0xFFFFF9F2)],
          ),
          border: Border.all(color: surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.07),
              blurRadius: 28,
              offset: const Offset(0, 14),
            ),
            BoxShadow(
              color: KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.12 : 0.18),
              blurRadius: 40,
              spreadRadius: -8,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            children: [
              Positioned(
                right: -30,
                top: -40,
                child: Icon(Icons.blur_on_rounded, size: 160, color: KurdishHeritageColors.zer.withValues(alpha: 0.07)),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 26, 22, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [KurdishHeritageColors.zer, Color(0xFFD4A84B)],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: KurdishHeritageColors.zer.withValues(alpha: 0.45),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.auto_awesome_rounded, size: 42, color: Color(0xFF1A1410)),
                        ),
                        const SizedBox(width: 18),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: KurdishHeritageColors.zer.withValues(alpha: 0.18),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: KurdishHeritageColors.zer.withValues(alpha: 0.35)),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.auto_awesome_rounded, size: 14, color: isDark ? Colors.white.withValues(alpha: 0.92) : KurdishHeritageColors.res),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Travel intelligence',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.6,
                                        color: isDark ? Colors.white.withValues(alpha: 0.88) : KurdishHeritageColors.res.withValues(alpha: 0.85),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                '${AppBranding.appName} AI',
                                style: TextStyle(
                                  color: isDark ? Colors.white : KurdishHeritageColors.res,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 28,
                                  letterSpacing: -0.8,
                                  height: 1.05,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Discover places by mood and sketch full-day plans tailored to how you want to feel.',
                                style: TextStyle(
                                  color: isDark ? Colors.white.withValues(alpha: 0.68) : KurdishHeritageColors.textMutedLight,
                                  fontSize: 14,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _heroMiniChip(isDark, Icons.psychology_alt_outlined, 'Mood match'),
                        _heroMiniChip(isDark, Icons.map_outlined, 'Local picks'),
                        _heroMiniChip(isDark, Icons.route_rounded, 'Day routes'),
                      ],
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

  Widget _heroMiniChip(bool isDark, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: KurdishHeritageColors.zer),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white.withValues(alpha: 0.82) : KurdishHeritageColors.res.withValues(alpha: 0.88),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodComposer(bool isDark) {
    final fill = isDark ? const Color(0xFF1C1915) : Colors.white;
    final fieldFill = isDark ? Colors.white.withValues(alpha: 0.06) : KurdishHeritageColors.surface3Light;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.22 : 0.28),
            KurdishHeritageColors.kesk.withValues(alpha: isDark ? 0.14 : 0.18),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: KurdishHeritageColors.zer.withValues(alpha: isDark ? 0.08 : 0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(1.5),
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 22),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(26.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        KurdishHeritageColors.zer.withValues(alpha: 0.2),
                        KurdishHeritageColors.kesk.withValues(alpha: 0.12),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(Icons.draw_rounded, color: KurdishHeritageColors.zer.withValues(alpha: isDark ? 1 : 0.95), size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Search by mood',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.4,
                          color: isDark ? Colors.white : KurdishHeritageColors.res,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Write freely — a sentence or two works best.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white.withValues(alpha: 0.52) : KurdishHeritageColors.textMutedLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            TextField(
              controller: _moodController,
              minLines: 4,
              maxLines: 8,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white.withValues(alpha: 0.95) : KurdishHeritageColors.res,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: fieldFill,
                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                hintText: 'Example: I want somewhere peaceful — mountain views, tea, and not too crowded…',
                hintStyle: TextStyle(
                  fontSize: 15,
                  height: 1.45,
                  fontWeight: FontWeight.w400,
                  color: isDark ? Colors.white.withValues(alpha: 0.28) : KurdishHeritageColors.textSubtleLight,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.08) : KurdishHeritageColors.borderLight),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: isDark ? Colors.white.withValues(alpha: 0.1) : KurdishHeritageColors.borderLight),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: KurdishHeritageColors.zer, width: 2),
                ),
              ),
              onSubmitted: (_) => _searchByMood(),
            ),
            const SizedBox(height: 16),
            Text(
              'Try an idea',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.6,
                color: KurdishHeritageColors.zer.withValues(alpha: 0.85),
              ),
            ),
            const SizedBox(height: 10),
            _buildSuggestedPrompts(isDark),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  elevation: 0,
                  backgroundColor: KurdishHeritageColors.zer,
                  foregroundColor: KurdishHeritageColors.res,
                  disabledBackgroundColor: KurdishHeritageColors.zer.withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                onPressed: _isMoodLoading ? null : _searchByMood,
                icon: _isMoodLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: KurdishHeritageColors.res),
                      )
                    : const Icon(Icons.travel_explore_rounded, size: 22),
                label: Text(
                  _isMoodLoading ? 'Finding places…' : 'Find matching places',
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 0.2),
                ),
              ),
            ),
          ],
        ),
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

  Widget _buildSectionHeader(String title) {
    return Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 2, color: KurdishHeritageColors.zer));
  }

  Widget _buildSuggestedPrompts(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _suggestedPrompts.map((p) {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () {
              _moodController.text = p;
              _searchByMood();
            },
            child: Ink(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: isDark ? Colors.white.withValues(alpha: 0.06) : KurdishHeritageColors.zer.withValues(alpha: 0.08),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.12) : KurdishHeritageColors.zer.withValues(alpha: 0.2)),
              ),
              child: Text(
                p,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white.withValues(alpha: 0.88) : KurdishHeritageColors.res,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05)),
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
                  decoration: BoxDecoration(color: KurdishHeritageColors.kesk.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
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
            color: _cityController.text == city ? KurdishHeritageColors.zer : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _cityController.text == city ? Colors.white.withValues(alpha: 0.2) : (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05))),
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
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.1)),
      ),
      child: TextField(
        controller: _interestsController,
        style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res),
        decoration: InputDecoration(
          hintText: 'Interests (e.g. food, mountains, history)',
          border: InputBorder.none,
          hintStyle: TextStyle(fontSize: 14, color: isDark ? Colors.white.withValues(alpha: 0.24) : Colors.black.withValues(alpha: 0.24)),
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
          boxShadow: [BoxShadow(color: KurdishHeritageColors.sor.withValues(alpha: 0.2), blurRadius: 15, offset: const Offset(0, 8))],
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
        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.1) : KurdishHeritageColors.xweli.withValues(alpha: 0.2)),
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
            style: TextStyle(fontSize: 15, color: isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black.withValues(alpha: 0.7), height: 1.7),
          ),
        ],
      ),
    );
  }
}
