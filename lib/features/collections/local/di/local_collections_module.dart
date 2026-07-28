import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/local/domain/usecases/cancel_local_collection_usecase.dart';
import 'package:treasureflow/features/collections/local/domain/usecases/check_payment_status_usecase.dart';
import 'package:treasureflow/features/collections/local/domain/usecases/create_payment_usecase.dart';
import 'package:treasureflow/features/collections/local/domain/usecases/get_local_collection_detail_usecase.dart';
import 'package:treasureflow/features/collections/local/domain/usecases/get_local_collections_usecase.dart';
import 'package:treasureflow/features/collections/local/domain/usecases/register_weighing_usecase.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collections_list_provider.dart';

class LocalCollectionsModule {
  final AppContainer _appContainer;

  LocalCollectionsModule(this._appContainer);

  GetLocalCollectionsUseCase _provideGetCollectionsUseCase() =>
      GetLocalCollectionsUseCase(_appContainer.localCollectionsRepository);

  GetLocalCollectionDetailUseCase _provideGetDetailUseCase() =>
      GetLocalCollectionDetailUseCase(_appContainer.localCollectionsRepository);

  RegisterWeighingUseCase _provideRegisterWeighingUseCase() =>
      RegisterWeighingUseCase(_appContainer.localCollectionsRepository);

  CreatePaymentUseCase _provideCreatePaymentUseCase() =>
      CreatePaymentUseCase(_appContainer.localCollectionsRepository);

  CheckPaymentStatusUseCase _provideCheckPaymentStatusUseCase() =>
      CheckPaymentStatusUseCase(_appContainer.localCollectionsRepository);

  CancelLocalCollectionUseCase _provideCancelCollectionUseCase() =>
      CancelLocalCollectionUseCase(_appContainer.localCollectionsRepository);

  LocalCollectionDetailProvider provideDetailProvider() {
    return LocalCollectionDetailProvider(
      getDetailUseCase: _provideGetDetailUseCase(),
      registerWeighingUseCase: _provideRegisterWeighingUseCase(),
      createPaymentUseCase: _provideCreatePaymentUseCase(),
      checkPaymentStatusUseCase: _provideCheckPaymentStatusUseCase(),
      cancelCollectionUseCase: _provideCancelCollectionUseCase(),
    );
  }

  LocalCollectionsListProvider provideListProvider() {
    return LocalCollectionsListProvider(
      getCollectionsUseCase: _provideGetCollectionsUseCase(),
    );
  }
}
