import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';

abstract class FeedRepository {
  Future<PaginatedPosts> getFeedPosts({
    int limit = 10,
    String? cursor,
  });
}
