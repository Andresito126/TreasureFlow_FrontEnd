import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/profile/domain/usecases/get_my_posts_usecase.dart';
import 'package:treasureflow/features/profile/presentation/providers/profile_posts_provider.dart';

class ProfileModule {
  final AppContainer _appContainer;

  ProfileModule(this._appContainer);

  GetMyPostsUseCase _provideGetMyPostsUseCase() =>
      GetMyPostsUseCase(_appContainer.myPostsRepository);

  ProfilePostsProvider provideProfilePostsProvider() {
    return ProfilePostsProvider(
      getMyPostsUseCase: _provideGetMyPostsUseCase(),
    );
  }
}
