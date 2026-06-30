import 'package:treasureflow/core/notifications/data/datasources/device_token_remote_datasource.dart';
import 'package:treasureflow/core/notifications/domain/repositories/device_token_repository.dart';

class DeviceTokenRepositoryImpl implements DeviceTokenRepository {
  final DeviceTokenRemoteDatasource _datasource;

  const DeviceTokenRepositoryImpl(this._datasource);

  @override
  Future<void> registerToken(String fcmToken) {
    return _datasource.registerToken(fcmToken);
  }
}
