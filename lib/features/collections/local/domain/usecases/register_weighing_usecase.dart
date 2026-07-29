import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

class RegisterWeighingUseCase {
  final LocalCollectionsRepository _repository;

  const RegisterWeighingUseCase(this._repository);

  Future<void> call(
    String collectionId,
    double actualQuantity, {
    double? finalAmount,
  }) => _repository.registerWeighing(
    collectionId,
    actualQuantity,
    finalAmount: finalAmount,
  );
}
