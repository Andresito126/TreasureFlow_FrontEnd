import 'package:treasureflow/features/reviews/domain/entities/review.dart';
import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';

class ListEstablishmentReviewsUseCase {
  final ReviewsRepository _repository;

  const ListEstablishmentReviewsUseCase(this._repository);

  Future<ReviewsPage> call({
    required String establishmentId,
    required int limit,
    required int offset,
  }) {
    return _repository.listForEstablishment(
      establishmentId: establishmentId,
      limit: limit,
      offset: offset,
    );
  }
}
