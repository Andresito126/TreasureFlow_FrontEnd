import 'package:treasureflow/features/home/local/data/datasources/local_home_feed_remote_datasource.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_feed_item.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_feed_repository.dart';

class LocalHomeFeedRepositoryImpl implements LocalHomeFeedRepository {
  final LocalHomeFeedRemoteDatasource _datasource;

  const LocalHomeFeedRepositoryImpl(this._datasource);

  @override
  Future<LocalHomeFeedPage> getFeed({int limit = 20, int offset = 0}) =>
      _datasource.getFeed(limit: limit, offset: offset);
}
