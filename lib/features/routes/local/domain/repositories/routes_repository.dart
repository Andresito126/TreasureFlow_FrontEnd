import 'package:treasureflow/features/routes/local/domain/entities/route_generated_result.dart';
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
  Future<void> reschedulePickup({
    required String pickupId,
    required String newDate,
  });
}
