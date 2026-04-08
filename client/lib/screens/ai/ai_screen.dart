import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../config/api_config.dart';

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
      );

      if (response.statusCode == 200) {
        setState(() {
          _moodResults = jsonDecode(response.body);
          _isMoodLoading = false;
        });
      } else {
        setState(() => _isMoodLoading = false);
        _showError('AI search failed (${response.statusCode}). Please try again.');
      }
    } catch (e) {
      setState(() => _isMoodLoading = false);
      _showError('Connection error. Check your internet and try again.');
    }
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
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _tripItinerary = data['itinerary'];
          _isTripLoading = false;
        });
      } else {
        setState(() => _isTripLoading = false);
        _showError('Trip planner failed. Please try again.');
      }
    } catch (e) {
      setState(() => _isTripLoading = false);
      _showError('Connection error. Check your internet and try again.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              _buildMoodSearchSection(),
              if (_hasMoodSearched) _buildMoodResults(),
              const SizedBox(height: 24),
              _buildTripPlannerSection(),
              if (_hasTripPlanned) _buildTripResults(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.auto_awesome, color: Colors.white, size: 28),
              SizedBox(width: 10),
              Text(
                'AI Travel Assistant',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Powered by Mercury 2 — describe your mood or plan a full day trip.',
            style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSearchSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mood Search',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Describe what you feel like and the AI will find matching places.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // Suggested prompts
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestedPrompts.map((p) => GestureDetector(
              onTap: () {
                _moodController.text = p;
                _searchByMood();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Text(
                  p,
                  style: TextStyle(fontSize: 12, color: Colors.purple.shade700, fontWeight: FontWeight.w500),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 16),

          // Input row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.purple.shade200, width: 1.5),
              boxShadow: [
                BoxShadow(color: Colors.purple.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _moodController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. "A quiet green place with waterfalls"',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    onSubmitted: (_) => _searchByMood(),
                  ),
                ),
                GestureDetector(
                  onTap: _searchByMood,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(colors: [Colors.purple, Colors.deepPurple]),
                      shape: BoxShape.circle,
                    ),
                    child: _isMoodLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.search, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodResults() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _moodResults.isEmpty ? 'No matching places found.' : 'Best Matches (${_moodResults.length})',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          ..._moodResults.map((place) => _buildPlaceCard(place)).toList(),
        ],
      ),
    );
  }

  Widget _buildPlaceCard(Map<String, dynamic> place) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
        border: Border.all(color: Colors.purple.shade50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  place['name'] ?? 'Unknown Place',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37)),
                ),
              ),
              if (place['category'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    place['category'],
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.purple.shade700),
                  ),
                ),
            ],
          ),
          if (place['description'] != null) ...[
            const SizedBox(height: 8),
            Text(
              place['description'],
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
          ],
          if (place['rating'] != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.star, color: Color(0xFFFFA726), size: 14),
                const SizedBox(width: 4),
                Text(
                  '${place['rating']}',
                  style: const TextStyle(fontSize: 12, color: Colors.black54, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripPlannerSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: const [
              Icon(Icons.map_outlined, color: Color(0xFF6A1B9A), size: 20),
              SizedBox(width: 8),
              Text(
                '1-Day Trip Planner',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Tell us your city and interests — Mercury 2 will plan your perfect day.',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // City picker chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cities.map((city) => GestureDetector(
              onTap: () => setState(() => _cityController.text = city),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: _cityController.text == city ? const Color(0xFF6A1B9A) : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _cityController.text == city ? const Color(0xFF6A1B9A) : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  city,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _cityController.text == city ? Colors.white : Colors.black87,
                  ),
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 14),

          // Or type city
          _buildTextField(_cityController, 'City (e.g. Erbil)', Icons.location_city_outlined),
          const SizedBox(height: 12),
          _buildTextField(_interestsController, 'Your interests (e.g. history, nature, food)', Icons.favorite_outline),
          const SizedBox(height: 16),

          // Plan button
          SizedBox(
            width: double.infinity,
            child: GestureDetector(
              onTap: _planTrip,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF6A1B9A), Color(0xFF4527A0)]),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _isTripLoading
                    ? const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Plan My Trip',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
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

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripResults() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_tripCity != null)
            Text(
              'Your Day in $_tripCity',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1F5E37)),
            ),
          const SizedBox(height: 12),
          if (_tripItinerary != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade100),
                boxShadow: [
                  BoxShadow(color: Colors.purple.withOpacity(0.06), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Text(
                _tripItinerary!,
                style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.6),
              ),
            ),
        ],
      ),
    );
  }
}
