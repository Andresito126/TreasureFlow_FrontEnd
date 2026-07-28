import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

class ConfirmAmountUseCase {
  final CitizenCollectionsRepository _repository;

  const ConfirmAmountUseCase(this._repository);

  Future<void> call(String collectionId) =>
      _repository.confirmAmount(collectionId);
}
