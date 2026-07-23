class EstablishmentListItem {
  final String id;
  final String storeName;
  final String? photoUrl;
  final String? addressText;
  final double averageRating;
  final List<String> materials;
  final bool isOpen;
  final String? distance;

  const EstablishmentListItem({
    required this.id,
    required this.storeName,
    this.photoUrl,
    this.addressText,
    required this.averageRating,
    required this.materials,
    required this.isOpen,
    this.distance,
  });
}

class EstablishmentListPage {
  final int total;
  final List<EstablishmentListItem> items;

  const EstablishmentListPage({required this.total, required this.items});
}
