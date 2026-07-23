import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/core/maps/domain/entities/suggestion.dart';
import 'package:treasureflow/core/maps/domain/usecases/get_current_location_usecase.dart';
import 'package:treasureflow/core/maps/domain/usecases/reverse_geocode_usecase.dart';
import 'package:treasureflow/core/maps/domain/usecases/search_places_usecase.dart';
import 'package:uuid/uuid.dart';

enum MapStatus { idle, loadingLocation, located, loadingAddress, error }

class MapProvider extends ChangeNotifier {
  final GetCurrentLocationUseCase _getCurrentLocation;
  final ReverseGeocodeUseCase _reverseGeocode;
  final SearchPlacesUseCase _searchPlaces;

  MapProvider({
    required GetCurrentLocationUseCase getCurrentLocation,
    required ReverseGeocodeUseCase reverseGeocode,
    required SearchPlacesUseCase searchPlaces,
  })  : _getCurrentLocation = getCurrentLocation,
        _reverseGeocode = reverseGeocode,
        _searchPlaces = searchPlaces;

  // ── Estado ──────────────────────────────────────────────────────────────
  MapStatus _status = MapStatus.idle;
  Place? _currentPlace;
  List<Suggestion> _suggestions = [];
  String? _error;
  bool _isEditing = false;
  LatLng? _pinLocation;
  Timer? _idleDebounce;

  // ── Session token: se renueva cada vez que el usuario elige un resultado ─
  String _sessionToken = const Uuid().v4();

  // ── Getters ─────────────────────────────────────────────────────────────
  MapStatus get status => _status;
  Place? get currentPlace => _currentPlace;
  List<Suggestion> get suggestions => _suggestions;
  String? get error => _error;
  bool get isEditing => _isEditing;
  LatLng? get pinLocation => _pinLocation;

  bool get isLoadingLocation => _status == MapStatus.loadingLocation;
  bool get isLoadingAddress => _status == MapStatus.loadingAddress;

  LatLng get initialTarget =>
      _pinLocation ?? const LatLng(16.7625, -93.375); // Tuxtla por defecto

  // ── Inicialización ──────────────────────────────────────────────────────
  Future<void> initializeLocation() async {
    _status = MapStatus.loadingLocation;
    _error = null;
    notifyListeners();

    try {
      _currentPlace = await _getCurrentLocation.execute();
      _pinLocation = LatLng(
        _currentPlace!.latitude,
        _currentPlace!.longitude,
      );
      _status = MapStatus.located;
    } catch (e) {
      _error = e.toString();
      _status = MapStatus.error;
    }
    notifyListeners();
  }

  // ── El pin se mueve con la cámara: actualizamos la posición ─────────────
  void onCameraMove(LatLng position) {
    _pinLocation = position;
    // No notificamos aquí para no re-renderizar en cada frame del gesto
  }

  // ── onCameraIdle: debounce de 800 ms antes de hacer reverse geocoding ───
  void onCameraIdle() {
    if (_pinLocation == null) return;
    _idleDebounce?.cancel();
    _idleDebounce = Timer(const Duration(milliseconds: 800), () {
      _doReverseGeocode(_pinLocation!);
    });
  }

  Future<void> _doReverseGeocode(LatLng latLng) async {
    _status = MapStatus.loadingAddress;
    notifyListeners();
    try {
      _currentPlace = await _reverseGeocode.execute(
        latLng.latitude,
        latLng.longitude,
      );
      _status = MapStatus.located;
    } catch (e) {
      _error = e.toString();
      _status = MapStatus.error;
    }
    notifyListeners();
  }

  // ── Autocompletado ───────────────────────────────────────────────────────
  Future<List<Suggestion>> fetchSuggestions(String input, String lang) =>
      _searchPlaces.fetchSuggestions(input, _sessionToken);

  // ── El usuario elige un resultado del buscador ──────────────────────────
  Future<Place> selectSuggestion(String placeId) async {
    final result = await _searchPlaces.getPlaceDetail(placeId, _sessionToken);
    _currentPlace = result;
    _pinLocation = LatLng(result.latitude, result.longitude);
    _suggestions = [];
    // Renovar session token: la sesión de facturación terminó
    _sessionToken = const Uuid().v4();
    _status = MapStatus.located;
    notifyListeners();
    return result;
  }

  // ── Modo edición ─────────────────────────────────────────────────────────
  void enterEditMode() {
    _isEditing = true;
    notifyListeners();
  }

  void exitEditMode() {
    _isEditing = false;
    notifyListeners();
  }

  // ── Centrar en ubicación actual ──────────────────────────────────────────
  Future<void> goToCurrentLocation() async {
    _status = MapStatus.loadingLocation;
    notifyListeners();
    try {
      _currentPlace = await _getCurrentLocation.execute();
      _pinLocation = LatLng(
        _currentPlace!.latitude,
        _currentPlace!.longitude,
      );
      _status = MapStatus.located;
    } catch (e) {
      _error = e.toString();
      _status = MapStatus.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _idleDebounce?.cancel();
    super.dispose();
  }
}