import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_generated_result.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_summary.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/entities/weekly_planning_day.dart';

class RoutesRemoteDatasource {
  final ApiClient _apiClient;

  const RoutesRemoteDatasource(this._apiClient);

  Future<List<WeeklyPlanningDay>> getWeeklyPlanning(String from) async {
    final data = await _apiClient.getList('/routes/planning?from=$from');
    return data
        .whereType<Map<String, dynamic>>()
        .map(WeeklyPlanningDay.fromJson)
        .toList();
  }

  Future<RouteGeneratedResult> generateRoute({
    required String date,
    required double driverLat,
    required double driverLng,
  }) async {
    final data = await _apiClient.post(
      '/routes/generate',
      body: {'date': date, 'driverLat': driverLat, 'driverLng': driverLng},
    );
    return RouteGeneratedResult.fromJson(data);
  }

  Future<TodayRoute?> getRouteForDate(String date) async {
    final data = await _apiClient.getNullable('/routes/today?date=$date');
    return data != null ? TodayRoute.fromJson(data) : null;
  }

  Future<void> reschedulePickup({
    required String pickupId,
    required String newDate,
  }) async {
    await _apiClient.patch(
      '/routes/pickups/$pickupId/reschedule',
      body: {'newDate': newDate},
    );
  }

  Future<void> startRoute(String routeId) async {
    await _apiClient.patch('/routes/$routeId/start');
  }

  Future<void> completeStop({
    required String routeId,
    required String stopId,
  }) async {
    await _apiClient.patch('/routes/$routeId/stops/$stopId/complete');
  }

  Future<void> postponeStop({
    required String routeId,
    required String stopId,
    required String newDate,
    String? reason,
  }) async {
    await _apiClient.patch(
      '/routes/$routeId/stops/$stopId/postpone',
      body: {
        'newDate': newDate,
        if (reason != null && reason.isNotEmpty) 'reason': reason,
      },
    );
  }

  Future<RouteSummary> getRouteSummary(String routeId) async {
    final data = await _apiClient.get('/routes/$routeId/summary');
    return RouteSummary.fromJson(data);
  }

  Future<String?> getActiveTrackingRouteId() async {
    final data = await _apiClient.get('/routes/tracking/active');
    return data['routeId'] as String?;
  }
}
