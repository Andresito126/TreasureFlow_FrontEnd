class EstablishmentDetailSchedule {
  final int dayOfWeek;
  final String startTime;
  final String endTime;

  const EstablishmentDetailSchedule({
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
  });
}

class EstablishmentDetail {
  final String id;
  final String storeName;
  final String? profilePictureUrl;
  final List<String> photoUrls;
  final String? addressText;
  final String phone;
  final double latitude;
  final double longitude;
  final double averageRating;
  final List<String> materials;
  final bool hasVehicle;
  final List<EstablishmentDetailSchedule> schedules;
  final bool isOpen;

  const EstablishmentDetail({
    required this.id,
    required this.storeName,
    this.profilePictureUrl,
    required this.photoUrls,
    this.addressText,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.averageRating,
    required this.materials,
    required this.hasVehicle,
    required this.schedules,
    required this.isOpen,
  });
}
