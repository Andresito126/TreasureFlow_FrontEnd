import 'package:treasureflow/features/collections/local/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

class GetLocalCollectionDetailUseCase {
  final LocalCollectionsRepository _repository;

  const GetLocalCollectionDetailUseCase(this._repository);

  Future<CollectionDetail> call(String collectionId) =>
      _repository.getCollectionDetail(collectionId);
}
