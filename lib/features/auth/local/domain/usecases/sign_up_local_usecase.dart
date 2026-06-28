import 'package:treasureflow/features/auth/local/domain/entities/operating_schedule.dart';
import 'package:treasureflow/features/auth/local/domain/repositories/local_auth_repository.dart';

class SignUpLocalUseCase {
  final LocalAuthRepository _repository;

  const SignUpLocalUseCase(this._repository);

  Future<String> call({
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
    return _repository.signUp(
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
  }
}
