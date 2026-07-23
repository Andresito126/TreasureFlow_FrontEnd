import 'package:treasureflow/features/home/local/domain/entities/local_home_feed_item.dart';

abstract class LocalHomeFeedRepository {
  Future<LocalHomeFeedPage> getFeed({int limit = 20, int offset = 0});
}
