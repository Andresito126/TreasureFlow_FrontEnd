import 'package:treasureflow/features/collections/citizen/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_list_item.dart';

abstract class CitizenCollectionsRepository {
  Future<List<CollectionListItem>> getCollections();
  Future<CollectionDetail> getCollectionDetail(String id);
  Future<Collection?> findByOfferId(String offerId);
  Future<void> confirmAmount(String id);
  Future<void> cancelCollection(String id);
}
