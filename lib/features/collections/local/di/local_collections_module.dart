import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/local/data/datasources/conekta_tokens_remote_datasource.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collections_list_provider.dart';

class LocalCollectionsModule {
  final AppContainer _appContainer;

  LocalCollectionsModule(this._appContainer);

  LocalCollectionDetailProvider provideDetailProvider() {
    return LocalCollectionDetailProvider(
      repository: _appContainer.localCollectionsRepository,
      conektaTokensDatasource: ConektaTokensRemoteDatasource(
        publicKey: dotenv.env['CONEKTA_PUBLIC_KEY'] ?? '',
      ),
    );
  }

  LocalCollectionsListProvider provideListProvider() {
    return LocalCollectionsListProvider(
      repository: _appContainer.localCollectionsRepository,
    );
  }
}
