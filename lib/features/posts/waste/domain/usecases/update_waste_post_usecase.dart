import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class UpdateWastePostUseCase {
  final WastePostRepository _repository;

  const UpdateWastePostUseCase(this._repository);

  Future<void> call({
    required String postId,
    required String description,
    required double latitude,
    required double longitude,
    required String addressText,
    required List<String> photoUrls,
    required String materialTypeId,
    required String deliveryMode,
  }) =>
      _repository.updatePost(
        postId: postId,
        description: description,
        latitude: latitude,
        longitude: longitude,
        addressText: addressText,
        photoUrls: photoUrls,
        materialTypeId: materialTypeId,
        deliveryMode: deliveryMode,
      );
}
