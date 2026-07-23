import 'package:treasureflow/features/profile/local/data/datasources/local_profile_remote_datasource.dart';
import 'package:treasureflow/features/profile/local/domain/entities/establishment_profile.dart';
import 'package:treasureflow/features/profile/local/domain/repositories/local_profile_repository.dart';

class LocalProfileRepositoryImpl implements LocalProfileRepository {
  final LocalProfileRemoteDatasource _datasource;

  const LocalProfileRepositoryImpl(this._datasource);

  @override
  Future<EstablishmentProfile> getProfile() => _datasource.getProfile();

  @override
  Future<void> updateProfile({
    String? storeName,
    String? phone,
    String? addressText,
    bool? hasVehicle,
    String? profilePictureUrl,
    List<EstablishmentSchedule>? schedules,
    List<String>? photoUrls,
  }) {
    return _datasource.updateProfile(
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
