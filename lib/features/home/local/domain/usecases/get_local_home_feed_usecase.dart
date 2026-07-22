import 'package:treasureflow/features/home/local/domain/entities/local_home_feed_item.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_feed_repository.dart';

class GetLocalHomeFeedUseCase {
  final LocalHomeFeedRepository _repository;

  const GetLocalHomeFeedUseCase(this._repository);

  Future<LocalHomeFeedPage> call({int limit = 20, int offset = 0}) {
    return _repository.getFeed(limit: limit, offset: offset);
  }
}
