import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/profile/local/presentation/providers/local_profile_provider.dart';

class LocalProfileModule {
  final AppContainer _appContainer;

  LocalProfileModule(this._appContainer);

  LocalProfileProvider provideLocalProfileProvider() {
    return LocalProfileProvider(
      repository: _appContainer.localProfileRepository,
    );
  }
}
