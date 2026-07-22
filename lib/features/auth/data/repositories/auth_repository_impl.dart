import 'package:treasureflow/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/data/models/login_request_model.dart';
import 'package:treasureflow/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _datasource;

  const AuthRepositoryImpl(this._datasource);

  @override
  Future<void> login({
    required String email,
    required String password,
  }) {
    final model = LoginRequestModel(email: email, password: password);
    return _datasource.login(model);
  }

  @override
  Future<void> logout() => _datasource.logout();

  @override
  Future<void> requestForgotPasswordCode({required String phone}) =>
      _datasource.requestForgotPasswordCode(phone);

  @override
  Future<void> confirmForgotPassword({
    required String phone,
    required String code,
    required String newPassword,
  }) {
    return _datasource.confirmForgotPassword(
      phone: phone,
      code: code,
      newPassword: newPassword,
    );
  }
}
