import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';

abstract class MyPostsRepository {
  Future<PaginatedPosts> getMyPosts({
    required String filter,
    int limit = 10,
    String? cursor,
  });
}
