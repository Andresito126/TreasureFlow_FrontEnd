class ConfirmedPickup {
  final String scheduledPickupId;
  final String citizenId;
  final String citizenName;
  final String? citizenPhone;
  final double latitude;
  final double longitude;
  final String? addressText;

  const ConfirmedPickup({
    required this.scheduledPickupId,
    required this.citizenId,
    required this.citizenName,
    required this.latitude,
    required this.longitude,
    this.citizenPhone,
    this.addressText,
  });

  factory ConfirmedPickup.fromJson(Map<String, dynamic> json) {
    return ConfirmedPickup(
      scheduledPickupId: json['scheduledPickupId'] as String,
      citizenId: json['citizenId'] as String,
      citizenName: json['citizenName'] as String,
      citizenPhone: json['citizenPhone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressText: json['addressText'] as String?,
    );
  }
}
