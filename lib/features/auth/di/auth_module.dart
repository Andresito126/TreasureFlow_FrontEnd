import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/notifications/domain/usecases/register_device_token_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/login_usecase.dart';
import 'package:treasureflow/features/auth/domain/usecases/logout_usecase.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/auth_provider.dart';

class AuthModule {
  final AppContainer _appContainer;

  AuthModule(this._appContainer);

  LoginUseCase _provideLoginUseCase() =>
      LoginUseCase(_appContainer.authRepository);

  LogoutUseCase _provideLogoutUseCase() =>
      LogoutUseCase(_appContainer.authRepository);

  CheckAuthUseCase _provideCheckAuthUseCase() =>
      CheckAuthUseCase(_appContainer.userStorage);

  RegisterDeviceTokenUseCase _provideRegisterDeviceTokenUseCase() =>
      RegisterDeviceTokenUseCase(_appContainer.deviceTokenRepository);

  AuthProvider provideAuthProvider() {
    return AuthProvider(
      loginUseCase: _provideLoginUseCase(),
      logoutUseCase: _provideLogoutUseCase(),
      checkAuthUseCase: _provideCheckAuthUseCase(),
      userStorage: _appContainer.userStorage,
      registerDeviceTokenUseCase: _provideRegisterDeviceTokenUseCase(),
      notificationService: _appContainer.notificationService,
    );
  }
}
