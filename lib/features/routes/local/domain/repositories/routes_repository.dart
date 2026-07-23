import 'package:treasureflow/features/routes/local/domain/entities/active_tracking_info.dart';
import 'package:treasureflow/features/routes/local/domain/entities/confirmed_pickup.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_generated_result.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_summary.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/entities/weekly_planning_day.dart';

abstract class RoutesRepository {
  Future<List<WeeklyPlanningDay>> getWeeklyPlanning(String from);
  Future<RouteGeneratedResult> generateRoute({
    required String date,
    required double driverLat,
    required double driverLng,
  });
  Future<TodayRoute?> getRouteForDate(String date);
  Future<List<ConfirmedPickup>> getConfirmedPickupsForDay(String date);
  Future<void> reschedulePickup({
    required String pickupId,
    required String newDate,
  });
  Future<void> startRoute(String routeId);
  Future<void> completeStop({required String routeId, required String stopId});
  Future<void> postponeStop({
    required String routeId,
    required String stopId,
    required String newDate,
    String? reason,
  });
  Future<RouteSummary> getRouteSummary(String routeId);
  Future<ActiveTrackingInfo?> getActiveTrackingInfo();
  Future<void> sendHeartbeat({
    required String routeId,
    required double lat,
    required double lng,
  });
  Future<void> arriveStop({
    required String routeId,
    required String stopId,
    required double lat,
    required double lng,
  });
}
