import 'package:treasureflow/features/auth/local/domain/entities/operating_schedule.dart';

abstract class LocalAuthRepository {
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
  });
}
