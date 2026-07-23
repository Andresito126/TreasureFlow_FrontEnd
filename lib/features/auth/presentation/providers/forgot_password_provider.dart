import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/auth/domain/usecases/confirm_forgot_password_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/request_forgot_password_code_usecase.dart';
import 'package:treasureflow/features/auth/presentation/providers/forgot_password_ui_state.dart';

export 'package:treasureflow/features/auth/presentation/providers/forgot_password_ui_state.dart'
    show RequestCodeStatus, ResetPasswordStatus;

class ForgotPasswordProvider extends ChangeNotifier {
  final RequestForgotPasswordCodeUseCase _requestCodeUseCase;
  final ConfirmForgotPasswordUseCase _confirmUseCase;

  ForgotPasswordProvider({
    required RequestForgotPasswordCodeUseCase requestCodeUseCase,
    required ConfirmForgotPasswordUseCase confirmUseCase,
  }) : _requestCodeUseCase = requestCodeUseCase,
       _confirmUseCase = confirmUseCase;

  RequestCodeStatus _requestStatus = RequestCodeStatus.idle;
  ResetPasswordStatus _resetStatus = ResetPasswordStatus.idle;
  String? _errorMessage;
  String? _phone;

  RequestCodeStatus get requestStatus => _requestStatus;
  ResetPasswordStatus get resetStatus => _resetStatus;
  String? get errorMessage => _errorMessage;
  String? get phone => _phone;

  Future<void> requestCode(String phone) async {
    _requestStatus = RequestCodeStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _requestCodeUseCase(phone: phone);
      _phone = phone;
      _requestStatus = RequestCodeStatus.sent;
    } on ApiException catch (e) {
      _errorMessage = e.statusCode == 429
          ? 'Demasiados intentos. Espera un momento antes de pedir otro código.'
          : e.message;
      _requestStatus = RequestCodeStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _requestStatus = RequestCodeStatus.error;
    }

    notifyListeners();
  }

  Future<bool> confirm({
    required String code,
    required String newPassword,
  }) async {
    final phone = _phone;
    if (phone == null) return false;

    _resetStatus = ResetPasswordStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _confirmUseCase(phone: phone, code: code, newPassword: newPassword);
      _resetStatus = ResetPasswordStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _resetStatus = ResetPasswordStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _resetStatus = ResetPasswordStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetToPhoneStep() {
    _requestStatus = RequestCodeStatus.idle;
    _resetStatus = ResetPasswordStatus.idle;
    _errorMessage = null;
    _phone = null;
    notifyListeners();
  }
}
