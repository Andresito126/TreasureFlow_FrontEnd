import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/domain/repositories/local_profile_repository.dart';

class GetEstablishmentProfileUseCase {
  final LocalProfileRepository _repository;

  const GetEstablishmentProfileUseCase(this._repository);

  Future<EstablishmentProfile> call() => _repository.getProfile();
}
