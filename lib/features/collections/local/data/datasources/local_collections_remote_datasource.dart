import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/local/domain/entities/check_payment_status_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';

class LocalCollectionsRemoteDatasource {
  final ApiClient _apiClient;

  const LocalCollectionsRemoteDatasource(this._apiClient);

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

  Future<void> registerWeighing(String id, double actualQuantity) async {
    await _apiClient.patch(
      '/collections/$id/weighing',
      body: {'actualQuantity': actualQuantity},
    );
  }

  Future<CreatePaymentResult> createPayment(
    String id, {
    required PaymentMethodType method,
    String? tokenId,
  }) async {
    final data = await _apiClient.post(
      '/collections/$id/payment',
      body: {
        'method': method.apiValue,
        'tokenId': ?tokenId,
      },
    );
    return CreatePaymentResult.fromJson(data);
  }

  Future<CheckPaymentStatusResult> checkPaymentStatus(String id) async {
    final data = await _apiClient.get('/collections/$id/payment/status');
    return CheckPaymentStatusResult.fromJson(data);
  }

  Future<void> cancelCollection(String id) async {
    await _apiClient.patch('/collections/$id/cancel', body: {});
  }
}
