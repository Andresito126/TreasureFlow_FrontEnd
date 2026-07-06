import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';

class CreateOfferUseCase {
  final WastePostRepository _repository;

  const CreateOfferUseCase(this._repository);

  Future<String> call({
    required String postId,
    required double pricePerUnit,
    String unit = 'kg',
  }) {
    return _repository.createOffer(
      postId: postId,
      pricePerUnit: pricePerUnit,
      unit: unit,
    );
  }
}
