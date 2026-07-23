import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/domain/repositories/local_profile_repository.dart';

class UpdateEstablishmentProfileUseCase {
  final LocalProfileRepository _repository;

  const UpdateEstablishmentProfileUseCase(this._repository);

  Future<void> call({
    String? storeName,
    String? phone,
    String? addressText,
    bool? hasVehicle,
    String? profilePictureUrl,
    List<EstablishmentSchedule>? schedules,
    List<String>? photoUrls,
  }) {
    return _repository.updateProfile(
      storeName: storeName,
      phone: phone,
      addressText: addressText,
      hasVehicle: hasVehicle,
      profilePictureUrl: profilePictureUrl,
      schedules: schedules,
      photoUrls: photoUrls,
    );
  }
}
