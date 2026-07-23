import 'package:treasureflow/features/auth/domain/repositories/auth_repository.dart';

class RequestForgotPasswordCodeUseCase {
  final AuthRepository _repository;

  const RequestForgotPasswordCodeUseCase(this._repository);

  Future<void> call({required String phone}) {
    return _repository.requestForgotPasswordCode(phone: phone);
  }
}
