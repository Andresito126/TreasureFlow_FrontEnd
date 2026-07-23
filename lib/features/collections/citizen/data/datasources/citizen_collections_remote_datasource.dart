import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_list_item.dart';

class CitizenCollectionsRemoteDatasource {
  final ApiClient _apiClient;

  const CitizenCollectionsRemoteDatasource(this._apiClient);

  Future<List<CollectionListItem>> getCollections() async {
    final data = await _apiClient.getList('/collections');
    return data
        .whereType<Map<String, dynamic>>()
        .map(CollectionListItem.fromJson)
        .toList();
  }

  Future<CollectionDetail> getCollectionDetail(String id) async {
    final data = await _apiClient.get('/collections/$id');
    return CollectionDetail.fromJson(data);
  }

  /// null si la collection aún no existe (creación asíncrona tras aceptar la oferta).
  Future<Collection?> findByOfferId(String offerId) async {
    try {
      final data = await _apiClient.get('/collections/by-offer/$offerId');
      return Collection.fromJson(data);
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> confirmAmount(String id) async {
    await _apiClient.patch('/collections/$id/confirm-amount', body: {});
  }

  Future<void> cancelCollection(String id) async {
    await _apiClient.patch('/collections/$id/cancel', body: {});
  }
}
