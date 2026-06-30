import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';
import 'package:treasureflow/features/profile/domain/repositories/my_posts_repository.dart';

class GetMyPostsUseCase {
  final MyPostsRepository _repository;

  const GetMyPostsUseCase(this._repository);

  Future<PaginatedPosts> call({
    required String filter,
    int limit = 10,
    String? cursor,
  }) {
    return _repository.getMyPosts(filter: filter, limit: limit, cursor: cursor);
  }
}
