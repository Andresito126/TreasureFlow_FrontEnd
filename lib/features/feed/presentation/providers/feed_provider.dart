import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/feed/domain/usecases/get_feed_posts_usecase.dart';
import 'package:treasureflow/features/profile/citizen/domain/entities/post_summary.dart';

enum FeedStatus { idle, loading, success, error }

class FeedProvider extends ChangeNotifier {
  final GetFeedPostsUseCase _getFeedPostsUseCase;

  FeedProvider({required GetFeedPostsUseCase getFeedPostsUseCase})
    : _getFeedPostsUseCase = getFeedPostsUseCase;

  FeedStatus _status = FeedStatus.idle;
  String? _errorMessage;
  List<PostSummary> _posts = [];
  String? _nextCursor;
  bool _isLoadingMore = false;

  FeedStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<PostSummary> get posts => List.unmodifiable(_posts);
  bool get hasMore => _nextCursor != null;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadPosts({bool reset = true}) async {
    if (reset) {
      _status = FeedStatus.loading;
      _posts = [];
      _nextCursor = null;
      notifyListeners();
    }

    try {
      final result = await _getFeedPostsUseCase(
        cursor: reset ? null : _nextCursor,
      );
      _posts = reset ? result.items : [..._posts, ...result.items];
      _nextCursor = result.nextCursor;
      _status = FeedStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = FeedStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = FeedStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != FeedStatus.success) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final result = await _getFeedPostsUseCase(cursor: _nextCursor);
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
}
