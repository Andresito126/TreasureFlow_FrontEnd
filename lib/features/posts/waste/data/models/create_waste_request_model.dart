import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';

class CreateWasteRequestModel {
  final String description;
  final double latitude;
  final double longitude;
  final String addressText;
  final List<String> photoUrls;
  final String materialTypeId;
  final String deliveryMode;
  final List<WasteAvailability> schedules;

  const CreateWasteRequestModel({
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.addressText,
    required this.photoUrls,
    required this.materialTypeId,
    required this.deliveryMode,
    required this.schedules,
  });

  Map<String, dynamic> toJson() => {
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'addressText': addressText,
        'photoUrls': photoUrls,
        'materialTypeId': materialTypeId,
        'deliveryMode': deliveryMode,
        'schedules': schedules.map((s) => s.toJson()).toList(),
      };
}
