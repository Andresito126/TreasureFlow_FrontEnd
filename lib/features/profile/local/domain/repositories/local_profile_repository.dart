import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';

abstract class LocalProfileRepository {
  Future<EstablishmentProfile> getProfile();

  Future<void> updateProfile({
    String? storeName,
    String? phone,
    String? addressText,
    bool? hasVehicle,
    String? profilePictureUrl,
  });
}
