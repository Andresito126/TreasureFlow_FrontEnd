import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:treasureflow/core/network/tracking_socket_client_factory.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/state/tracking_ui_state.dart';

export 'package:treasureflow/features/tracking/citizen/presentation/state/tracking_ui_state.dart'
    show TrackingConnStatus;

class CitizenTrackingProvider extends ChangeNotifier {
  static const _pollInterval = Duration(seconds: 60);

  final TrackingSocketClientFactory _socketFactory;
  final RoutesRepository _repository;

  CitizenTrackingProvider({
    required TrackingSocketClientFactory socketFactory,
    required RoutesRepository repository,
  }) : _socketFactory = socketFactory,
       _repository = repository;

  io.Socket? _socket;
  String? _routeId;
  Timer? _pollTimer;

  TrackingConnStatus _status = TrackingConnStatus.idle;
  String? _errorMessage;

  double? _truckLat;
  double? _truckLng;
  double? _selfLat;
  double? _selfLng;
  bool _driverInactive = false;

  TrackingConnStatus get status => _status;
  String? get errorMessage => _errorMessage;
  double? get truckLat => _truckLat;
  double? get truckLng => _truckLng;
  double? get selfLat => _selfLat;
  double? get selfLng => _selfLng;
  bool get hasTruck => _truckLat != null && _truckLng != null;
  bool get hasSelf => _selfLat != null && _selfLng != null;
  bool get driverInactive => _driverInactive;

  Future<void> connect(String routeId) async {
    _routeId = routeId;
    _status = TrackingConnStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    await _resolveSelfLocation();

    await _refreshSnapshot();

    final socket = await _socketFactory.create();
    _socket = socket;

    socket.onConnect((_) {
      _status = TrackingConnStatus.connected;

      socket.emit('citizen:watch', {'routeId': _routeId});
      notifyListeners();
    });

    socket.on('location:update', (data) {
      if (data is Map) {
        final lat = data['lat'];
        final lng = data['lng'];
        if (lat is num && lng is num) {
          _truckLat = lat.toDouble();
          _truckLng = lng.toDouble();

          _driverInactive = false;
          notifyListeners();
        }
      }
    });

    socket.on('tracking:error', (data) {
      _status = TrackingConnStatus.error;
      _errorMessage = data is Map && data['message'] is String
          ? data['message'] as String
          : 'No se pudo seguir la ruta';
      notifyListeners();
    });

    socket.onDisconnect((_) {
      _status = TrackingConnStatus.disconnected;
      notifyListeners();
    });

    socket.connect();

    _pollTimer = Timer.periodic(_pollInterval, (_) => _refreshSnapshot());
  }

  Future<void> _refreshSnapshot() async {
    try {
      final info = await _repository.getActiveTrackingInfo();
      if (info == null || info.routeId != _routeId) return;

      _driverInactive = info.driverInactive;

      if (!hasTruck && info.lastLat != null && info.lastLng != null) {
        _truckLat = info.lastLat;
        _truckLng = info.lastLng;
      }
      notifyListeners();
    } catch (_) {}
  }

  Future<void> _resolveSelfLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      _selfLat = position.latitude;
      _selfLng = position.longitude;
      notifyListeners();
    } catch (_) {}
  }

  void disconnectSocket() {
    _pollTimer?.cancel();
    _pollTimer = null;
    _socket?.dispose();
    _socket = null;
  }

  @override
  void dispose() {
    disconnectSocket();
    super.dispose();
  }
}
