import 'package:treasureflow/features/feed/domain/repositories/feed_repository.dart';
import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';

class GetFeedPostsUseCase {
  final FeedRepository _repository;

  const GetFeedPostsUseCase(this._repository);

  Future<PaginatedPosts> call({int limit = 10, String? cursor}) {
    return _repository.getFeedPosts(limit: limit, cursor: cursor);
  }
}
