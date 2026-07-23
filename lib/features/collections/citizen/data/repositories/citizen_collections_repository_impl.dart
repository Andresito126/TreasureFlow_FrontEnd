import 'package:treasureflow/features/collections/citizen/data/datasources/citizen_collections_remote_datasource.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

class CitizenCollectionsRepositoryImpl implements CitizenCollectionsRepository {
  final CitizenCollectionsRemoteDatasource _datasource;

  const CitizenCollectionsRepositoryImpl(this._datasource);

  @override
  Future<List<CollectionListItem>> getCollections() =>
      _datasource.getCollections();

  @override
  Future<CollectionDetail> getCollectionDetail(String id) =>
      _datasource.getCollectionDetail(id);

  @override
  Future<Collection?> findByOfferId(String offerId) =>
      _datasource.findByOfferId(offerId);

  @override
  Future<void> confirmAmount(String id) => _datasource.confirmAmount(id);

  @override
  Future<void> cancelCollection(String id) => _datasource.cancelCollection(id);
}
