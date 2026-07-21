import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_feed_item.dart';
import 'package:treasureflow/features/home/local/domain/repositories/local_home_feed_repository.dart';

enum LocalHomeFeedStatus { idle, loading, success, error }

class LocalHomeFeedProvider extends ChangeNotifier {
  final LocalHomeFeedRepository _repository;

  LocalHomeFeedStatus _status = LocalHomeFeedStatus.idle;
  List<LocalHomeFeedItem> _items = [];
  int _total = 0;
  String? _errorMessage;

  LocalHomeFeedStatus get status => _status;
  List<LocalHomeFeedItem> get items => List.unmodifiable(_items);
  int get total => _total;
  String? get errorMessage => _errorMessage;

  LocalHomeFeedProvider(this._repository);

  Future<void> load() async {
    if (_status == LocalHomeFeedStatus.loading) return;
    _status = LocalHomeFeedStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _repository.getFeed();
      _items = page.results;
      _total = page.total;
      _status = LocalHomeFeedStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = LocalHomeFeedStatus.error;
    } catch (_) {
      _errorMessage = 'Error al cargar el inicio';
      _status = LocalHomeFeedStatus.error;
    }

    notifyListeners();
  }
}
