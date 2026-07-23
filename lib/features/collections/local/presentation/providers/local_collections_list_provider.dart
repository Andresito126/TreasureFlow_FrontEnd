import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/local/domain/repositories/local_collections_repository.dart';

enum LocalListStatus { idle, loading, success, error }

class LocalCollectionsListProvider extends ChangeNotifier {
  final LocalCollectionsRepository _repository;

  LocalCollectionsListProvider({required LocalCollectionsRepository repository})
      : _repository = repository;

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
      _items = await _repository.getCollections();
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
