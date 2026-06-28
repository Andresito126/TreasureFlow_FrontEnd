import 'package:treasureflow/features/auth/citizen/data/datasources/citizen_auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/citizen/data/models/citizen_register_request_model.dart';
import 'package:treasureflow/features/auth/citizen/domain/repositories/citizen_auth_repository.dart';

class CitizenAuthRepositoryImpl implements CitizenAuthRepository {
  final CitizenAuthRemoteDatasource _datasource;

  const CitizenAuthRepositoryImpl(this._datasource);

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required String phone,
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
    required String profilePictureUrl,
  }) {
    final model = CitizenRegisterRequestModel(
      email: email,
      password: password,
      phone: phone,
      firstName: firstName,
      paternalLastName: paternalLastName,
      maternalLastName: maternalLastName,
      profilePictureUrl: profilePictureUrl,
    );
    return _datasource.signUp(model);
  }
}
