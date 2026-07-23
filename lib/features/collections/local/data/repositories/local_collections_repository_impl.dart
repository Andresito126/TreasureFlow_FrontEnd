import 'package:treasureflow/features/collections/local/data/datasources/local_collections_remote_datasource.dart';
import 'package:treasureflow/features/collections/local/domain/entities/check_payment_status_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_detail.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

class LocalCollectionsRepositoryImpl implements LocalCollectionsRepository {
  final LocalCollectionsRemoteDatasource _datasource;

  const LocalCollectionsRepositoryImpl(this._datasource);

  @override
  Future<List<CollectionListItem>> getCollections() =>
      _datasource.getCollections();

  @override
  Future<CollectionDetail> getCollectionDetail(String id) =>
      _datasource.getCollectionDetail(id);

  @override
  Future<void> registerWeighing(
    String id,
    double actualQuantity, {
    double? finalAmount,
  }) => _datasource.registerWeighing(
    id,
    actualQuantity,
    finalAmount: finalAmount,
  );

  @override
  Future<CreatePaymentResult> createPayment(
    String id, {
    required PaymentMethodType method,
    String? tokenId,
  }) => _datasource.createPayment(id, method: method, tokenId: tokenId);

  @override
  Future<CheckPaymentStatusResult> checkPaymentStatus(String id) =>
      _datasource.checkPaymentStatus(id);

  @override
  Future<void> cancelCollection(String id) => _datasource.cancelCollection(id);
}
