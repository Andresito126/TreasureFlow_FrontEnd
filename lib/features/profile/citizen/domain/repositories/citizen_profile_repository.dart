import 'package:treasureflow/features/profile/citizen/domain/entities/citizen_full_profile.dart';

abstract class CitizenProfileRepository {
  Future<CitizenFullProfile> getProfile();

  Future<void> updateProfile({
    String? firstName,
    String? paternalLastName,
    String? maternalLastName,
    String? phone,
    String? profilePictureUrl,
  });
}
