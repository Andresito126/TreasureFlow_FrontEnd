import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_list_item.dart';
import 'package:treasureflow/features/collections/citizen/domain/usecases/get_citizen_collections_usecase.dart';
import 'package:treasureflow/features/collections/citizen/presentation/state/citizen_collections_ui_state.dart';

export 'package:treasureflow/features/collections/citizen/presentation/state/citizen_collections_ui_state.dart'
    show CitizenListStatus;

class CitizenCollectionsListProvider extends ChangeNotifier {
  final GetCitizenCollectionsUseCase _getCollectionsUseCase;

  CitizenCollectionsListProvider({
    required GetCitizenCollectionsUseCase getCollectionsUseCase,
  }) : _getCollectionsUseCase = getCollectionsUseCase;

  CitizenListStatus _status = CitizenListStatus.idle;
  String? _errorMessage;
  List<CollectionListItem> _items = [];

  CitizenListStatus get status => _status;
  String? get errorMessage => _errorMessage;

  List<CollectionListItem> get activeItems =>
      _items.where((i) => i.collection.status.isActive).toList();

  List<CollectionListItem> get allItems => _items;

  Future<void> load() async {
    _status = CitizenListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _items = await _getCollectionsUseCase();
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
