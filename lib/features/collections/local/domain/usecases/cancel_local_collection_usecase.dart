import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

class CancelLocalCollectionUseCase {
  final LocalCollectionsRepository _repository;

  const CancelLocalCollectionUseCase(this._repository);

  Future<void> call(String collectionId) =>
      _repository.cancelCollection(collectionId);
}
