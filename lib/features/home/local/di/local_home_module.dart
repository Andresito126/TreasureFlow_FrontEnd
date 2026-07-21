import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/home/local/data/datasources/local_home_feed_remote_datasource.dart';
import 'package:treasureflow/features/home/local/data/repositories/local_home_feed_repository_impl.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_feed_repository.dart';
import 'package:treasureflow/features/home/local/presentation/providers/local_home_feed_provider.dart';

class LocalHomeModule {
  final AppContainer _appContainer;

  LocalHomeModule(this._appContainer);

  LocalHomeFeedRepository _provideRepository() {
    final datasource = LocalHomeFeedRemoteDatasource(_appContainer.apiClient);
    return LocalHomeFeedRepositoryImpl(datasource);
  }

  LocalHomeFeedProvider provideProvider() =>
      LocalHomeFeedProvider(_provideRepository());
}
