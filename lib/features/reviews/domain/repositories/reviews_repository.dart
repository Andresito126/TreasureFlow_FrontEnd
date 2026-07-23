import 'package:treasureflow/features/reviews/domain/entities/review.dart';

abstract class ReviewsRepository {
  Future<ReviewsPage> listForEstablishment({
    required String establishmentId,
    required int limit,
    required int offset,
  });

  Future<ReviewsPage> listMine({required int limit, required int offset});

  Future<List<EligibleCollection>> getEligibility(String establishmentId);

  Future<String> submitReview({
    required String collectionId,
    required int rating,
    String? comment,
  });

  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  });

  Future<void> deleteReview(String reviewId);
}
