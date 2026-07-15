import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/create_offer_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/create_waste_post_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/delete_waste_post_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/get_available_slots_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/get_waste_post_detail_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/update_waste_post_usecase.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/create_waste_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/edit_waste_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/waste_detail_local_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/waste_detail_provider.dart';

class WastePostModule {
  final AppContainer _appContainer;

  WastePostModule(this._appContainer);

  CreateWastePostUseCase _provideCreateUseCase() =>
      CreateWastePostUseCase(_appContainer.wastePostRepository);

  GetWastePostDetailUseCase provideGetDetailUseCase() =>
      GetWastePostDetailUseCase(_appContainer.wastePostRepository);

  UploadImageUseCase _provideUploadImageUseCase() =>
      UploadImageUseCase(_appContainer.mediaRepository);

  CreateWasteProvider provideCreateWasteProvider() {
    return CreateWasteProvider(
      createWastePostUseCase: _provideCreateUseCase(),
      uploadImageUseCase: _provideUploadImageUseCase(),
    );
  }

  WasteDetailProvider provideDetailProvider() {
    return WasteDetailProvider(
      getWastePostDetailUseCase: provideGetDetailUseCase(),
      repository: _appContainer.wastePostRepository,
    );
  }

  DeleteWastePostUseCase provideDeleteWastePostUseCase() =>
      DeleteWastePostUseCase(_appContainer.wastePostRepository);

  EditWasteProvider provideEditWasteProvider() {
    return EditWasteProvider(
      updateUseCase: UpdateWastePostUseCase(_appContainer.wastePostRepository),
      uploadImageUseCase: _provideUploadImageUseCase(),
    );
  }

  WasteDetailLocalProvider provideDetailLocalProvider() {
    return WasteDetailLocalProvider(
      getDetailUseCase: provideGetDetailUseCase(),
      createOfferUseCase: CreateOfferUseCase(_appContainer.wastePostRepository),
      getAvailableSlotsUseCase:
          GetAvailableSlotsUseCase(_appContainer.wastePostRepository),
    );
  }
}