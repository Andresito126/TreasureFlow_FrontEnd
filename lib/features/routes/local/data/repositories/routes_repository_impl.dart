import 'package:treasureflow/features/routes/local/data/datasources/routes_remote_datasource.dart';
import 'package:treasureflow/features/routes/local/domain/entities/active_tracking_info.dart';
import 'package:treasureflow/features/routes/local/domain/entities/confirmed_pickup.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_generated_result.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_summary.dart';
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
  }) => _datasource.generateRoute(
    date: date,
    driverLat: driverLat,
    driverLng: driverLng,
  );

  @override
  Future<TodayRoute?> getRouteForDate(String date) =>
      _datasource.getRouteForDate(date);

  @override
  Future<List<ConfirmedPickup>> getConfirmedPickupsForDay(String date) =>
      _datasource.getConfirmedPickupsForDay(date);

  @override
  Future<void> reschedulePickup({
    required String pickupId,
    required String newDate,
  }) => _datasource.reschedulePickup(pickupId: pickupId, newDate: newDate);

  @override
  Future<void> startRoute(String routeId) => _datasource.startRoute(routeId);

  @override
  Future<void> completeStop({
    required String routeId,
    required String stopId,
  }) => _datasource.completeStop(routeId: routeId, stopId: stopId);

  @override
  Future<void> postponeStop({
    required String routeId,
    required String stopId,
    required String newDate,
    String? reason,
  }) => _datasource.postponeStop(
    routeId: routeId,
    stopId: stopId,
    newDate: newDate,
    reason: reason,
  );

  @override
  Future<RouteSummary> getRouteSummary(String routeId) =>
      _datasource.getRouteSummary(routeId);

  @override
  Future<ActiveTrackingInfo?> getActiveTrackingInfo() =>
      _datasource.getActiveTrackingInfo();

  @override
  Future<void> sendHeartbeat({
    required String routeId,
    required double lat,
    required double lng,
  }) => _datasource.sendHeartbeat(routeId: routeId, lat: lat, lng: lng);

  @override
  Future<void> arriveStop({
    required String routeId,
    required String stopId,
    required double lat,
    required double lng,
  }) => _datasource.arriveStop(
    routeId: routeId,
    stopId: stopId,
    lat: lat,
    lng: lng,
  );
}
