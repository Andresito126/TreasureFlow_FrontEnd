import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/auth/domain/usecases/change_password_usecase.dart';
import 'package:treasureflow/features/auth/presentation/state/auth_ui_state.dart';

export 'package:treasureflow/features/auth/presentation/state/auth_ui_state.dart'
    show ChangePasswordStatus;

class ChangePasswordProvider extends ChangeNotifier {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordProvider({required ChangePasswordUseCase changePasswordUseCase})
    : _changePasswordUseCase = changePasswordUseCase;

  ChangePasswordStatus _status = ChangePasswordStatus.idle;
  String? _errorMessage;

  ChangePasswordStatus get status => _status;
  String? get errorMessage => _errorMessage;

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _status = ChangePasswordStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _changePasswordUseCase(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      _status = ChangePasswordStatus.success;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ChangePasswordStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = ChangePasswordStatus.error;
      notifyListeners();
      return false;
    }
  }
}
