import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/home/citizen/domain/entities/citizen_home.dart';
import 'package:treasureflow/features/home/citizen/domain/usecases/get_citizen_home_usecase.dart';

enum CitizenHomeStatus { idle, loading, success, error }

class CitizenHomeProvider extends ChangeNotifier {
  final GetCitizenHomeUseCase _getCitizenHomeUseCase;

  CitizenHomeStatus _status = CitizenHomeStatus.idle;
  CitizenHome? _data;
  String? _errorMessage;

  CitizenHomeStatus get status => _status;
  CitizenHome? get data => _data;
  String? get errorMessage => _errorMessage;

  CitizenHomeProvider(this._getCitizenHomeUseCase);

  Future<void> load() async {
    if (_status == CitizenHomeStatus.loading) return;
    _status = CitizenHomeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _getPosition();
      _data = await _getCitizenHomeUseCase(
        lat: position.latitude,
        lng: position.longitude,
      );
      _status = CitizenHomeStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = CitizenHomeStatus.error;
    } catch (_) {
      _errorMessage = 'Error al cargar el inicio';
      _status = CitizenHomeStatus.error;
    }

    notifyListeners();
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return _defaultPosition();

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return _defaultPosition();
    }

    return Geolocator.getCurrentPosition();
  }

  Position _defaultPosition() => Position(
    latitude: 19.432608,
    longitude: -99.133209,
    timestamp: DateTime.now(),
    accuracy: 0,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
}
