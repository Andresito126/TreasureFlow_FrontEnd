import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/profile/domain/entities/post_summary.dart';
import 'package:treasureflow/features/profile/domain/usecases/get_my_posts_usecase.dart';

enum MyPostsStatus { idle, loading, success, error }

class ProfilePostsProvider extends ChangeNotifier {
  final GetMyPostsUseCase _getMyPostsUseCase;

  static const filterLabels = ['Todas', 'Activas', 'Con ofertas', 'Apartadas', 'Finalizadas'];
  static const _filterValues = ['all', 'active', 'with_offers', 'reserved', 'completed'];

  ProfilePostsProvider({required GetMyPostsUseCase getMyPostsUseCase})
      : _getMyPostsUseCase = getMyPostsUseCase;

  MyPostsStatus _status = MyPostsStatus.idle;
  String? _errorMessage;
  int _selectedFilterIndex = 0;
  List<PostSummary> _posts = [];
  String? _nextCursor;
  bool _isLoadingMore = false;

  MyPostsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int get selectedFilterIndex => _selectedFilterIndex;
  List<PostSummary> get posts => List.unmodifiable(_posts);
  bool get hasMore => _nextCursor != null;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadPosts({bool reset = true}) async {
    if (reset) {
      _status = MyPostsStatus.loading;
      _posts = [];
      _nextCursor = null;
      notifyListeners();
    }

    try {
      final result = await _getMyPostsUseCase(
        filter: _filterValues[_selectedFilterIndex],
        cursor: reset ? null : _nextCursor,
      );
      _posts = reset ? result.items : [..._posts, ...result.items];
      _nextCursor = result.nextCursor;
      _status = MyPostsStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = MyPostsStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = MyPostsStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != MyPostsStatus.success) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _getMyPostsUseCase(
        filter: _filterValues[_selectedFilterIndex],
        cursor: _nextCursor,
      );
      _posts = [..._posts, ...result.items];
      _nextCursor = result.nextCursor;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
    }

    _isLoadingMore = false;
    notifyListeners();
  }

  void setFilter(int index) {
    if (_selectedFilterIndex == index) return;
    _selectedFilterIndex = index;
    loadPosts(reset: true);
  }
}
