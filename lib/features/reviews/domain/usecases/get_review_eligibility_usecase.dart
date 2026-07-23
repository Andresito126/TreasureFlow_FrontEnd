import 'package:treasureflow/features/reviews/domain/entities/review.dart';
import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';

class GetReviewEligibilityUseCase {
  final ReviewsRepository _repository;

  const GetReviewEligibilityUseCase(this._repository);

  Future<List<EligibleCollection>> call(String establishmentId) {
    return _repository.getEligibility(establishmentId);
  }
}
