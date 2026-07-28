import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

class CancelCitizenCollectionUseCase {
  final CitizenCollectionsRepository _repository;

  const CancelCitizenCollectionUseCase(this._repository);

  Future<void> call(String collectionId) =>
      _repository.cancelCollection(collectionId);
}
