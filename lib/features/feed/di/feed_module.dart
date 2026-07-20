import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:treasureflow/features/feed/domain/usecases/get_recommended_feed_usecase.dart';
import 'package:treasureflow/features/feed/presentation/providers/feed_provider.dart';
import 'package:treasureflow/features/feed/presentation/providers/recommended_feed_provider.dart';

class FeedModule {
  final AppContainer _container;

  const FeedModule(this._container);

  GetFeedPostsUseCase _provideUseCase() {
    return GetFeedPostsUseCase(_container.feedRepository);
  }

  FeedProvider provideFeedProvider() {
    return FeedProvider(getFeedPostsUseCase: _provideUseCase());
  }

  GetRecommendedFeedUseCase _provideRecommendedUseCase() {
    return GetRecommendedFeedUseCase(_container.feedRepository);
  }

  RecommendedFeedProvider provideRecommendedFeedProvider() {
    return RecommendedFeedProvider(
      getRecommendedFeedUseCase: _provideRecommendedUseCase(),
    );
  }
}
