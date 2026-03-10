class Place {
  final int id;
  final String name;
  final String description;
  final double latitude;
  final double longitude;
  final String address;
  final double rating;
  final List<String> images;
  final String? category;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.rating,
    required this.images,
    this.category,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      address: json['address'] ?? '',
      rating: json['rating']?.toDouble() ?? 0.0,
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] as String?,
    );
  }
}