import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/establishments/data/datasources/establishments_remote_datasource.dart';
import 'package:treasureflow/features/establishments/data/repositories/establishments_repository_impl.dart';
import 'package:treasureflow/features/establishments/domain/repositories/establishments_repository.dart';
import 'package:treasureflow/features/establishments/domain/usecases/get_establishment_detail_usecase.dart';
import 'package:treasureflow/features/establishments/domain/usecases/list_establishments_usecase.dart';
import 'package:treasureflow/features/establishments/presentation/providers/establishment_detail_provider.dart';
import 'package:treasureflow/features/establishments/presentation/providers/establishments_list_provider.dart';

class EstablishmentsModule {
  final AppContainer _appContainer;

  EstablishmentsModule(this._appContainer);

  EstablishmentsRepository _provideRepository() {
    final datasource = EstablishmentsRemoteDatasource(_appContainer.apiClient);
    return EstablishmentsRepositoryImpl(datasource);
  }

  ListEstablishmentsUseCase _provideListEstablishmentsUseCase() =>
      ListEstablishmentsUseCase(_provideRepository());

  GetEstablishmentDetailUseCase _provideGetEstablishmentDetailUseCase() =>
      GetEstablishmentDetailUseCase(_provideRepository());

  EstablishmentsListProvider provideListProvider() =>
      EstablishmentsListProvider(_provideListEstablishmentsUseCase());

  EstablishmentDetailProvider provideDetailProvider() =>
      EstablishmentDetailProvider(_provideGetEstablishmentDetailUseCase());
}
