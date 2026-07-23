import 'package:treasureflow/features/profile/citizen/domain/entities/post_summary.dart';
import 'package:treasureflow/features/feed/domain/entities/recommended_post.dart';
import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';

abstract class FeedRepository {
  Future<PaginatedPosts> getFeedPosts({
    int limit = 10,
    String? cursor,
  });

  Future<PaginatedRecommendedPosts> getRecommendedFeed({
    int limit = 10,
    int offset = 0,
  });
}
