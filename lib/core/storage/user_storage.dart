import 'package:treasureflow/core/storage/token_storage.dart';

class UserStorage {
  final TokenStorage _tokenStorage;

  UserStorage(this._tokenStorage);

  Future<bool> hasSession() => _tokenStorage.hasTokens();

  Future<void> clearSession() => _tokenStorage.deleteTokens();
}
