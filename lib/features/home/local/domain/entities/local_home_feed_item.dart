class LocalHomeFeedItem {
  final String id;
  final String? description;
  final String? mainPhotoUrl;
  final String citizenId;
  final String citizenName;
  final String citizenProfilePictureUrl;
  final String publishedAt;
  final bool isFeatured;
  final int? zoneId;
  final String materialTypeId;
  final String materialTypeName;
  final int distanceMeters;
  final double latitude;
  final double longitude;

  const LocalHomeFeedItem({
    required this.id,
    this.description,
    this.mainPhotoUrl,
    required this.citizenId,
    required this.citizenName,
    required this.citizenProfilePictureUrl,
    required this.publishedAt,
    required this.isFeatured,
    this.zoneId,
    required this.materialTypeId,
    required this.materialTypeName,
    required this.distanceMeters,
    required this.latitude,
    required this.longitude,
  });
}

class LocalHomeFeedPage {
  final int total;
  final List<LocalHomeFeedItem> results;

  const LocalHomeFeedPage({required this.total, required this.results});
}
