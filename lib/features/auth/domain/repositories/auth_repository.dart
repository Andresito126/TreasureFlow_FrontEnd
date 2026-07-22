abstract class AuthRepository {
  Future<void> login({required String email, required String password});

  Future<void> logout();

  Future<void> requestForgotPasswordCode({required String phone});

  Future<void> confirmForgotPassword({
    required String phone,
    required String code,
    required String newPassword,
  });
}
