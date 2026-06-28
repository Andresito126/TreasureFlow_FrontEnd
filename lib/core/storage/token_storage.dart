import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  Future<void> deleteTokens() async {
    await Future.wait([
      _storage.delete(key: _kAccessToken),
      _storage.delete(key: _kRefreshToken),
    ]);
  }

  Future<bool> hasTokens() async {
    final token = await _storage.read(key: _kAccessToken);
    return token != null;
  }
}
