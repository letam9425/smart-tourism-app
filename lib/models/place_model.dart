// lib/models/place_model.dart
class Place {
  final int id;                   // int, không phải String
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final double rating;
  final List<String> images;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.rating,
    required this.images,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: (json['id'] as num?)?.toInt() ?? 0,  // Chuyển num sang int an toàn
      name: json['name'] as String? ?? 'Unknown',
      description: json['description'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      address: json['address'] as String? ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    );
  }
}