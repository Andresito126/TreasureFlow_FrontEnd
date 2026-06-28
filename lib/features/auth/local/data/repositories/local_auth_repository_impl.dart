import 'package:treasureflow/features/auth/local/data/datasources/local_auth_remote_datasource.dart';
import 'package:treasureflow/features/auth/local/data/models/local_register_request_model.dart';
import 'package:treasureflow/features/auth/local/domain/entities/operating_schedule.dart';
import 'package:treasureflow/features/auth/local/domain/repositories/local_auth_repository.dart';

class LocalAuthRepositoryImpl implements LocalAuthRepository {
  final LocalAuthRemoteDatasource _datasource;

  const LocalAuthRepositoryImpl(this._datasource);

  @override
  Future<String> signUp({
    required String email,
    required String password,
    required String phone,
    required String storeName,
    required double latitude,
    required double longitude,
    String? addressText,
    required bool hasVehicle,
    required List<String> materialTypeIds,
    required List<OperatingSchedule> schedules,
    required List<String> photoUrls,
    required String profilePictureUrl,
  }) {
    final model = LocalRegisterRequestModel(
      email: email,
      password: password,
      phone: phone,
      storeName: storeName,
      latitude: latitude,
      longitude: longitude,
      addressText: addressText,
      hasVehicle: hasVehicle,
      materialTypeIds: materialTypeIds,
      schedules: schedules,
      photoUrls: photoUrls,
      profilePictureUrl: profilePictureUrl,
    );
    return _datasource.signUp(model);
  }
}
