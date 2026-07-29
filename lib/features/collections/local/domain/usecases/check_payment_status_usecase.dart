import 'package:treasureflow/features/collections/local/domain/entities/check_payment_status_result.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

class CheckPaymentStatusUseCase {
  final LocalCollectionsRepository _repository;

  const CheckPaymentStatusUseCase(this._repository);

  Future<CheckPaymentStatusResult> call(String collectionId) =>
      _repository.checkPaymentStatus(collectionId);
}
