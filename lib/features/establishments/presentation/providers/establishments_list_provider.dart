import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_list_item.dart';
import 'package:treasureflow/features/establishments/domain/usecases/list_establishments_usecase.dart';
import 'package:treasureflow/features/establishments/presentation/state/establishments_ui_state.dart';

export 'package:treasureflow/features/establishments/presentation/state/establishments_ui_state.dart'
    show EstablishmentsListStatus;

class EstablishmentsListProvider extends ChangeNotifier {
  final ListEstablishmentsUseCase _listEstablishmentsUseCase;

  static const _pageSize = 20;

  EstablishmentsListProvider(this._listEstablishmentsUseCase);

  EstablishmentsListStatus _status = EstablishmentsListStatus.idle;
  List<EstablishmentListItem> _items = [];
  int _total = 0;
  String? _errorMessage;
  bool _isLoadingMore = false;
  double? _lat;
  double? _lng;
  String? _materialTypeId;
  String _searchQuery = '';
  bool _nearbyOnly = false;
  Timer? _searchDebounce;

  EstablishmentsListStatus get status => _status;
  List<EstablishmentListItem> get items => List.unmodifiable(_items);
  String? get errorMessage => _errorMessage;
  bool get hasMore => _items.length < _total;
  bool get isLoadingMore => _isLoadingMore;
  String? get materialTypeId => _materialTypeId;
  String get searchQuery => _searchQuery;
  bool get nearbyOnly => _nearbyOnly;

  Future<void> load() async {
    if (_status == EstablishmentsListStatus.loading) return;
    _status = EstablishmentsListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final position = await _getPosition();
      _lat = position.latitude;
      _lng = position.longitude;

      final page = await _listEstablishmentsUseCase(
        limit: _pageSize,
        offset: 0,
        lat: _lat,
        lng: _lng,
        materialTypeId: _materialTypeId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        nearby: _nearbyOnly ? true : null,
      );
      _items = page.items;
      _total = page.total;
      _status = EstablishmentsListStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = EstablishmentsListStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = EstablishmentsListStatus.error;
    }

    notifyListeners();
  }

  Future<void> filterByMaterial(String? materialTypeId) async {
    if (_materialTypeId == materialTypeId) return;
    _materialTypeId = materialTypeId;
    _items = [];
    _total = 0;
    await load();
  }

  Future<void> setNearbyOnly(bool nearbyOnly) async {
    if (_nearbyOnly == nearbyOnly) return;
    _nearbyOnly = nearbyOnly;
    _items = [];
    _total = 0;
    await load();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      _items = [];
      _total = 0;
      load();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore ||
        !hasMore ||
        _status != EstablishmentsListStatus.success)
      return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _listEstablishmentsUseCase(
        limit: _pageSize,
        offset: _items.length,
        lat: _lat,
        lng: _lng,
        materialTypeId: _materialTypeId,
        search: _searchQuery.isEmpty ? null : _searchQuery,
        nearby: _nearbyOnly ? true : null,
      );
      _items = [..._items, ...page.items];
      _total = page.total;
    } catch (_) {}

    _isLoadingMore = false;
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
