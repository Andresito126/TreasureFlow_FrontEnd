import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/features/profile/local/domain/usecases/get_establishment_profile_usecase.dart';
import 'package:treasureflow/features/profile/local/domain/usecases/update_establishment_profile_usecase.dart';
import 'package:treasureflow/features/profile/local/presentation/providers/local_profile_provider.dart';

class LocalProfileModule {
  final AppContainer _appContainer;

  LocalProfileModule(this._appContainer);

  GetEstablishmentProfileUseCase _provideGetEstablishmentProfileUseCase() =>
      GetEstablishmentProfileUseCase(_appContainer.localProfileRepository);

  UpdateEstablishmentProfileUseCase
  _provideUpdateEstablishmentProfileUseCase() =>
      UpdateEstablishmentProfileUseCase(_appContainer.localProfileRepository);

  UploadImageUseCase _provideUploadImageUseCase() =>
      UploadImageUseCase(_appContainer.mediaRepository);

  LocalProfileProvider provideLocalProfileProvider() {
    return LocalProfileProvider(
      getEstablishmentProfileUseCase: _provideGetEstablishmentProfileUseCase(),
      updateEstablishmentProfileUseCase: _provideUpdateEstablishmentProfileUseCase(),
      uploadImageUseCase: _provideUploadImageUseCase(),
    );
  }
}
