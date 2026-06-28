import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/features/auth/citizen/domain/usecases/sign_up_citizen_usecase.dart';
import 'package:treasureflow/features/auth/citizen/presentation/providers/register_citizen_provider.dart';

class CitizenAuthModule {
  final AppContainer _appContainer;

  CitizenAuthModule(this._appContainer);

  SignUpCitizenUseCase _provideSignUpUseCase() =>
      SignUpCitizenUseCase(_appContainer.citizenAuthRepository);

  UploadImageUseCase _provideUploadImageUseCase() =>
      UploadImageUseCase(_appContainer.mediaRepository);

  RegisterCitizenProvider provideRegisterProvider() {
    return RegisterCitizenProvider(
      signUpCitizenUseCase: _provideSignUpUseCase(),
      uploadImageUseCase: _provideUploadImageUseCase(),
    );
  }
}
