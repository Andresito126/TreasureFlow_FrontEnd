import 'package:treasureflow/features/collections/local/domain/entities/check_payment_status_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';

abstract class LocalCollectionsRepository {
  Future<List<CollectionListItem>> getCollections();
  Future<CollectionDetail> getCollectionDetail(String id);
  Future<void> registerWeighing(
    String id,
    double actualQuantity, {
    double? finalAmount,
  });
  Future<CreatePaymentResult> createPayment(
    String id, {
    required PaymentMethodType method,
    String? tokenId,
  });
  Future<CheckPaymentStatusResult> checkPaymentStatus(String id);
  Future<void> cancelCollection(String id);
}
