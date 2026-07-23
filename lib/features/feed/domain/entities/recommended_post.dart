class RecommendedPost {
  final String id;
  final String description;
  final String? mainPhotoUrl;
  final String publishedAt;
  final bool isFeatured;
  final int zoneId;
  final String materialTypeId;
  final String materialTypeName;
  final double distanceMeters;
  final double latitude;
  final double longitude;

  const RecommendedPost({
    required this.id,
    required this.description,
    this.mainPhotoUrl,
    required this.publishedAt,
    required this.isFeatured,
    required this.zoneId,
    required this.materialTypeId,
    required this.materialTypeName,
    required this.distanceMeters,
    required this.latitude,
    required this.longitude,
  });
}

class PaginatedRecommendedPosts {
  final int total;
  final List<RecommendedPost> items;

  const PaginatedRecommendedPosts({
    required this.total,
    required this.items,
  });
}
