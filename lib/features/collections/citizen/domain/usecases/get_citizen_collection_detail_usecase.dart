import 'package:treasureflow/features/collections/citizen/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

class GetCitizenCollectionDetailUseCase {
  final CitizenCollectionsRepository _repository;

  const GetCitizenCollectionDetailUseCase(this._repository);

  Future<CollectionDetail> call(String collectionId) =>
      _repository.getCollectionDetail(collectionId);
}
