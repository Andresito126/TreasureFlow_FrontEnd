import 'package:treasureflow/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;

  const LoginUseCase(this._repository);

  Future<void> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
