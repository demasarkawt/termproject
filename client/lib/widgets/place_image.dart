import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PlaceImage extends StatefulWidget {
  final String imagePath;
  final String title;
  final BoxFit fit;

  const PlaceImage({
    super.key,
    required this.imagePath,
    required this.title,
    this.fit = BoxFit.cover,
  });

  @override
  State<PlaceImage> createState() => _PlaceImageState();
}

class _PlaceImageState extends State<PlaceImage> {
  String? _networkUrl;
  bool _isLoading = true;
  bool _hasError = false;

  // Cache to avoid duplicate network calls
  static final Map<String, String?> _urlCache = {};

  @override
  void initState() {
    super.initState();
    _fetchWikiImage();
  }

  @override
  void didUpdateWidget(PlaceImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.title != widget.title) {
      _fetchWikiImage();
    }
  }

  Future<void> _fetchWikiImage() async {
    // Determine a good search term for Wikipedia based on the place title
    String searchTerm = widget.title;
    if (searchTerm.contains('Citadel')) searchTerm = 'Citadel of Erbil';
    else if (searchTerm.contains('Bekhal')) searchTerm = 'Bekhal Waterfall';
    else if (searchTerm.contains('Shanadar')) searchTerm = 'Shanidar Cave';
    else if (searchTerm.contains('Halabja Monument')) searchTerm = 'Halabja monument';
    else if (searchTerm.contains('Amedi')) searchTerm = 'Amadiya';
    else if (searchTerm.contains('Duhok Dam')) searchTerm = 'Duhok Dam';
    else if (searchTerm.contains('Sulaimaniyah Bazaar')) searchTerm = 'Sulaymaniyah';
    else if (searchTerm.contains('Dukan')) searchTerm = 'Lake Dukan';
    else if (searchTerm.contains('Lalish')) searchTerm = 'Lalish';
    else if (searchTerm.contains('Ahmed Awa')) searchTerm = 'Ahmad Awa';
    else if (searchTerm.contains('Gali Ali Beg')) searchTerm = 'Gali Ali Beg Waterfall';
    else if (searchTerm.contains('Sami Abdulrahman')) searchTerm = 'Sami Abdulrahman Park';
    else if (searchTerm.contains('Amna Suraka')) searchTerm = 'Amna Suraka';
    // Food & Dining – map to the city or cuisine Wikipedia page for best image
    else if (searchTerm.contains('Machko') || searchTerm.contains('Chaikhana')) searchTerm = 'Erbil';
    else if (searchTerm.contains('Abu Shihab')) searchTerm = 'Kurdish cuisine';
    else if (searchTerm.contains('Kebab Yasin')) searchTerm = 'Kebab';
    else if (searchTerm.contains('Dawa 2')) searchTerm = 'Dolma (food)';
    else if (searchTerm.contains('Shaab Teahouse') || searchTerm.contains('Chaikhanay')) searchTerm = 'Sulaymaniyah';
    else if (searchTerm.contains('Kebab Wasta')) searchTerm = 'Kebab';
    else if (searchTerm.contains("Chalak")) searchTerm = 'Sulaymaniyah';
    else if (searchTerm.contains('Kebab Kawa')) searchTerm = 'Duhok';
    else if (searchTerm.contains('Malta Restaurant')) searchTerm = 'Duhok';
    else if (searchTerm.contains('Mazi Mall')) searchTerm = 'Duhok';
    else if (searchTerm.contains('Hawraman Traditional')) searchTerm = 'Hawraman';
    else if (searchTerm.contains('Halabja Kebab')) searchTerm = 'Halabja';

    if (_urlCache.containsKey(searchTerm)) {
      if (mounted) {
        setState(() {
          _networkUrl = _urlCache[searchTerm];
          _isLoading = false;
        });
      }
      return;
    }

    try {
      final url = Uri.parse(
          'https://en.wikipedia.org/w/api.php?action=query&titles=${Uri.encodeComponent(searchTerm)}&prop=pageimages&format=json&pithumbsize=1000&origin=*');
      final response = await http.get(
        url,
        headers: {'User-Agent': 'KurdistanTravelApp/1.0 (contact@example.com)'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final queryMap = data['query'] as Map<String, dynamic>;
        final pages = queryMap['pages'] as Map<String, dynamic>;
        
        String? imageUrl;
        for (var pageValue in pages.values) {
          if (pageValue is Map<String, dynamic>) {
            if (pageValue.containsKey('thumbnail')) {
              final thumbnailMap = pageValue['thumbnail'] as Map<String, dynamic>;
              imageUrl = thumbnailMap['source'] as String?;
              break;
            }
          }
        }
        
        // If English wiki fails, try Arabic wiki for local places
        if (imageUrl == null) {
          final arUrl = Uri.parse(
              'https://ar.wikipedia.org/w/api.php?action=query&titles=${Uri.encodeComponent(searchTerm)}&prop=pageimages&format=json&pithumbsize=1000&origin=*');
          final arResponse = await http.get(
            arUrl,
            headers: {'User-Agent': 'KurdistanTravelApp/1.0 (contact@example.com)'},
          );
          if (arResponse.statusCode == 200) {
            final arData = json.decode(arResponse.body) as Map<String, dynamic>;
            final arQueryMap = arData['query'] as Map<String, dynamic>;
            final arPages = arQueryMap['pages'] as Map<String, dynamic>;
            for (var pageValue in arPages.values) {
              if (pageValue is Map<String, dynamic>) {
                if (pageValue.containsKey('thumbnail')) {
                  final thumbnailMap = pageValue['thumbnail'] as Map<String, dynamic>;
                  imageUrl = thumbnailMap['source'] as String?;
                  break;
                }
              }
            }
          }
        }

        _urlCache[searchTerm] = imageUrl;

        if (mounted) {
          setState(() {
            _networkUrl = imageUrl;
            _isLoading = false;
          });
        }
      } else {
        print('PlaceImage Error: Failed to fetch for $searchTerm with status ${response.statusCode}');
        throw Exception('Failed to load wiki image');
      }
    } catch (e) {
      print('PlaceImage Exception for $searchTerm: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        color: Colors.grey.shade200,
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F5E37)),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (_networkUrl != null) {
      return Image.network(
        _networkUrl!,
        fit: widget.fit,
        errorBuilder: (context, error, stackTrace) => _buildFallback(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey.shade200,
            child: const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F5E37)),
                strokeWidth: 2,
              ),
            ),
          );
        },
      );
    }

    return _buildFallback();
  }

  Widget _buildFallback() {
    return Image.asset(
      widget.imagePath,
      fit: widget.fit,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFEFFCF7),
          alignment: Alignment.center,
          child: const Icon(
            Icons.image_not_supported_rounded,
            color: Color(0xFF0F766E),
            size: 40,
          ),
        );
      },
    );
  }
}
