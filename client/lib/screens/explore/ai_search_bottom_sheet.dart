import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:go_router/go_router.dart';

import '../../config/api_config.dart';
import '../../services/theme_service.dart';
import '../../data/place_repo.dart';

class AiSearchBottomSheet extends StatefulWidget {
  const AiSearchBottomSheet({super.key});

  @override
  State<AiSearchBottomSheet> createState() => _AiSearchBottomSheetState();
}

class _AiSearchBottomSheetState extends State<AiSearchBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _results = [];
  bool _hasSearched = false;

  Future<void> _searchByMood() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty) return;

    setState(() {
      _isLoading = true;
      _hasSearched = true;
      _results = [];
    });

    try {
      final url = Uri.parse('$kBaseUrl/api/ai/mood-search');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'prompt': prompt}),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        setState(() {
          _results = jsonDecode(response.body);
          _isLoading = false;
        });
        return;
      }
    } catch (e) {
      debugPrint('AI API failed, falling back to local search: $e');
    }

    // ✅ LOCAL FALLBACK (Enhanced matching)
    final query = prompt.toLowerCase();
    
    // If user typed "all" or similar, show everything.
    // If the query matches nothing specific, show some top picks.
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
      'id': p.id,
    }).toList();

    // Limit to top results to keep it clean
    if (localMatches.length > 20) {
      localMatches.shuffle();
      localMatches.removeRange(10, localMatches.length);
    }

    setState(() {
      _results = localMatches;
      _isLoading = false;
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: KurdishHeritageColors.sor));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? KurdishHeritageColors.res : KurdishHeritageColors.spi,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : Colors.black.withOpacity(0.05)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(color: isDark ? Colors.white.withOpacity(0.24) : Colors.black12, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'AI MOOD SEARCH',
                style: TextStyle(color: KurdishHeritageColors.zer, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 2),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: isDark ? Colors.white54 : Colors.black54),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Describe your perfect journey',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: isDark ? Colors.white : KurdishHeritageColors.res,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 24),
          
          // Search Input
          Container(
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
                    controller: _controller,
                    style: TextStyle(color: isDark ? Colors.white : KurdishHeritageColors.res),
                    decoration: InputDecoration(
                      hintText: 'e.g. "A calm place near waterfalls"',
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
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: KurdishHeritageColors.zer))
              : _hasSearched && _results.isEmpty
                ? Center(child: Text('No results found', style: TextStyle(color: isDark ? Colors.white.withOpacity(0.24) : Colors.black.withOpacity(0.24), fontWeight: FontWeight.bold)))
                : ListView.builder(
                    itemCount: _results.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) => _buildPlaceResult(_results[index], isDark),
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaceResult(Map<String, dynamic> place, bool isDark) {
    return GestureDetector(
      onTap: () {
        if (place['id'] != null) {
          Navigator.pop(context);
          context.go('/place/${place['id']}');
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
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
                Expanded(
                  child: Text(
                    place['name'] ?? '',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : KurdishHeritageColors.res),
                  ),
                ),
                if (place['category'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: KurdishHeritageColors.kesk.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                    child: Text(place['category'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: KurdishHeritageColors.kesk)),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              place['description'] ?? '',
              style: TextStyle(fontSize: 14, color: isDark ? Colors.white60 : Colors.black54, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
