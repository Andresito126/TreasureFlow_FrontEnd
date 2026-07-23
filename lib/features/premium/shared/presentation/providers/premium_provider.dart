import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collection_detail_provider.dart'
    show PaymentPollingStatus;
import 'package:treasureflow/features/premium/shared/domain/entities/premium_status.dart';
import 'package:treasureflow/features/premium/shared/domain/usecases/get_premium_status_usecase.dart';
import 'package:treasureflow/features/premium/shared/domain/usecases/pay_premium_usecase.dart';

export 'package:treasureflow/features/collections/local/presentation/providers/local_collection_detail_provider.dart'
    show PaymentPollingStatus;

enum PremiumLoadStatus { idle, loading, success, error }

class PremiumProvider extends ChangeNotifier {
  final GetPremiumStatusUseCase _getPremiumStatusUseCase;
  final PayPremiumUseCase _payPremiumUseCase;

  static const _pollIntervalSeconds = 4;
  static const _maxPollingAttempts = 90;

  PremiumProvider({
    required GetPremiumStatusUseCase getPremiumStatusUseCase,
    required PayPremiumUseCase payPremiumUseCase,
  })  : _getPremiumStatusUseCase = getPremiumStatusUseCase,
        _payPremiumUseCase = payPremiumUseCase;

  PremiumLoadStatus _status = PremiumLoadStatus.idle;
  PremiumStatus? _premiumStatus;
  CreatePaymentResult? _paymentResult;
  PaymentPollingStatus _pollingStatus = PaymentPollingStatus.idle;
  bool _isPaying = false;
  String? _errorMessage;
  String? _actionError;
  Timer? _pollTimer;
  int _pollAttempts = 0;
  bool _disposed = false;

  PremiumLoadStatus get status => _status;
  PremiumStatus? get premiumStatus => _premiumStatus;
  CreatePaymentResult? get paymentResult => _paymentResult;
  PaymentPollingStatus get pollingStatus => _pollingStatus;
  bool get isPaying => _isPaying;
  String? get errorMessage => _errorMessage;
  String? get actionError => _actionError;
  bool get isPremium => _premiumStatus?.isPremium ?? false;

  Future<void> load() async {
    _status = PremiumLoadStatus.loading;
    _errorMessage = null;
    _safeNotify();

    try {
      final result = await _getPremiumStatusUseCase();
      _premiumStatus = result;
      _status = PremiumLoadStatus.success;

      final pending = result.pendingPayment;
      if (!result.isPremium && pending != null && _paymentResult == null) {
        _paymentResult = CreatePaymentResult(
          paymentId: pending.paymentId,
          status: PaymentStatusType.pending,
          method: pending.method,
          amount: 16,
          reference: pending.reference,
          barcodeUrl: null,
          expiresAt: pending.expiresAt,
        );
        _startPolling();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = PremiumLoadStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = PremiumLoadStatus.error;
    }

    _safeNotify();
  }

  Future<bool> payWithCard(String tokenId) async {
    _isPaying = true;
    _actionError = null;
    _safeNotify();

    try {
      await _payPremiumUseCase(method: PaymentMethodType.card, tokenId: tokenId);
      await _silentReload();
      _isPaying = false;
      _safeNotify();
      return true;
    } on ApiException catch (e) {
      _actionError = e.message;
      _isPaying = false;
      _safeNotify();
      return false;
    } catch (_) {
      _actionError = 'No se pudo procesar el pago';
      _isPaying = false;
      _safeNotify();
      return false;
    }
  }

  Future<bool> payWithVoucher(PaymentMethodType method) async {
    _isPaying = true;
    _actionError = null;
    _safeNotify();

    try {
      final result = await _payPremiumUseCase(method: method);
      _paymentResult = result;
      _isPaying = false;
      _startPolling();
      _safeNotify();
      return true;
    } on ApiException catch (e) {
      _actionError = e.message;
      _isPaying = false;
      _safeNotify();
      return false;
    } catch (_) {
      _actionError = 'No se pudo generar la referencia de pago';
      _isPaying = false;
      _safeNotify();
      return false;
    }
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollAttempts = 0;
    _pollingStatus = PaymentPollingStatus.polling;
    _pollTimer = Timer.periodic(
      const Duration(seconds: _pollIntervalSeconds),
      (_) => _poll(),
    );
  }

  Future<void> _poll() async {
    _pollAttempts++;
    if (_pollAttempts > _maxPollingAttempts) {
      _pollTimer?.cancel();
      _pollingStatus = PaymentPollingStatus.timedOut;
      _safeNotify();
      return;
    }

    try {
      final result = await _getPremiumStatusUseCase();
      _premiumStatus = result;

      if (result.isPremium) {
        _pollTimer?.cancel();
        _pollingStatus = PaymentPollingStatus.succeeded;
        _paymentResult = null;
      } else if (result.pendingPayment == null) {
        _pollTimer?.cancel();
        _pollingStatus = PaymentPollingStatus.failedOrExpired;
      }
      _safeNotify();
    } catch (_) {}
  }

  Future<void> checkPaymentNow() async {
    if (_pollingStatus == PaymentPollingStatus.timedOut) {
      _pollingStatus = PaymentPollingStatus.polling;
      _pollAttempts = 0;
      _safeNotify();
    }
    await _poll();
  }

  void resetPaymentFlow() {
    _pollTimer?.cancel();
    _paymentResult = null;
    _pollingStatus = PaymentPollingStatus.idle;
    _actionError = null;
    _safeNotify();
  }

  Future<void> _silentReload() async {
    try {
      _premiumStatus = await _getPremiumStatusUseCase();
    } catch (_) {}
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _pollTimer?.cancel();
    super.dispose();
  }
}
