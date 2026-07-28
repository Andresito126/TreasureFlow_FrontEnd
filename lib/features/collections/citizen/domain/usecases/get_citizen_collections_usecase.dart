import 'package:treasureflow/features/collections/citizen/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

class GetCitizenCollectionsUseCase {
  final CitizenCollectionsRepository _repository;

  const GetCitizenCollectionsUseCase(this._repository);

  Future<List<CollectionListItem>> call() => _repository.getCollections();
}
