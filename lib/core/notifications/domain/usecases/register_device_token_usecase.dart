import 'package:treasureflow/core/notifications/domain/repositories/device_token_repository.dart';

class RegisterDeviceTokenUseCase {
  final DeviceTokenRepository _repository;

  const RegisterDeviceTokenUseCase(this._repository);

  Future<void> call(String fcmToken) {
    return _repository.registerToken(fcmToken);
  }
}
