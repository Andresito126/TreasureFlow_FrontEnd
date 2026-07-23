import 'package:treasureflow/core/storage/user_storage.dart';

class CheckAuthUseCase {
  final UserStorage _userStorage;

  const CheckAuthUseCase(this._userStorage);

  Future<bool> call() => _userStorage.hasSession();
}
