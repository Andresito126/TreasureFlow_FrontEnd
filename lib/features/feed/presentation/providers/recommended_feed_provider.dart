import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/feed/domain/entities/recommended_post.dart';
import 'package:treasureflow/features/feed/domain/usecases/get_recommended_feed_usecase.dart';

enum RecommendedFeedStatus { idle, loading, success, error }

class RecommendedFeedProvider extends ChangeNotifier {
  final GetRecommendedFeedUseCase _getRecommendedFeedUseCase;

  RecommendedFeedProvider({
    required GetRecommendedFeedUseCase getRecommendedFeedUseCase,
  }) : _getRecommendedFeedUseCase = getRecommendedFeedUseCase;

  static const int _pageSize = 10;

  RecommendedFeedStatus _status = RecommendedFeedStatus.idle;
  String? _errorMessage;
  List<RecommendedPost> _posts = [];
  int _total = 0;
  bool _isLoadingMore = false;

  RecommendedFeedStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<RecommendedPost> get posts => List.unmodifiable(_posts);
  int get total => _total;
  bool get hasMore => _posts.length < _total;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadPosts({bool reset = true}) async {
    if (reset) {
      _status = RecommendedFeedStatus.loading;
      _posts = [];
      _total = 0;
      notifyListeners();
    }

    final offset = reset ? 0 : _posts.length;
    debugPrint('[RecommendedFeedProvider] loadPosts(reset:$reset) -> limit:$_pageSize offset:$offset');

    try {
      final result = await _getRecommendedFeedUseCase(
        limit: _pageSize,
        offset: offset,
      );
      debugPrint('[RecommendedFeedProvider] OK total:${result.total} items:${result.items.length}');
      _posts = reset ? result.items : [..._posts, ...result.items];
      _total = result.total;
      _status = RecommendedFeedStatus.success;
    } on ApiException catch (e) {
      debugPrint('[RecommendedFeedProvider] ApiException: ${e.statusCode} ${e.message} ${e.error}');
      _errorMessage = e.message;
      _status = RecommendedFeedStatus.error;
    } catch (e, stackTrace) {
      debugPrint('[RecommendedFeedProvider] Unexpected error: $e');
      debugPrint('$stackTrace');
      _errorMessage = 'Ocurrió un error inesperado';
      _status = RecommendedFeedStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != RecommendedFeedStatus.success) {
      return;
    }

    _isLoadingMore = true;
    notifyListeners();

    debugPrint('[RecommendedFeedProvider] loadMore() -> limit:$_pageSize offset:${_posts.length}');

    try {
      final result = await _getRecommendedFeedUseCase(
        limit: _pageSize,
        offset: _posts.length,
      );
      debugPrint('[RecommendedFeedProvider] loadMore OK total:${result.total} newItems:${result.items.length}');
      _posts = [..._posts, ...result.items];
      _total = result.total;
    } on ApiException catch (e) {
      debugPrint('[RecommendedFeedProvider] loadMore ApiException: ${e.statusCode} ${e.message} ${e.error}');
      _errorMessage = e.message;
    } catch (e, stackTrace) {
      debugPrint('[RecommendedFeedProvider] loadMore Unexpected error: $e');
      debugPrint('$stackTrace');
      _errorMessage = 'Ocurrió un error inesperado';
    }

    _isLoadingMore = false;
    notifyListeners();
  }
}
