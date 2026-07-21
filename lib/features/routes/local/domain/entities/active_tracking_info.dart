class ActiveTrackingInfo {
  final String routeId;
  final bool driverInactive;
  final double? lastLat;
  final double? lastLng;

  const ActiveTrackingInfo({
    required this.routeId,
    required this.driverInactive,
    this.lastLat,
    this.lastLng,
  });

  static ActiveTrackingInfo? fromJson(Map<String, dynamic> json) {
    final routeId = json['routeId'] as String?;
    if (routeId == null) return null;
    return ActiveTrackingInfo(
      routeId: routeId,
      driverInactive: json['driverInactive'] as bool? ?? false,
      lastLat: (json['lastLat'] as num?)?.toDouble(),
      lastLng: (json['lastLng'] as num?)?.toDouble(),
    );
  }
}
