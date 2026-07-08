import 'package:treasureflow/core/network/api_client.dart';

class DeviceTokenRemoteDatasource {
  final ApiClient _apiClient;

  const DeviceTokenRemoteDatasource(this._apiClient);

  Future<void> registerToken(String fcmToken) async {
    await _apiClient.patch(
      '/auth/fcm-token',
      body: {'fcmToken': fcmToken},
    );
  }
}
