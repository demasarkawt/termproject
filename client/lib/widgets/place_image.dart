import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Renders an image for a place.
///
/// Resolution priority:
///   1. If `imagePath` is an http(s) URL (e.g. a Cloudflare R2 URL coming
///      from the backend), render it directly with `CachedNetworkImage`.
///   2. Else if it's an asset path (assets/...), render it as an asset.
///   3. Else (legacy paths or empty), try Wikipedia's API for a thumbnail
///      based on `title`, then fall back to a placeholder.
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
  String? _wikiUrl;
  bool _isLoading = false;
  bool _wikiTried = false;

  static final Map<String, String?> _wikiCache = {};

  bool get _isNetwork =>
      widget.imagePath.startsWith('http://') ||
      widget.imagePath.startsWith('https://');

  bool get _isAsset => widget.imagePath.startsWith('assets/');

  @override
  void initState() {
    super.initState();
    if (!_isNetwork && !_isAsset) {
      _fetchWikiImage();
    }
  }

  @override
  void didUpdateWidget(PlaceImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imagePath != widget.imagePath ||
        oldWidget.title != widget.title) {
      _wikiUrl = null;
      _wikiTried = false;
      if (!_isNetwork && !_isAsset) {
        _fetchWikiImage();
      }
    }
  }

  Future<void> _fetchWikiImage() async {
    setState(() => _isLoading = true);
    final searchTerm = _wikipediaSearchTerm(widget.title);

    if (_wikiCache.containsKey(searchTerm)) {
      if (mounted) {
        setState(() {
          _wikiUrl = _wikiCache[searchTerm];
          _isLoading = false;
          _wikiTried = true;
        });
      }
      return;
    }

    try {
      final url = Uri.parse(
          'https://en.wikipedia.org/w/api.php?action=query&titles=${Uri.encodeComponent(searchTerm)}&prop=pageimages&format=json&pithumbsize=1000&origin=*');
      final response = await http.get(
        url,
        headers: {'User-Agent': 'Travelo/1.0 (contact@example.com)'},
      );
      String? imageUrl;
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final pages =
            (data['query'] as Map<String, dynamic>)['pages'] as Map<String, dynamic>;
        for (final v in pages.values) {
          if (v is Map<String, dynamic> && v.containsKey('thumbnail')) {
            imageUrl = (v['thumbnail'] as Map<String, dynamic>)['source'] as String?;
            break;
          }
        }
      }
      _wikiCache[searchTerm] = imageUrl;
      if (mounted) {
        setState(() {
          _wikiUrl = imageUrl;
          _isLoading = false;
          _wikiTried = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _wikiTried = true;
        });
      }
    }
  }

  String _wikipediaSearchTerm(String title) {
    if (title.contains('Citadel')) return 'Citadel of Erbil';
    if (title.contains('Bekhal')) return 'Bekhal Waterfall';
    if (title.contains('Shanidar') || title.contains('Shanadar')) {
      return 'Shanidar Cave';
    }
    if (title.contains('Halabja Monument')) return 'Halabja monument';
    if (title.contains('Amedi') || title.contains('Amadiya')) return 'Amadiya';
    if (title.contains('Lalish')) return 'Lalish';
    if (title.contains('Dukan')) return 'Lake Dukan';
    if (title.contains('Gali Ali Beg') || title.contains('Geli Ali Beg')) {
      return 'Gali Ali Beg Waterfall';
    }
    if (title.contains('Hawraman')) return 'Hawraman';
    if (title.contains('Korek')) return 'Mount Korek';
    return title;
  }

  @override
  Widget build(BuildContext context) {
    if (_isNetwork) {
      return CachedNetworkImage(
        imageUrl: widget.imagePath,
        fit: widget.fit,
        placeholder: (_, __) => _buildSpinner(),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }
    if (_isAsset) {
      return Image.asset(
        widget.imagePath,
        fit: widget.fit,
        errorBuilder: (_, __, ___) => _buildFallback(),
      );
    }
    if (_isLoading) {
      return _buildSpinner();
    }
    if (_wikiUrl != null) {
      return CachedNetworkImage(
        imageUrl: _wikiUrl!,
        fit: widget.fit,
        placeholder: (_, __) => _buildSpinner(),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }
    if (!_wikiTried) {
      return _buildSpinner();
    }
    return _buildFallback();
  }

  Widget _buildSpinner() {
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

  Widget _buildFallback() {
    return Container(
      color: const Color(0xFFEFFCF7),
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported_rounded,
        color: Color(0xFF0F766E),
        size: 40,
      ),
    );
  }
}
