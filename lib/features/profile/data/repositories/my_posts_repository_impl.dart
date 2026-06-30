import 'package:treasureflow/features/profile/data/datasources/my_posts_remote_datasource.dart';
import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';
import 'package:treasureflow/features/profile/domain/repositories/my_posts_repository.dart';

class MyPostsRepositoryImpl implements MyPostsRepository {
  final MyPostsRemoteDatasource _datasource;

  const MyPostsRepositoryImpl(this._datasource);

  @override
  Future<PaginatedPosts> getMyPosts({
    required String filter,
    int limit = 10,
    String? cursor,
  }) {
    return _datasource.getMyPosts(filter: filter, limit: limit, cursor: cursor);
  }
}
