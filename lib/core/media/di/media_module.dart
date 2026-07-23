import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';

class MediaModule {
  final AppContainer _appContainer;

  MediaModule(this._appContainer);

  UploadImageUseCase provideUploadImageUseCase() =>
      UploadImageUseCase(_appContainer.mediaRepository);
}
