import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/notifications/domain/usecases/register_device_token_usecase.dart';
import 'package:treasureflow/core/notifications/services/notification_service.dart';
import 'package:treasureflow/core/storage/user_storage.dart';
import 'package:treasureflow/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/logout_usecase.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_ui_state.dart';

class AuthProvider extends ChangeNotifier {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final CheckAuthUseCase _checkAuthUseCase;
  final UserStorage _userStorage;
  final RegisterDeviceTokenUseCase _registerDeviceTokenUseCase;
  final NotificationService _notificationService;

  AuthProvider({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required CheckAuthUseCase checkAuthUseCase,
    required UserStorage userStorage,
    required RegisterDeviceTokenUseCase registerDeviceTokenUseCase,
    required NotificationService notificationService,
  }) : _loginUseCase = loginUseCase,
       _logoutUseCase = logoutUseCase,
       _checkAuthUseCase = checkAuthUseCase,
       _userStorage = userStorage,
       _registerDeviceTokenUseCase = registerDeviceTokenUseCase,
       _notificationService = notificationService;

  AuthUiState _status = AuthUiState.idle;
  String? _errorMessage;
  bool _isAuthenticated = false;
  String? _userType;

  AuthUiState get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;
  String? get userType => _userType;

  Future<void> checkAuth() async {
    _isAuthenticated = await _checkAuthUseCase();
    if (_isAuthenticated) {
      _userType = await _userStorage.getUserType();
    }
    notifyListeners();
  }

  Future<void> login({required String email, required String password}) async {
    _status = AuthUiState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loginUseCase(email: email, password: password);
      _isAuthenticated = true;
      _userType = await _userStorage.getUserType();
      _status = AuthUiState.success;
      unawaited(_registerDeviceToken());
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = AuthUiState.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = AuthUiState.error;
    }

    notifyListeners();
  }

  Future<void> _registerDeviceToken() async {
    try {
      final fcmToken = await _notificationService.getToken();
      if (fcmToken == null) return;
      await _registerDeviceTokenUseCase(fcmToken);
    } catch (_) {}
  }

  Future<void> logout() async {
    _status = AuthUiState.loading;
    notifyListeners();

    try {
      await _logoutUseCase();
      _isAuthenticated = false;
      _userType = null;
      _status = AuthUiState.idle;
    } catch (_) {
      _errorMessage = 'Error al cerrar sesión';
      _status = AuthUiState.error;
    }

    notifyListeners();
  }
}
