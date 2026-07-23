import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';

class UpdateReviewUseCase {
  final ReviewsRepository _repository;

  const UpdateReviewUseCase(this._repository);

  Future<void> call({
    required String reviewId,
    required int rating,
    String? comment,
  }) {
    return _repository.updateReview(reviewId: reviewId, rating: rating, comment: comment);
  }
}
