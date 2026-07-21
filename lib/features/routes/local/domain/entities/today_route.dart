import 'package:treasureflow/features/routes/local/domain/entities/route_status.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route_stop.dart';

class TodayRoute {
  final String routeId;
  final String routeDate;
  final RouteExecutionStatus status;
  final int totalDistanceMeters;

  final bool driverInactive;
  final double? lastLat;
  final double? lastLng;
  final List<TodayRouteStop> stops;

  const TodayRoute({
    required this.routeId,
    required this.routeDate,
    required this.status,
    required this.totalDistanceMeters,
    required this.driverInactive,
    required this.stops,
    this.lastLat,
    this.lastLng,
  });

  factory TodayRoute.fromJson(Map<String, dynamic> json) {
    return TodayRoute(
      routeId: json['routeId'] as String,
      routeDate: json['routeDate'] as String,
      status: RouteExecutionStatus.fromApi(json['status'] as String?),
      totalDistanceMeters: (json['totalDistanceMeters'] as num).toInt(),
      driverInactive: json['driverInactive'] as bool? ?? false,
      lastLat: (json['lastLat'] as num?)?.toDouble(),
      lastLng: (json['lastLng'] as num?)?.toDouble(),
      stops: (json['stops'] as List<dynamic>)
          .whereType<Map<String, dynamic>>()
          .map(TodayRouteStop.fromJson)
          .toList(),
    );
  }
}
