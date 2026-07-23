import 'package:treasureflow/features/feed/domain/entities/recommended_post.dart';
import 'package:treasureflow/features/feed/domain/repositories/feed_repository.dart';

class GetRecommendedFeedUseCase {
  final FeedRepository _repository;

  const GetRecommendedFeedUseCase(this._repository);

  Future<PaginatedRecommendedPosts> call({int limit = 10, int offset = 0}) {
    return _repository.getRecommendedFeed(limit: limit, offset: offset);
  }
}
