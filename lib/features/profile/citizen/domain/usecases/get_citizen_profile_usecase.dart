import 'package:treasureflow/features/profile/citizen/domain/entities/citizen_full_profile.dart';
import 'package:treasureflow/features/profile/citizen/domain/repositories/citizen_profile_repository.dart';

class GetCitizenProfileUseCase {
  final CitizenProfileRepository _repository;

  const GetCitizenProfileUseCase(this._repository);

  Future<CitizenFullProfile> call() => _repository.getProfile();
}
