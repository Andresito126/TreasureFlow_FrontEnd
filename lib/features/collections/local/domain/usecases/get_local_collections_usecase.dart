import 'package:treasureflow/features/collections/local/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

class GetLocalCollectionsUseCase {
  final LocalCollectionsRepository _repository;

  const GetLocalCollectionsUseCase(this._repository);

  Future<List<CollectionListItem>> call() => _repository.getCollections();
}
