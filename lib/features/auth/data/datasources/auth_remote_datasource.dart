import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/storage/token_storage.dart';
import 'package:treasureflow/features/auth/data/models/login_request_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  const AuthRemoteDatasource(this._apiClient, this._tokenStorage);

  Future<void> login(LoginRequestModel model) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: model.toJson(),
    );

    await _tokenStorage.saveTokens(
      response['accessToken'] as String,
      response['refreshToken'] as String,
    );
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken != null) {
      await _apiClient.post(
        '/auth/logout',
        body: {'refreshToken': refreshToken},
      );
    }
    await _tokenStorage.deleteTokens();
  }
}
