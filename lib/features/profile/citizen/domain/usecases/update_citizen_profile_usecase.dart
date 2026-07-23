import 'package:treasureflow/features/profile/citizen/domain/repositories/citizen_profile_repository.dart';

class UpdateCitizenProfileUseCase {
  final CitizenProfileRepository _repository;

  const UpdateCitizenProfileUseCase(this._repository);

  Future<void> call({
    String? firstName,
    String? paternalLastName,
    String? maternalLastName,
    String? phone,
    String? profilePictureUrl,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      paternalLastName: paternalLastName,
      maternalLastName: maternalLastName,
      phone: phone,
      profilePictureUrl: profilePictureUrl,
    );
  }
}
