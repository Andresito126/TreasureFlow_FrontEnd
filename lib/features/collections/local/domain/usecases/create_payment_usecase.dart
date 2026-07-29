import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

class CreatePaymentUseCase {
  final LocalCollectionsRepository _repository;

  const CreatePaymentUseCase(this._repository);

  Future<CreatePaymentResult> call(
    String collectionId, {
    required PaymentMethodType method,
    String? tokenId,
  }) => _repository.createPayment(
    collectionId,
    method: method,
    tokenId: tokenId,
  );
}
