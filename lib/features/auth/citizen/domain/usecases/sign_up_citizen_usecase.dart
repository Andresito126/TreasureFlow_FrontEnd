import 'package:treasureflow/features/auth/citizen/domain/repositories/citizen_auth_repository.dart';

class SignUpCitizenUseCase {
  final CitizenAuthRepository _repository;

  const SignUpCitizenUseCase(this._repository);

  Future<String> call({
    required String email,
    required String password,
    required String phone,
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
    required String profilePictureUrl,
  }) {
    return _repository.signUp(
      email: email,
      password: password,
      phone: phone,
      firstName: firstName,
      paternalLastName: paternalLastName,
      maternalLastName: maternalLastName,
      profilePictureUrl: profilePictureUrl,
    );
  }
}
