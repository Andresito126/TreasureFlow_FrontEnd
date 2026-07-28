import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/citizen/domain/usecases/cancel_citizen_collection_usecase.dart';
import 'package:treasureflow/features/collections/citizen/domain/usecases/confirm_amount_usecase.dart';
import 'package:treasureflow/features/collections/citizen/domain/usecases/find_collection_by_offer_usecase.dart';
import 'package:treasureflow/features/collections/citizen/domain/usecases/get_citizen_collection_detail_usecase.dart';
import 'package:treasureflow/features/collections/citizen/domain/usecases/get_citizen_collections_usecase.dart';
import 'package:treasureflow/features/collections/citizen/presentation/providers/citizen_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/citizen/presentation/providers/citizen_collections_list_provider.dart';

class CitizenCollectionsModule {
  final AppContainer _appContainer;

  CitizenCollectionsModule(this._appContainer);

  GetCitizenCollectionsUseCase _provideGetCollectionsUseCase() =>
      GetCitizenCollectionsUseCase(_appContainer.citizenCollectionsRepository);

  GetCitizenCollectionDetailUseCase _provideGetDetailUseCase() =>
      GetCitizenCollectionDetailUseCase(
        _appContainer.citizenCollectionsRepository,
      );

  ConfirmAmountUseCase _provideConfirmAmountUseCase() =>
      ConfirmAmountUseCase(_appContainer.citizenCollectionsRepository);

  CancelCitizenCollectionUseCase _provideCancelCollectionUseCase() =>
      CancelCitizenCollectionUseCase(_appContainer.citizenCollectionsRepository);

  FindCollectionByOfferUseCase provideFindByOfferUseCase() =>
      FindCollectionByOfferUseCase(_appContainer.citizenCollectionsRepository);

  CitizenCollectionDetailProvider provideDetailProvider() {
    return CitizenCollectionDetailProvider(
      getDetailUseCase: _provideGetDetailUseCase(),
      confirmAmountUseCase: _provideConfirmAmountUseCase(),
      cancelCollectionUseCase: _provideCancelCollectionUseCase(),
    );
  }

  CitizenCollectionsListProvider provideListProvider() {
    return CitizenCollectionsListProvider(
      getCollectionsUseCase: _provideGetCollectionsUseCase(),
    );
  }
}
