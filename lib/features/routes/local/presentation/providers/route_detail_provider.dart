import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';

enum RouteDetailStatus { idle, loading, success, error }

enum GenerateRouteStatus { idle, generating, error }

enum RescheduleStatus { idle, working, error }

class RouteDetailProvider extends ChangeNotifier {
  final RoutesRepository _repository;

  RouteDetailProvider({required RoutesRepository repository})
      : _repository = repository;

  RouteDetailStatus _status = RouteDetailStatus.idle;
  String? _errorMessage;
  TodayRoute? _route;
  String? _date;

  GenerateRouteStatus _generateStatus = GenerateRouteStatus.idle;
  String? _generateError;

  RescheduleStatus _rescheduleStatus = RescheduleStatus.idle;
  String? _rescheduleError;

  RouteDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;
  TodayRoute? get route => _route;

  GenerateRouteStatus get generateStatus => _generateStatus;
  String? get generateError => _generateError;

  RescheduleStatus get rescheduleStatus => _rescheduleStatus;
  String? get rescheduleError => _rescheduleError;

  Future<void> load(String date) async {
    _date = date;
    _status = RouteDetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _route = await _repository.getRouteForDate(date);
      _status = RouteDetailStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = RouteDetailStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = RouteDetailStatus.error;
    }

    notifyListeners();
  }

  Future<bool> generateRoute({
    required double driverLat,
    required double driverLng,
  }) async {
    if (_date == null) return false;
    _generateStatus = GenerateRouteStatus.generating;
    _generateError = null;
    notifyListeners();

    try {
      await _repository.generateRoute(
        date: _date!,
        driverLat: driverLat,
        driverLng: driverLng,
      );
      _generateStatus = GenerateRouteStatus.idle;
      notifyListeners();
      await load(_date!);
      return true;
    } on ApiException catch (e) {
      _generateError = e.message;
      _generateStatus = GenerateRouteStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _generateError = 'Ocurrió un error inesperado al generar la ruta';
      _generateStatus = GenerateRouteStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> reschedulePickup({
    required String pickupId,
    required String newDate,
  }) async {
    _rescheduleStatus = RescheduleStatus.working;
    _rescheduleError = null;
    notifyListeners();

    try {
      await _repository.reschedulePickup(pickupId: pickupId, newDate: newDate);
      _rescheduleStatus = RescheduleStatus.idle;
      notifyListeners();
      if (_date != null) await load(_date!);
      return true;
    } on ApiException catch (e) {
      _rescheduleError = e.message;
      _rescheduleStatus = RescheduleStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _rescheduleError = 'Ocurrió un error inesperado al reagendar';
      _rescheduleStatus = RescheduleStatus.error;
      notifyListeners();
      return false;
    }
  }
}
