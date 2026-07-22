import 'package:treasureflow/features/profile/citizen/data/datasources/citizen_profile_remote_datasource.dart';
import 'package:treasureflow/features/profile/citizen/domain/entities/citizen_full_profile.dart';
import 'package:treasureflow/features/profile/citizen/domain/repositories/citizen_profile_repository.dart';

class CitizenProfileRepositoryImpl implements CitizenProfileRepository {
  final CitizenProfileRemoteDatasource _datasource;

  const CitizenProfileRepositoryImpl(this._datasource);

  @override
  Future<CitizenFullProfile> getProfile() => _datasource.getProfile();

  @override
  Future<void> updateProfile({
    String? firstName,
    String? paternalLastName,
    String? maternalLastName,
    String? phone,
    String? profilePictureUrl,
  }) {
    return _datasource.updateProfile(
      firstName: firstName,
      paternalLastName: paternalLastName,
      maternalLastName: maternalLastName,
      phone: phone,
      profilePictureUrl: profilePictureUrl,
    );
  }
}
