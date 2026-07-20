import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

enum LocalDetailStatus { idle, loading, success, error }

enum LocalActionStatus { idle, working, done, error }

enum PaymentPollingStatus {
  idle,
  polling,
  succeeded,
  failedOrExpired,
  timedOut,
}

class LocalCollectionDetailProvider extends ChangeNotifier {
  final LocalCollectionsRepository _repository;

  LocalCollectionDetailProvider({
    required LocalCollectionsRepository repository,
  }) : _repository = repository;

  LocalDetailStatus _status = LocalDetailStatus.idle;
  String? _errorMessage;
  CollectionDetail? _detail;

  LocalActionStatus _actionStatus = LocalActionStatus.idle;
  String? _actionError;

  CreatePaymentResult? _paymentResult;
  PaymentPollingStatus _pollingStatus = PaymentPollingStatus.idle;
  Timer? _pollingTimer;
  int _pollingAttempts = 0;
  static const _maxPollingAttempts = 90;

  Timer? _passiveRefreshTimer;

  String? _collectionId;
  bool _disposed = false;

  LocalDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;
  CollectionDetail? get detail => _detail;
  LocalActionStatus get actionStatus => _actionStatus;
  String? get actionError => _actionError;
  CreatePaymentResult? get paymentResult => _paymentResult;
  PaymentPollingStatus get pollingStatus => _pollingStatus;

  Future<void> load(String collectionId) async {
    _collectionId = collectionId;
    _status = LocalDetailStatus.loading;
    _errorMessage = null;
    _safeNotify();

    try {
      _detail = await _repository.getCollectionDetail(collectionId);
      _status = LocalDetailStatus.success;
      _resumePendingPaymentPollingIfNeeded();
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = LocalDetailStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = LocalDetailStatus.error;
    }

    _safeNotify();
  }

  Future<void> silentReload() async {
    final id = _collectionId;
    if (id == null) return;
    try {
      _detail = await _repository.getCollectionDetail(id);
      _safeNotify();
    } catch (_) {}
  }

  Future<bool> registerWeighing(double actualQuantity) => _runAction(
    () => _repository.registerWeighing(_collectionId!, actualQuantity),
  );

  Future<bool> cancelCollection() =>
      _runAction(() => _repository.cancelCollection(_collectionId!));

  Future<bool> _runAction(Future<void> Function() action) async {
    if (_collectionId == null) return false;
    _actionStatus = LocalActionStatus.working;
    _actionError = null;
    _safeNotify();

    try {
      await action();
      _actionStatus = LocalActionStatus.done;
      await silentReload();
      _safeNotify();
      return true;
    } on ApiException catch (e) {
      _actionError = e.message;
      _actionStatus = LocalActionStatus.error;
      _safeNotify();
      return false;
    } catch (_) {
      _actionError = 'Ocurrió un error inesperado';
      _actionStatus = LocalActionStatus.error;
      _safeNotify();
      return false;
    }
  }

  Future<bool> payWithCard({required String tokenId}) async {
    if (_collectionId == null) return false;
    _actionStatus = LocalActionStatus.working;
    _actionError = null;
    _safeNotify();

    try {
      _paymentResult = await _repository.createPayment(
        _collectionId!,
        method: PaymentMethodType.card,
        tokenId: tokenId,
      );

      _actionStatus = LocalActionStatus.done;
      await silentReload();
      _safeNotify();
      return true;
    } on ApiException catch (e) {
      _actionError = e.message;
      _actionStatus = LocalActionStatus.error;
      await silentReload();
      _safeNotify();
      return false;
    } catch (_) {
      _actionError = 'Ocurrió un error inesperado al procesar el pago';
      _actionStatus = LocalActionStatus.error;
      _safeNotify();
      return false;
    }
  }

  Future<bool> payWithVoucher(PaymentMethodType method) async {
    if (_collectionId == null) return false;
    _actionStatus = LocalActionStatus.working;
    _actionError = null;
    _safeNotify();

    try {
      _paymentResult = await _repository.createPayment(
        _collectionId!,
        method: method,
      );
      _actionStatus = LocalActionStatus.done;
      _startPolling();
      _safeNotify();
      return true;
    } on ApiException catch (e) {
      _actionError = e.message;
      _actionStatus = LocalActionStatus.error;
      _safeNotify();
      return false;
    } catch (_) {
      _actionError = 'Ocurrió un error inesperado al generar el pago';
      _actionStatus = LocalActionStatus.error;
      _safeNotify();
      return false;
    }
  }

  void resetPaymentFlow() {
    _stopPolling();
    _paymentResult = null;
    _pollingStatus = PaymentPollingStatus.idle;
    _actionStatus = LocalActionStatus.idle;
    _actionError = null;
    _safeNotify();
  }

  void _resumePendingPaymentPollingIfNeeded() {
    final payment = _detail?.payment;
    if (payment != null &&
        payment.status == PaymentStatusType.pending &&
        payment.method != PaymentMethodType.card &&
        _pollingStatus != PaymentPollingStatus.polling) {
      _startPolling();
    }
  }

  void _startPolling() {
    _stopPolling();
    _pollingAttempts = 0;
    _pollingStatus = PaymentPollingStatus.polling;
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _poll());
  }

  Future<void> _poll() async {
    final id = _collectionId;
    if (id == null) return;

    _pollingAttempts++;
    if (_pollingAttempts > _maxPollingAttempts) {
      _stopPolling();
      _pollingStatus = PaymentPollingStatus.timedOut;
      _safeNotify();
      return;
    }

    try {
      final result = await _repository.checkPaymentStatus(id);

      if (result.collectionStatus == CollectionStatus.completed) {
        _stopPolling();
        _pollingStatus = PaymentPollingStatus.succeeded;
        await silentReload();
        _safeNotify();
      } else if (result.gatewayStatus == 'expired' ||
          result.gatewayStatus == 'declined') {
        _stopPolling();
        _pollingStatus = PaymentPollingStatus.failedOrExpired;
        await silentReload();
        _safeNotify();
      }
    } catch (_) {}
  }

  Future<void> checkPaymentNow() async {
    final id = _collectionId;
    if (id == null) return;
    try {
      final result = await _repository.checkPaymentStatus(id);
      if (result.collectionStatus == CollectionStatus.completed) {
        _pollingStatus = PaymentPollingStatus.succeeded;
        await silentReload();
      }
      _safeNotify();
    } catch (_) {}
  }

  void pausePolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

  void resumePolling() {
    if (_pollingStatus == PaymentPollingStatus.polling &&
        _pollingTimer == null) {
      _pollingTimer = Timer.periodic(
        const Duration(seconds: 4),
        (_) => _poll(),
      );
    }
  }

  void _stopPolling() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
  }

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
    _stopPolling();
    stopPassiveRefresh();
    super.dispose();
  }
}
