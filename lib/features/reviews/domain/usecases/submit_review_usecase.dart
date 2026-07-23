import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';

class SubmitReviewUseCase {
  final ReviewsRepository _repository;

  const SubmitReviewUseCase(this._repository);

  Future<String> call({
    required String collectionId,
    required int rating,
    String? comment,
  }) {
    return _repository.submitReview(
      collectionId: collectionId,
      rating: rating,
      comment: comment,
    );
  }
}
