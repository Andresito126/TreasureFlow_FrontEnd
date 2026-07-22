import 'package:treasureflow/features/auth/domain/repositories/auth_repository.dart';

class ConfirmForgotPasswordUseCase {
  final AuthRepository _repository;

  const ConfirmForgotPasswordUseCase(this._repository);

  Future<void> call({
    required String phone,
    required String code,
    required String newPassword,
  }) {
    return _repository.confirmForgotPassword(
      phone: phone,
      code: code,
      newPassword: newPassword,
    );
  }
}
