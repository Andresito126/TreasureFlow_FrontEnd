abstract class CitizenAuthRepository {
  Future<String> signUp({
    required String email,
    required String password,
    required String phone,
    required String firstName,
    required String paternalLastName,
    required String maternalLastName,
    required String profilePictureUrl,
  });
}
