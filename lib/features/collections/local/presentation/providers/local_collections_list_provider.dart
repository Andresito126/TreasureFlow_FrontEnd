import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/local/domain/usecases/get_local_collections_usecase.dart';
import 'package:treasureflow/features/collections/local/presentation/state/local_collections_ui_state.dart';

export 'package:treasureflow/features/collections/local/presentation/state/local_collections_ui_state.dart'
    show LocalListStatus;

class LocalCollectionsListProvider extends ChangeNotifier {
  final GetLocalCollectionsUseCase _getCollectionsUseCase;

  LocalCollectionsListProvider({
    required GetLocalCollectionsUseCase getCollectionsUseCase,
  }) : _getCollectionsUseCase = getCollectionsUseCase;

  LocalListStatus _status = LocalListStatus.idle;
  String? _errorMessage;
  List<CollectionListItem> _items = [];

  LocalListStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// Solo las recolecciones en curso (ni completadas ni canceladas).
  List<CollectionListItem> get activeItems =>
      _items.where((i) => i.collection.status.isActive).toList();

  List<CollectionListItem> get allItems => _items;

  Future<void> load() async {
    _status = LocalListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _getCollectionsUseCase();
      _status = LocalListStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = LocalListStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = LocalListStatus.error;
    }

    notifyListeners();
  }
}
