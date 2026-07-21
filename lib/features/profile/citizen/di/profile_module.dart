import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/delete_waste_post_usecase.dart';
import 'package:treasureflow/features/profile/citizen/domain/usecases/get_my_posts_usecase.dart';
import 'package:treasureflow/features/profile/citizen/presentation/providers/profile_posts_provider.dart';

class ProfileModule {
  final AppContainer _appContainer;

  ProfileModule(this._appContainer);

  GetMyPostsUseCase _provideGetMyPostsUseCase() =>
      GetMyPostsUseCase(_appContainer.myPostsRepository);

  DeleteWastePostUseCase _provideDeleteWastePostUseCase() =>
      DeleteWastePostUseCase(_appContainer.wastePostRepository);

  ProfilePostsProvider provideProfilePostsProvider() {
    return ProfilePostsProvider(
      getMyPostsUseCase: _provideGetMyPostsUseCase(),
      deleteWastePostUseCase: _provideDeleteWastePostUseCase(),
    );
  }
}
