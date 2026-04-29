/// A user-created geo photo memory on the map (stored on device).
class MapSpotMemory {
  MapSpotMemory({
    required this.id,
    required this.lat,
    required this.lng,
    required this.title,
    required this.description,
    required this.thoughts,
    required this.imagePaths,
    required this.createdAt,
  });

  final String id;
  final double lat;
  final double lng;
  final String title;

  /// Short context (e.g. “park bench near the fountain”).
  final String description;

  /// Personal note — vibe, photo tips, feelings.
  final String thoughts;

  /// Local filesystem paths under app documents (`spot_memories/...`).
  final List<String> imagePaths;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'id': id,
        'lat': lat,
        'lng': lng,
        'title': title,
        'description': description,
        'thoughts': thoughts,
        'imagePaths': imagePaths,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MapSpotMemory.fromJson(Map<String, dynamic> j) => MapSpotMemory(
        id: j['id'] as String,
        lat: (j['lat'] as num).toDouble(),
        lng: (j['lng'] as num).toDouble(),
        title: j['title'] as String? ?? '',
        description: j['description'] as String? ?? '',
        thoughts: j['thoughts'] as String? ?? '',
        imagePaths:
            (j['imagePaths'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
        createdAt: DateTime.tryParse(j['createdAt']?.toString() ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
      );
}
