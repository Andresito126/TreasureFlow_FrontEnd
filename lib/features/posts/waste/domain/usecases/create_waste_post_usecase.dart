import 'package:treasureflow/features/posts/waste/domain/entities/waste_availability.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class CreateWastePostUseCase {
  final WastePostRepository _repository;

  const CreateWastePostUseCase(this._repository);

  Future<String> call({
    required String description,
    required double latitude,
    required double longitude,
    required String addressText,
    required List<String> photoUrls,
    required String materialTypeId,
    required String deliveryMode,
    required List<WasteAvailability> schedules,
  }) {
    return _repository.create(
      description: description,
      latitude: latitude,
      longitude: longitude,
      addressText: addressText,
      photoUrls: photoUrls,
      materialTypeId: materialTypeId,
      deliveryMode: deliveryMode,
      schedules: schedules,
    );
  }
}