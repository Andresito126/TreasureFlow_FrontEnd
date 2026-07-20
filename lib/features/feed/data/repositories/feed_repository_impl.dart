import 'package:treasureflow/features/feed/data/datasources/feed_remote_datasource.dart';
import 'package:treasureflow/features/feed/domain/entities/recommended_post.dart';
import 'package:treasureflow/features/feed/domain/repositories/feed_repository.dart';
import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';

class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDatasource _datasource;

  const FeedRepositoryImpl(this._datasource);

  @override
  Future<PaginatedPosts> getFeedPosts({int limit = 10, String? cursor}) {
    return _datasource.getFeedPosts(limit: limit, cursor: cursor);
  }

  @override
  Future<PaginatedRecommendedPosts> getRecommendedFeed({
    int limit = 10,
    int offset = 0,
  }) {
    return _datasource.getRecommendedFeed(limit: limit, offset: offset);
  }
}
