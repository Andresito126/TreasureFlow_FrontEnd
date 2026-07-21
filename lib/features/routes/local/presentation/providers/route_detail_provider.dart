import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/policies/route_schedule_policy.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';
import 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart';

export 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart'
    show
        RouteDetailStatus,
        GenerateRouteStatus,
        RescheduleStatus,
        StopActionStatus;

class RouteDetailProvider extends ChangeNotifier {
  final RoutesRepository _repository;
  final RouteSchedulePolicy _schedulePolicy;

  RouteDetailProvider({
    required RoutesRepository repository,
    RouteSchedulePolicy schedulePolicy = const RouteSchedulePolicy(),
  }) : _repository = repository,
       _schedulePolicy = schedulePolicy;

  RouteDetailStatus _status = RouteDetailStatus.idle;
  String? _errorMessage;
  TodayRoute? _route;
  String? _date;

  GenerateRouteStatus _generateStatus = GenerateRouteStatus.idle;
  String? _generateError;

  RescheduleStatus _rescheduleStatus = RescheduleStatus.idle;
  String? _rescheduleError;

  StopActionStatus _stopActionStatus = StopActionStatus.idle;
  String? _stopActionError;

  RouteDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;
  TodayRoute? get route => _route;
  String? get date => _date;

  GenerateRouteStatus get generateStatus => _generateStatus;
  String? get generateError => _generateError;

  RescheduleStatus get rescheduleStatus => _rescheduleStatus;
  String? get rescheduleError => _rescheduleError;

  StopActionStatus get stopActionStatus => _stopActionStatus;
  String? get stopActionError => _stopActionError;

  bool get canGenerateRoute =>
      _date != null && _schedulePolicy.canGenerateRoute(_date!);

  bool get canStartRoute =>
      _date != null && _schedulePolicy.canStartRoute(_date!);

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
    if (!canGenerateRoute) {
      _generateError = 'Solo puedes generar esta ruta el día programado';
      _generateStatus = GenerateRouteStatus.error;
      notifyListeners();
      return false;
    }

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

  Future<bool> generateFromCurrentLocation() async {
    if (_date == null) return false;
    if (!canGenerateRoute) {
      _generateError = 'Solo puedes generar esta ruta el día programado';
      _generateStatus = GenerateRouteStatus.error;
      notifyListeners();
      return false;
    }

    _generateStatus = GenerateRouteStatus.resolvingLocation;
    _generateError = null;
    notifyListeners();

    final position = await _resolveGps();
    if (position == null) {
      _generateStatus = GenerateRouteStatus.error;
      notifyListeners();
      return false;
    }

    return generateRoute(
      driverLat: position.latitude,
      driverLng: position.longitude,
    );
  }

  Future<Position?> _resolveGps() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _generateError = 'Activa la ubicación de tu dispositivo';
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _generateError = 'Necesitamos permiso de ubicación';
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<bool> startRoute() async {
    final route = _route;
    if (route == null) return false;
    if (!canStartRoute) {
      _stopActionError = 'Solo puedes iniciar el recorrido el día programado';
      _stopActionStatus = StopActionStatus.error;
      notifyListeners();
      return false;
    }

    _stopActionStatus = StopActionStatus.working;
    _stopActionError = null;
    notifyListeners();

    try {
      await _repository.startRoute(route.routeId);
      _stopActionStatus = StopActionStatus.idle;
      notifyListeners();
      if (_date != null) await load(_date!);
      return true;
    } on ApiException catch (e) {
      _stopActionError = e.message;
      _stopActionStatus = StopActionStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _stopActionError = 'Ocurrió un error inesperado al iniciar el recorrido';
      _stopActionStatus = StopActionStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> completeStop(String stopId) async {
    final route = _route;
    if (route == null) return false;
    _stopActionStatus = StopActionStatus.working;
    _stopActionError = null;
    notifyListeners();

    try {
      await _repository.completeStop(routeId: route.routeId, stopId: stopId);
      _stopActionStatus = StopActionStatus.idle;
      notifyListeners();
      if (_date != null) await load(_date!);
      return true;
    } on ApiException catch (e) {
      _stopActionError = e.message;
      _stopActionStatus = StopActionStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _stopActionError = 'Ocurrió un error inesperado al completar la parada';
      _stopActionStatus = StopActionStatus.error;
      notifyListeners();
      return false;
    }
  }

  Future<bool> postponeStop(
    String stopId,
    String newDate,
    String? reason,
  ) async {
    final route = _route;
    if (route == null) return false;
    _stopActionStatus = StopActionStatus.working;
    _stopActionError = null;
    notifyListeners();

    try {
      await _repository.postponeStop(
        routeId: route.routeId,
        stopId: stopId,
        newDate: newDate,
        reason: reason,
      );
      _stopActionStatus = StopActionStatus.idle;
      notifyListeners();
      if (_date != null) await load(_date!);
      return true;
    } on ApiException catch (e) {
      _stopActionError = e.message;
      _stopActionStatus = StopActionStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _stopActionError = 'Ocurrió un error inesperado al posponer la parada';
      _stopActionStatus = StopActionStatus.error;
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
