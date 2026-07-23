import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';

class DeleteReviewUseCase {
  final ReviewsRepository _repository;

  const DeleteReviewUseCase(this._repository);

  Future<void> call(String reviewId) {
    return _repository.deleteReview(reviewId);
  }
}
