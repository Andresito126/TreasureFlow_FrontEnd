import 'package:treasureflow/features/reviews/domain/entities/review.dart';
import 'package:treasureflow/features/reviews/domain/repositories/reviews_repository.dart';

class ListMyReviewsUseCase {
  final ReviewsRepository _repository;

  const ListMyReviewsUseCase(this._repository);

  Future<ReviewsPage> call({required int limit, required int offset}) {
    return _repository.listMine(limit: limit, offset: offset);
  }
}
