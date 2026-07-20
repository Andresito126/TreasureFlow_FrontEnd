import 'package:treasureflow/features/routes/local/data/datasources/routes_remote_datasource.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_generated_result.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/entities/weekly_planning_day.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';

class RoutesRepositoryImpl implements RoutesRepository {
  final RoutesRemoteDatasource _datasource;

  const RoutesRepositoryImpl(this._datasource);

  @override
  Future<List<WeeklyPlanningDay>> getWeeklyPlanning(String from) =>
      _datasource.getWeeklyPlanning(from);

  @override
  Future<RouteGeneratedResult> generateRoute({
    required String date,
    required double driverLat,
    required double driverLng,
  }) =>
      _datasource.generateRoute(
        date: date,
        driverLat: driverLat,
        driverLng: driverLng,
      );

  @override
  Future<TodayRoute?> getRouteForDate(String date) =>
      _datasource.getRouteForDate(date);

  @override
  Future<void> reschedulePickup({
    required String pickupId,
    required String newDate,
  }) =>
      _datasource.reschedulePickup(pickupId: pickupId, newDate: newDate);
}
