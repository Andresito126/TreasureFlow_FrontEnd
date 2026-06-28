import 'package:treasureflow/features/auth/local/domain/entities/operating_schedule.dart';

class LocalRegisterRequestModel {
  final String email;
  final String password;
  final String phone;
  final String storeName;
  final double latitude;
  final double longitude;
  final String? addressText;
  final bool hasVehicle;
  final List<String> materialTypeIds;
  final List<OperatingSchedule> schedules;
  final List<String> photoUrls;
  final String profilePictureUrl;

  const LocalRegisterRequestModel({
    required this.email,
    required this.password,
    required this.phone,
    required this.storeName,
    required this.latitude,
    required this.longitude,
    this.addressText,
    required this.hasVehicle,
    required this.materialTypeIds,
    required this.schedules,
    required this.photoUrls,
    required this.profilePictureUrl,
  });

  Map<String, dynamic> toJson() => {
        'email': email,
        'password': password,
        'phone': phone,
        'storeName': storeName,
        'latitude': latitude,
        'longitude': longitude,
        if (addressText != null) 'addressText': addressText,
        'hasVehicle': hasVehicle,
        'materialTypeIds': materialTypeIds,
        'schedules': schedules.map((s) => s.toJson()).toList(),
        'photoUrls': photoUrls,
        'profilePictureUrl': profilePictureUrl,
      };
}
