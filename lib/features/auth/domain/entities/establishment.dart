class Establishment {
  final String id;
  final String email;
  final String phone;
  final String storeName;
  final double latitude;
  final double longitude;
  final String? addressText;
  final bool hasVehicle;
  final List<String> materialTypeIds;
  final List<String> photoUrls;
  final String profilePictureUrl;

  const Establishment({
    required this.id,
    required this.email,
    required this.phone,
    required this.storeName,
    required this.latitude,
    required this.longitude,
    this.addressText,
    required this.hasVehicle,
    required this.materialTypeIds,
    required this.photoUrls,
    required this.profilePictureUrl,
  });
}
