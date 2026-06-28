import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/logout_usecase.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_ui_state.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _checkAuthUseCase = checkAuthUseCase;

  AuthUiState _status = AuthUiState.idle;
  String? _errorMessage;
  bool _isAuthenticated = false;

  AuthUiState get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  Future<void> checkAuth() async {
    _isAuthenticated = await _checkAuthUseCase();
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _status = AuthUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loginUseCase(email: email, password: password);
      _isAuthenticated = true;
      _status = AuthUiState.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthUiState.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = AuthUiState.error;
    }

    notifyListeners();
  }

  Future<void> logout() async {
    _status = AuthUiState.loading;
    notifyListeners();

    try {
      await _logoutUseCase();
      _isAuthenticated = false;
      _status = AuthUiState.idle;
    } catch (_) {
      _errorMessage = 'Error al cerrar sesión';
      _status = AuthUiState.error;
    }

    notifyListeners();
  }
}