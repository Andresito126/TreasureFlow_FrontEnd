import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/home/local/data/datasources/local_home_feed_remote_datasource.dart';
import 'package:treasureflow/features/home/local/data/datasources/local_home_summary_remote_datasource.dart';
import 'package:treasureflow/features/home/local/data/repositories/local_home_feed_repository_impl.dart';
import 'package:treasureflow/features/home/local/data/repositories/local_home_summary_repository_impl.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_feed_repository.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_summary_repository.dartlocal_home_summary_repository.dart';
import 'package:treasureflow/features/home/local/domain/usecases/get_local_home_feed_usecase.dart';
import 'package:treasureflow/features/home/local/domain/usecases/get_local_home_summary_usecase.dart';
import 'package:treasureflow/features/home/local/presentation/providers/local_home_feed_provider.dart';
import 'package:treasureflow/features/home/local/presentation/providers/local_home_summary_provider.dart';

class LocalHomeModule {
  final AppContainer _appContainer;

  LocalHomeModule(this._appContainer);

  LocalHomeFeedRepository _provideRepository() {
    final datasource = LocalHomeFeedRemoteDatasource(_appContainer.apiClient);
    return LocalHomeFeedRepositoryImpl(datasource);
  }

  GetLocalHomeFeedUseCase _provideGetLocalHomeFeedUseCase() =>
      GetLocalHomeFeedUseCase(_provideRepository());

  LocalHomeFeedProvider provideProvider() =>
      LocalHomeFeedProvider(_provideGetLocalHomeFeedUseCase());

  LocalHomeSummaryRepository _provideLocalHomeSummaryRepository() {
    final datasource = LocalHomeSummaryRemoteDatasource(
      _appContainer.apiClient,
    );

    return LocalHomeSummaryRepositoryImpl(datasource);
  }

  GetLocalHomeSummaryUseCase _provideGetLocalHomeSummaryUseCase() =>
      GetLocalHomeSummaryUseCase(_provideLocalHomeSummaryRepository());

  LocalHomeSummaryProvider provideLocalHomeSummaryProvider() =>
      LocalHomeSummaryProvider(_provideGetLocalHomeSummaryUseCase());
}
