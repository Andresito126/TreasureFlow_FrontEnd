import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

enum CitizenDetailStatus { idle, loading, success, error }

enum CitizenActionStatus { idle, working, done, error }

class CitizenCollectionDetailProvider extends ChangeNotifier {
  final CitizenCollectionsRepository _repository;

  CitizenCollectionDetailProvider({
    required CitizenCollectionsRepository repository,
  }) : _repository = repository;

  CitizenDetailStatus _status = CitizenDetailStatus.idle;
  String? _errorMessage;
  CollectionDetail? _detail;

  CitizenActionStatus _actionStatus = CitizenActionStatus.idle;
  String? _actionError;

  Timer? _passiveRefreshTimer;
  String? _collectionId;
  bool _disposed = false;

  CitizenDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;
  CollectionDetail? get detail => _detail;
  CitizenActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;

  Future<void> load(String collectionId) async {
    _collectionId = collectionId;
    _status = CitizenDetailStatus.loading;
    _errorMessage = null;
    _safeNotify();

    try {
      _detail = await _repository.getCollectionDetail(collectionId);
      _status = CitizenDetailStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = CitizenDetailStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = CitizenDetailStatus.error;
    }

    _safeNotify();
  }

  Future<void> silentReload() async {
    final id = _collectionId;
    if (id == null) return;
    try {
      _detail = await _repository.getCollectionDetail(id);
      _safeNotify();
    } catch (_) {
      // no altera el estado visible si falla
    }
  }

  Future<bool> confirmAmount() =>
      _runAction(() => _repository.confirmAmount(_collectionId!));

  Future<bool> cancelCollection() =>
      _runAction(() => _repository.cancelCollection(_collectionId!));

  Future<bool> _runAction(Future<void> Function() action) async {
    if (_collectionId == null) return false;
    _actionStatus = CitizenActionStatus.working;
    _actionError = null;
    _safeNotify();

    try {
      await action();
      _actionStatus = CitizenActionStatus.done;
      await silentReload();
      _safeNotify();
      return true;
    } on ApiException catch (e) {
      _actionError = e.message;
      _actionStatus = CitizenActionStatus.error;
      _safeNotify();
      return false;
    } catch (_) {
      _actionError = 'Ocurrió un error inesperado';
      _actionStatus = CitizenActionStatus.error;
      _safeNotify();
      return false;
    }
  }

  /// Recarga el detalle periódicamente — para las pantallas de espera
  /// (esperando pesaje / esperando pago del establecimiento).
  void startPassiveRefresh({int seconds = 5}) {
    if (_passiveRefreshTimer != null) return;
    _passiveRefreshTimer = Timer.periodic(
      Duration(seconds: seconds),
      (_) => silentReload(),
    );
  }

  void stopPassiveRefresh() {
    _passiveRefreshTimer?.cancel();
    _passiveRefreshTimer = null;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stopPassiveRefresh();
    super.dispose();
  }
}
