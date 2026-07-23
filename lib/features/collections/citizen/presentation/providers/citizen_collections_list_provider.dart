import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/citizen/domain/repositories/citizen_collections_repository.dart';

enum CitizenListStatus { idle, loading, success, error }

class CitizenCollectionsListProvider extends ChangeNotifier {
  final CitizenCollectionsRepository _repository;

  CitizenCollectionsListProvider({
    required CitizenCollectionsRepository repository,
  }) : _repository = repository;

  CitizenListStatus _status = CitizenListStatus.idle;
  String? _errorMessage;
  List<CollectionListItem> _items = [];

  CitizenListStatus get status => _status;
  String? get errorMessage => _errorMessage;

  /// Solo las recolecciones en curso (ni completadas ni canceladas).
  List<CollectionListItem> get activeItems =>
      _items.where((i) => i.collection.status.isActive).toList();

  List<CollectionListItem> get allItems => _items;

  Future<void> load() async {
    _status = CitizenListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _repository.getCollections();
      _status = CitizenListStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = CitizenListStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = CitizenListStatus.error;
    }

    notifyListeners();
  }
}
