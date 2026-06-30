import 'dart:convert';

import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/core/storage/token_storage.dart';
import 'package:treasureflow/core/storage/user_storage.dart';
import 'package:treasureflow/features/auth/data/models/login_request_model.dart';

class AuthRemoteDatasource {
  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;
  final UserStorage _userStorage;

  const AuthRemoteDatasource(
    this._apiClient,
    this._tokenStorage,
    this._userStorage,
  );

  Future<void> login(LoginRequestModel model) async {
    final response = await _apiClient.post(
      '/auth/login',
      body: model.toJson(),
    );

    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;

    await _tokenStorage.saveTokens(accessToken, refreshToken);

    final payload = _decodeJwtPayload(accessToken);
    await _userStorage.saveUserData(
      userId: payload['sub'] as String,
      userType: payload['userType'] as String,
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
    await _userStorage.clearSession();
  }

  Map<String, dynamic> _decodeJwtPayload(String token) {
    final parts = token.split('.');
    final payload = parts[1];
    final normalized = base64Url.normalize(payload);
    final decoded = utf8.decode(base64Url.decode(normalized));
    return jsonDecode(decoded) as Map<String, dynamic>;
  }
}