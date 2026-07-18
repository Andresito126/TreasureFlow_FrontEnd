import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/citizen/presentation/providers/citizen_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/citizen/presentation/providers/citizen_collections_list_provider.dart';

class CitizenCollectionsModule {
  final AppContainer _appContainer;

  CitizenCollectionsModule(this._appContainer);

  CitizenCollectionDetailProvider provideDetailProvider() {
    return CitizenCollectionDetailProvider(
      repository: _appContainer.citizenCollectionsRepository,
    );
  }

  CitizenCollectionsListProvider provideListProvider() {
    return CitizenCollectionsListProvider(
      repository: _appContainer.citizenCollectionsRepository,
    );
  }
}
