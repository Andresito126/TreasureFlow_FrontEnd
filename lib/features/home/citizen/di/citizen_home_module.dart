import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/home/citizen/data/datasources/citizen_home_remote_datasource.dart';
import 'package:treasureflow/features/home/citizen/data/repositories/citizen_home_repository_impl.dart';
import 'package:treasureflow/features/home/citizen/domain/repositories/citizen_home_repository.dart';
import 'package:treasureflow/features/home/citizen/domain/usecases/get_citizen_home_usecase.dart';
import 'package:treasureflow/features/home/citizen/presentation/providers/citizen_home_provider.dart';

class CitizenHomeModule {
  final AppContainer _appContainer;

  CitizenHomeModule(this._appContainer);

  CitizenHomeRepository _provideRepository() {
    final datasource = CitizenHomeRemoteDatasource(_appContainer.apiClient);
    return CitizenHomeRepositoryImpl(datasource);
  }

  GetCitizenHomeUseCase _provideGetCitizenHomeUseCase() =>
      GetCitizenHomeUseCase(_provideRepository());

  CitizenHomeProvider provideProvider() =>
      CitizenHomeProvider(_provideGetCitizenHomeUseCase());
}
