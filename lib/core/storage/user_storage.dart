import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:treasureflow/core/storage/token_storage.dart';

class UserStorage {
  static const _kUserType = 'user_type';
  static const _kUserId = 'user_id';
  static const _kOnboardingSeen = 'onboarding_seen';

  final TokenStorage _tokenStorage;
  final FlutterSecureStorage _storage;

  UserStorage(this._tokenStorage, {FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  Future<bool> hasSession() => _tokenStorage.hasTokens();

  Future<void> saveUserData({
    required String userId,
    required String userType,
  }) async {
    await Future.wait([
      _storage.write(key: _kUserId, value: userId),
      _storage.write(key: _kUserType, value: userType),
    ]);
  }

  Future<String?> getUserType() => _storage.read(key: _kUserType);

  Future<String?> getUserId() => _storage.read(key: _kUserId);

  Future<bool> hasSeenOnboarding() async {
    final value = await _storage.read(key: _kOnboardingSeen);
    return value == 'true';
  }

  Future<void> markOnboardingSeen() =>
      _storage.write(key: _kOnboardingSeen, value: 'true');

  Future<void> clearSession() async {
    await Future.wait([
      _tokenStorage.deleteTokens(),
      _storage.delete(key: _kUserType),
      _storage.delete(key: _kUserId),
    ]);
  }
}