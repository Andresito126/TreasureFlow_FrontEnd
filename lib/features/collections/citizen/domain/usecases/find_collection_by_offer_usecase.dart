import 'package:treasureflow/features/collections/citizen/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

class FindCollectionByOfferUseCase {
  final CitizenCollectionsRepository _repository;

  const FindCollectionByOfferUseCase(this._repository);

  Future<Collection?> call(String offerId) => _repository.findByOfferId(offerId);
}
