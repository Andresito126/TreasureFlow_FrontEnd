import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/features/auth/local/domain/usecases/sign_up_local_usecase.dart';
import 'package:treasureflow/features/auth/local/presentation/providers/register_local_provider.dart';

class LocalAuthModule {
  final AppContainer _appContainer;

  LocalAuthModule(this._appContainer);

  SignUpLocalUseCase _provideSignUpUseCase() =>
      SignUpLocalUseCase(_appContainer.localAuthRepository);

  UploadImageUseCase _provideUploadImageUseCase() =>
      UploadImageUseCase(_appContainer.mediaRepository);

  RegisterLocalProvider provideRegisterProvider() {
    return RegisterLocalProvider(
      signUpLocalUseCase: _provideSignUpUseCase(),
      uploadImageUseCase: _provideUploadImageUseCase(),
    );
  }
}
