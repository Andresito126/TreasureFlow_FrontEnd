class EstablishmentSchedule {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const EstablishmentSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}

class EstablishmentProfile {
  final String email;
  final String phone;
  final String? profilePictureUrl;
  final String storeName;
  final double latitude;
  final double longitude;
  final String? addressText;
  final bool hasVehicle;
  final List<String> materialTypeIds;
  final List<EstablishmentSchedule> schedules;
  final List<String> photoUrls;

  const EstablishmentProfile({
    required this.email,
    required this.phone,
    required this.storeName,
    required this.latitude,
    required this.longitude,
    required this.hasVehicle,
    required this.materialTypeIds,
    required this.schedules,
    required this.photoUrls,
    this.profilePictureUrl,
    this.addressText,
  });
}
