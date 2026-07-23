import 'package:treasureflow/features/routes/local/domain/entities/route_status.dart';

class RouteSummary {
  final String routeId;
  final RouteExecutionStatus status;
  final int totalStops;
  final int completedStops;
  final int postponedStops;
  final int cancelledStops;
  final int totalDistanceMeters;

  const RouteSummary({
    required this.routeId,
    required this.status,
    required this.totalStops,
    required this.completedStops,
    required this.postponedStops,
    required this.cancelledStops,
    required this.totalDistanceMeters,
  });

  factory RouteSummary.fromJson(Map<String, dynamic> json) {
    return RouteSummary(
      routeId: json['routeId'] as String,
      status: RouteExecutionStatus.fromApi(json['status'] as String?),
      totalStops: (json['totalStops'] as num).toInt(),
      completedStops: (json['completedStops'] as num).toInt(),
      postponedStops: (json['postponedStops'] as num).toInt(),
      cancelledStops: (json['cancelledStops'] as num).toInt(),
      totalDistanceMeters: (json['totalDistanceMeters'] as num).toInt(),
    );
  }
}
