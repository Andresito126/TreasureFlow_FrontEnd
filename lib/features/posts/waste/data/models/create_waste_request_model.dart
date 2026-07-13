class CreateWasteRequestModel {
  final String description;
  final double latitude;
  final double longitude;
  final String addressText;
  final List<String> photoUrls;
  final String materialTypeId;
  final String deliveryMode;

  const CreateWasteRequestModel({
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.photoUrls,
    required this.materialTypeId,
    required this.deliveryMode,
  });

  Map<String, dynamic> toJson() => {
    'description': description,
    'latitude': latitude,
    'longitude': longitude,
    'addressText': addressText,
    'photoUrls': photoUrls,
    'materialTypeId': materialTypeId,
    'deliveryMode': deliveryMode,
  };
}
