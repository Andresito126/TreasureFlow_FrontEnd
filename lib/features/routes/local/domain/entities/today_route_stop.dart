import 'package:treasureflow/features/routes/local/domain/entities/route_status.dart';

class TodayRouteStop {
  final String stopId;
  final String scheduledPickupId;
  final int stopOrder;
  final StopStatus status;
  final DateTime? estimatedArrival;
  final int distanceFromPrevMeters;
  final int durationFromPrevSeconds;
  final String citizenId;
  final String citizenName;
  final String? citizenPhone;
  final double latitude;
  final double longitude;
  final String? addressText;

  const TodayRouteStop({
    required this.stopId,
    required this.scheduledPickupId,
    required this.stopOrder,
    required this.status,
    required this.distanceFromPrevMeters,
    required this.durationFromPrevSeconds,
    required this.citizenId,
    required this.citizenName,
    required this.latitude,
    required this.longitude,
    this.estimatedArrival,
    this.citizenPhone,
    this.addressText,
  });

  factory TodayRouteStop.fromJson(Map<String, dynamic> json) {
    return TodayRouteStop(
      stopId: json['stopId'] as String,
      scheduledPickupId: json['scheduledPickupId'] as String,
      stopOrder: (json['stopOrder'] as num).toInt(),
      status: StopStatus.fromApi(json['status'] as String?),
      estimatedArrival: json['estimatedArrival'] != null
          ? DateTime.tryParse(json['estimatedArrival'].toString())
          : null,
      distanceFromPrevMeters: (json['distanceFromPrevMeters'] as num).toInt(),
      durationFromPrevSeconds: (json['durationFromPrevSeconds'] as num).toInt(),
      citizenId: json['citizenId'] as String,
      citizenName: json['citizenName'] as String,
      citizenPhone: json['citizenPhone'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      addressText: json['addressText'] as String?,
    );
  }
}
