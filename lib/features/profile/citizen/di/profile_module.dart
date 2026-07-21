import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/media/domain/usecases/upload_image_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/delete_waste_post_usecase.dart';
import 'package:treasureflow/features/profile/citizen/domain/usecases/get_citizen_profile_usecase.dart';
import 'package:treasureflow/features/profile/citizen/domain/usecases/get_my_posts_usecase.dart';
import 'package:treasureflow/features/profile/citizen/domain/usecases/update_citizen_profile_usecase.dart';
import 'package:treasureflow/features/profile/citizen/presentation/providers/edit_citizen_profile_provider.dart';
import 'package:treasureflow/features/profile/citizen/presentation/providers/profile_posts_provider.dart';

class ProfileModule {
  final AppContainer _appContainer;

  ProfileModule(this._appContainer);

  GetMyPostsUseCase _provideGetMyPostsUseCase() =>
      GetMyPostsUseCase(_appContainer.myPostsRepository);

  DeleteWastePostUseCase _provideDeleteWastePostUseCase() =>
      DeleteWastePostUseCase(_appContainer.wastePostRepository);

  UploadImageUseCase _provideUploadImageUseCase() =>
      UploadImageUseCase(_appContainer.mediaRepository);

  ProfilePostsProvider provideProfilePostsProvider() {
    return ProfilePostsProvider(
      getMyPostsUseCase: _provideGetMyPostsUseCase(),
      deleteWastePostUseCase: _provideDeleteWastePostUseCase(),
    );
  }

  GetCitizenProfileUseCase _provideGetCitizenProfileUseCase() =>
      GetCitizenProfileUseCase(_appContainer.citizenProfileRepository);

  UpdateCitizenProfileUseCase _provideUpdateCitizenProfileUseCase() =>
      UpdateCitizenProfileUseCase(_appContainer.citizenProfileRepository);

  EditCitizenProfileProvider provideEditCitizenProfileProvider() {
    return EditCitizenProfileProvider(
      getCitizenProfileUseCase: _provideGetCitizenProfileUseCase(),
      updateCitizenProfileUseCase: _provideUpdateCitizenProfileUseCase(),
      uploadImageUseCase: _provideUploadImageUseCase(),
    );
  }
}
