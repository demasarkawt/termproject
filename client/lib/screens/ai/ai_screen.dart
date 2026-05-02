// Polished cinematic AI screen — chat / mood / trip planner.
// Drop into: lib/screens/ai/ai_screen.dart
// Preserves: same endpoints (/api/ai/mood-search, /api/ai/plan-trip),
// PlaceRepo fallback, all controllers.
 
import 'dart:convert';
 
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
 
import '../../config/api_config.dart';
import '../../data/place_repo.dart';
import '../../services/theme_service.dart';
import '../../widgets/cinematic.dart';
 
class AiScreen extends StatefulWidget {
  const AiScreen({super.key});
 
  @override
  State<AiScreen> createState() => _AiScreenState();
}
 
class _AiScreenState extends State<AiScreen>
    with TickerProviderStateMixin {
  final _moodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _interestsCtrl = TextEditingController();
 
  bool _moodLoading = false;
  bool _tripLoading = false;
  List<dynamic> _moodResults = [];
  String? _tripItinerary;
  String? _tripCity;
  bool _searched = false;
 
  static const _suggestions = [
    'Quiet nature spot',
    'Historical site',
    'Family-friendly',
    'Adventure',
    'Waterfalls',
    'Mountain view',
  ];
 
  static const _cities = ['Erbil', 'Sulaymaniyah', 'Duhok', 'Halabja'];
 
  Future<void> _searchByMood() async {
    final prompt = _moodCtrl.text.trim();
    if (prompt.isEmpty) return;
 
    setState(() {
      _moodLoading = true;
      _searched = true;
      _moodResults = [];
    });
 
    try {
      final res = await http
          .post(
            Uri.parse('$kBaseUrl/api/ai/mood-search'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'prompt': prompt}),
          )
          .timeout(const Duration(seconds: 4));
 
      if (res.statusCode == 200) {
        setState(() {
          _moodResults = jsonDecode(res.body);
          _moodLoading = false;
        });
        return;
      }
    } catch (_) {}
 
    // Local fallback.
    final q = prompt.toLowerCase();
    final local = PlaceRepo.all
        .where((p) =>
            q == 'all' ||
            q.isEmpty ||
            p.title.toLowerCase().contains(q) ||
            p.about.toLowerCase().contains(q) ||
            p.cityId.toLowerCase().contains(q) ||
            p.categoryId.toLowerCase().contains(q))
        .map((p) => {
              'name': p.title,
              'category': p.categoryId,
              'description': p.about,
            })
        .toList();
    if (local.length > 10) {
      local.shuffle();
      local.removeRange(10, local.length);
    }
 
    setState(() {
      _moodResults = local;
      _moodLoading = false;
    });
  }
 
  Future<void> _planTrip() async {
    final city = _cityCtrl.text.trim();
    final interests = _interestsCtrl.text.trim();
    if (city.isEmpty || interests.isEmpty) return;
 
    setState(() {
      _tripLoading = true;
      _tripItinerary = null;
      _tripCity = city;
    });
 
    try {
      final res = await http
          .post(
            Uri.parse('$kBaseUrl/api/ai/plan-trip'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'city': city, 'interests': interests}),
          )
          .timeout(const Duration(seconds: 6));
 
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        setState(() {
          _tripItinerary = body['itinerary']?.toString() ?? body.toString();
          _tripLoading = false;
        });
        return;
      }
    } catch (_) {}
 
    setState(() {
      _tripItinerary =
          'Day 1 — explore the heart of $city, focusing on $interests.\n'
          'Day 2 — venture beyond the city for surrounding nature & local cuisine.\n'
          'Day 3 — bazaar morning, sunset viewpoint.';
      _tripLoading = false;
    });
  }
 
  @override
  void dispose() {
    _moodCtrl.dispose();
    _cityCtrl.dispose();
    _interestsCtrl.dispose();
    super.dispose();
  }
 
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeService,
      builder: (context, _) {
        final isDark = themeService.isDark;
        final ink = isDark ? Colors.white : KurdishHeritageColors.res;
 
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(24, 80, 24, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [
                    Icon(Icons.auto_awesome_rounded, color: KurdishHeritageColors.zer, size: 20),
                    SizedBox(width: 10),
                    Text('AI ASSISTANT',
                        style: TextStyle(
                          color: KurdishHeritageColors.zer,
                          fontSize: 11,
                          letterSpacing: 5,
                          fontWeight: FontWeight.w900,
                        )),
                  ]),
                  const SizedBox(height: 12),
                  RevealText(
                    'Plan with\nIntelligence',
                    style: TextStyle(
                        color: ink,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        height: 1.05),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tell us your mood or destination — we’ll do the rest.',
                    style: TextStyle(
                      color: ink.withOpacity(0.6),
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 28),
 
                  // ── Mood section ──────────────────────────────────────
                  _SectionCard(
                    isDark: isDark,
                    title: 'WHAT\'S YOUR MOOD?',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _moodCtrl,
                          style: TextStyle(color: ink),
                          decoration: InputDecoration(
                            hintText: 'e.g. quiet nature spot',
                            hintStyle: TextStyle(color: ink.withOpacity(0.4)),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: KurdishHeritageColors.zer),
                            filled: true,
                            fillColor: ink.withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          onSubmitted: (_) => _searchByMood(),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final s in _suggestions)
                              PressScale(
                                onTap: () {
                                  _moodCtrl.text = s;
                                  _searchByMood();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: ink.withOpacity(0.05),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: ink.withOpacity(0.12),
                                    ),
                                  ),
                                  child: Text(
                                    s,
                                    style: TextStyle(
                                      color: ink.withOpacity(0.85),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        PressScale(
                          onTap: _moodLoading ? null : _searchByMood,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: KurdishHeritageColors.sor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _moodLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'FIND MY VIBE',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
 
                  if (_searched) ...[
                    const SizedBox(height: 16),
                    _MoodResults(results: _moodResults, ink: ink, loading: _moodLoading),
                  ],
 
                  const SizedBox(height: 28),
 
                  // ── Trip planner ──────────────────────────────────
                  _SectionCard(
                    isDark: isDark,
                    title: 'PLAN A TRIP',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            for (final city in _cities)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: PressScale(
                                  onTap: () => setState(() => _cityCtrl.text = city),
                                  child: AnimatedContainer(
                                    duration: Motion.sm,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: _cityCtrl.text == city
                                          ? KurdishHeritageColors.kesk
                                          : ink.withOpacity(0.05),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Text(
                                      city,
                                      style: TextStyle(
                                        color: _cityCtrl.text == city
                                            ? Colors.white
                                            : ink,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _interestsCtrl,
                          style: TextStyle(color: ink),
                          decoration: InputDecoration(
                            hintText: 'What do you love? (food, history, hikes…)',
                            hintStyle: TextStyle(color: ink.withOpacity(0.4)),
                            prefixIcon: const Icon(Icons.favorite_rounded,
                                color: KurdishHeritageColors.sor),
                            filled: true,
                            fillColor: ink.withOpacity(0.04),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        PressScale(
                          onTap: _tripLoading ? null : _planTrip,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: KurdishHeritageColors.kesk,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: _tripLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text(
                                    'GENERATE ITINERARY',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: 2,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
 
                  if (_tripItinerary != null) ...[
                    const SizedBox(height: 16),
                    _ItineraryCard(
                        city: _tripCity ?? '', itinerary: _tripItinerary!, ink: ink),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
 
// ─────────── Section card ───────────
 
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  final bool isDark;
  const _SectionCard(
      {required this.title, required this.child, required this.isDark});
 
  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? Colors.white.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: (isDark ? Colors.white : Colors.black).withOpacity(0.06),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: isDark ? KurdishHeritageColors.zer : KurdishHeritageColors.res,
                fontSize: 10,
                letterSpacing: 2,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}
 
// ─────────── Mood results ────────────────
 
class _MoodResults extends StatelessWidget {
  final List<dynamic> results;
  final Color ink;
  final bool loading;
  const _MoodResults({required this.results, required this.ink, required this.loading});
 
  @override
  Widget build(BuildContext context) {
    if (loading) return const SizedBox.shrink();
    if (results.isEmpty) return const SizedBox.shrink();
 
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'SUGGESTED FOR YOU',
            style: TextStyle(
              color: ink.withOpacity(0.4),
              fontSize: 10,
              letterSpacing: 2,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: results.length,
            itemBuilder: (context, i) {
              final r = results[i];
              return ScrollReveal(
                duration: Duration(milliseconds: Motion.md.inMilliseconds + (i * 40)),
                child: Container(
                  width: 240,
                  margin: const EdgeInsets.only(right: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: ink.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: ink.withOpacity(0.08)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (r['category'] ?? 'PLACE').toString().toUpperCase(),
                        style: const TextStyle(
                          color: KurdishHeritageColors.zer,
                          fontSize: 9,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        r['name'] ?? 'Unknown',
                        style: TextStyle(
                          color: ink,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        r['description'] ?? '',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: ink.withOpacity(0.6),
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
 
// ─────────── Itinerary card ────────────────
 
class _ItineraryCard extends StatelessWidget {
  final String city;
  final String itinerary;
  final Color ink;
  const _ItineraryCard({required this.city, required this.itinerary, required this.ink});
 
  @override
  Widget build(BuildContext context) {
    return ScrollReveal(
      child: Glass(
        radius: 24,
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: KurdishHeritageColors.zer, size: 20),
                const SizedBox(width: 10),
                Text(
                  'ITINERARY FOR $city'.toUpperCase(),
                  style: const TextStyle(
                    color: KurdishHeritageColors.zer,
                    fontSize: 11,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              itinerary,
              style: TextStyle(
                color: ink.withOpacity(0.9),
                fontSize: 14,
                height: 1.8,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                const Spacer(),
                PressScale(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: KurdishHeritageColors.zer.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Text(
                      'SAVE TO TRIPS',
                      style: TextStyle(
                        color: KurdishHeritageColors.zer,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
