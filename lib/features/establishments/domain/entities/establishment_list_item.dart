class EstablishmentListItem {
  final String id;
  final String storeName;
  final String? photoUrl;
  final String? addressText;
  final double averageRating;
  final int reviewsCount;
  final List<String> materials;
  final bool isOpen;
  final String? distance;
  final bool isPremium;

  const EstablishmentListItem({
    required this.id,
    required this.storeName,
    this.photoUrl,
    this.addressText,
    required this.averageRating,
    required this.reviewsCount,
    required this.materials,
    required this.isOpen,
    this.distance,
    required this.isPremium,
  });
}

class EstablishmentListPage {
  final int total;
  final List<EstablishmentListItem> items;

  const EstablishmentListPage({required this.total, required this.items});
}
