// API response models for the Kurdistan Go backend.

class ApiPlaceImage {
  final int id;
  final String url;
  final String? r2Key;
  final bool isCover;
  final int sortOrder;

  ApiPlaceImage({
    required this.id,
    required this.url,
    this.r2Key,
    this.isCover = false,
    this.sortOrder = 0,
  });

  factory ApiPlaceImage.fromJson(Map<String, dynamic> json) {
    return ApiPlaceImage(
      id: json['id'] as int,
      url: json['url'] as String,
      r2Key: json['r2_key'] as String?,
      isCover: json['is_cover'] as bool? ?? false,
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }
}

class ApiPlace {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? category;
  final double? rating;
  final double? latitude;
  final double? longitude;
  final bool isPremium;
  final int cityId;
  final List<ApiPlaceImage> images;

  ApiPlace({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    this.rating,
    this.latitude,
    this.longitude,
    this.isPremium = false,
    required this.cityId,
    this.images = const [],
  });

  factory ApiPlace.fromJson(Map<String, dynamic> json) {
    return ApiPlace(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      category: json['category'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      isPremium: json['is_premium'] as bool? ?? false,
      cityId: json['city_id'] as int,
      images: (json['images'] as List? ?? [])
          .map((e) => ApiPlaceImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Best available cover image URL (or null if no images uploaded yet).
  String? get coverUrl {
    if (images.isNotEmpty) {
      final cover = images.firstWhere(
        (i) => i.isCover,
        orElse: () => images.first,
      );
      return cover.url;
    }
    return imageUrl;
  }
}

class ApiCity {
  final int id;
  final String name;
  final String? description;
  final String? imageUrl;
  final double? latitude;
  final double? longitude;
  final List<ApiPlaceImage> images;

  ApiCity({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.latitude,
    this.longitude,
    this.images = const [],
  });

  factory ApiCity.fromJson(Map<String, dynamic> json) {
    return ApiCity(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      images: (json['images'] as List? ?? [])
          .map((e) => ApiPlaceImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  String? get coverUrl {
    if (images.isNotEmpty) {
      final cover = images.firstWhere(
        (i) => i.isCover,
        orElse: () => images.first,
      );
      return cover.url;
    }
    return imageUrl;
  }
}

class ApiEvent {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? eventType;
  final String? location;
  final String? startDate;
  final String? endDate;

  ApiEvent({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.eventType,
    this.location,
    this.startDate,
    this.endDate,
  });

  factory ApiEvent.fromJson(Map<String, dynamic> json) {
    return ApiEvent(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      eventType: json['event_type'] as String?,
      location: json['location'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
    );
  }
}
