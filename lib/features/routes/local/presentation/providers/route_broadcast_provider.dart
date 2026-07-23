import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';
import 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart';

export 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart'
    show BroadcastStatus;

class RouteBroadcastProvider extends ChangeNotifier {
  static const _heartbeatInterval = Duration(seconds: 15);

  final RoutesRepository _repository;

  RouteBroadcastProvider({required RoutesRepository repository})
    : _repository = repository;

  BroadcastStatus _status = BroadcastStatus.idle;
  double? _selfLat;
  double? _selfLng;
  bool _liveGps = true;
  String? _routeId;
  Timer? _heartbeatTimer;

  BroadcastStatus get status => _status;
  double? get selfLat => _selfLat;
  double? get selfLng => _selfLng;
  bool get hasSelfLocation => _selfLat != null && _selfLng != null;

  Future<void> startFromGps(String routeId) async {
    _routeId = routeId;
    _status = BroadcastStatus.resolvingLocation;
    notifyListeners();

    final position = await _resolveGps();
    if (position == null) {
      _status = BroadcastStatus.permissionDenied;
      notifyListeners();
      return;
    }

    _liveGps = true;
    await _begin(position.latitude, position.longitude);
  }

  Future<void> startFromFixedPoint(
    String routeId,
    double lat,
    double lng,
  ) async {
    _routeId = routeId;
    _liveGps = false;
    await _begin(lat, lng);
  }

  Future<void> retryGps() {
    final routeId = _routeId;
    if (routeId == null) return Future.value();
    return startFromGps(routeId);
  }

  Future<void> _begin(double lat, double lng) async {
    _selfLat = lat;
    _selfLng = lng;
    _status = BroadcastStatus.broadcasting;
    notifyListeners();

    await _sendHeartbeat();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    if (_liveGps) {
      try {
        final position = await Geolocator.getCurrentPosition();
        _selfLat = position.latitude;
        _selfLng = position.longitude;
        notifyListeners();
      } catch (_) {}
    }
    await _sendHeartbeat();
  }

  Future<void> _sendHeartbeat() async {
    final routeId = _routeId;
    if (routeId == null || !hasSelfLocation) return;

    try {
      await _repository.sendHeartbeat(
        routeId: routeId,
        lat: _selfLat!,
        lng: _selfLng!,
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        _heartbeatTimer?.cancel();
        _heartbeatTimer = null;
        _status = BroadcastStatus.routeClosed;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<Position?> _resolveGps() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  void stop() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
    _status = BroadcastStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _heartbeatTimer?.cancel();
    super.dispose();
  }
}
