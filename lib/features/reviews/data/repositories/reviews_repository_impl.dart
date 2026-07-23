import 'package:treasureflow/features/reviews/data/datasources/reviews_remote_datasource.dart';
import 'package:treasureflow/features/reviews/domain/entities/review.dart';
import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';

class ReviewsRepositoryImpl implements ReviewsRepository {
  final ReviewsRemoteDatasource _datasource;

  const ReviewsRepositoryImpl(this._datasource);

  @override
  Future<ReviewsPage> listForEstablishment({
    required String establishmentId,
    required int limit,
    required int offset,
  }) {
    return _datasource.listForEstablishment(
      establishmentId: establishmentId,
      limit: limit,
      offset: offset,
    );
  }

  @override
  Future<ReviewsPage> listMine({required int limit, required int offset}) {
    return _datasource.listMine(limit: limit, offset: offset);
  }

  @override
  Future<List<EligibleCollection>> getEligibility(String establishmentId) {
    return _datasource.getEligibility(establishmentId);
  }

  @override
  Future<String> submitReview({
    required String collectionId,
    required int rating,
    String? comment,
  }) {
    return _datasource.submitReview(
      collectionId: collectionId,
      rating: rating,
      comment: comment,
    );
  }

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) {
    return _datasource.updateReview(reviewId: reviewId, rating: rating, comment: comment);
  }

  @override
  Future<void> deleteReview(String reviewId) {
    return _datasource.deleteReview(reviewId);
  }
}
