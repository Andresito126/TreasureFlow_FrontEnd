import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/delete_waste_post_usecase.dart';
import 'package:treasureflow/features/profile/citizen/domain/entities/post_summary.dart';
import 'package:treasureflow/features/profile/citizen/domain/usecases/get_my_posts_usecase.dart';
import 'package:treasureflow/features/profile/citizen/presentation/state/profile_citizen_ui_state.dart';

export 'package:treasureflow/features/profile/citizen/presentation/state/profile_citizen_ui_state.dart'
    show MyPostsStatus, DeletePostStatus;

class ProfilePostsProvider extends ChangeNotifier {
  final GetMyPostsUseCase _getMyPostsUseCase;
  final DeleteWastePostUseCase _deleteWastePostUseCase;

  static const filterLabels = [
    'Todas',
    'Activas',
    'Con ofertas',
    'Apartadas',
    'Finalizadas',
  ];
  static const _filterValues = [
    'all',
    'active',
    'with_offers',
    'reserved',
    'completed',
  ];

  ProfilePostsProvider({
    required GetMyPostsUseCase getMyPostsUseCase,
    required DeleteWastePostUseCase deleteWastePostUseCase,
  }) : _getMyPostsUseCase = getMyPostsUseCase,
       _deleteWastePostUseCase = deleteWastePostUseCase;

  MyPostsStatus _status = MyPostsStatus.idle;
  String? _errorMessage;
  int _selectedFilterIndex = 0;
  List<PostSummary> _posts = [];
  String? _nextCursor;
  bool _isLoadingMore = false;
  CitizenProfile? _profile;

  DeletePostStatus _deleteStatus = DeletePostStatus.idle;
  String? _deletingPostId;
  String? _deleteError;

  MyPostsStatus get status => _status;
  String? get errorMessage => _errorMessage;
  int get selectedFilterIndex => _selectedFilterIndex;
  List<PostSummary> get posts => List.unmodifiable(_posts);
  bool get hasMore => _nextCursor != null;
  bool get isLoadingMore => _isLoadingMore;
  CitizenProfile? get profile => _profile;

  DeletePostStatus get deleteStatus => _deleteStatus;
  String? get deletingPostId => _deletingPostId;
  String? get deleteError => _deleteError;
  bool isDeletingPost(String postId) =>
      _deleteStatus == DeletePostStatus.deleting && _deletingPostId == postId;

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
      if (reset && result.profile != null) _profile = result.profile;
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

  Future<bool> deletePost(String postId) async {
    _deleteStatus = DeletePostStatus.deleting;
    _deletingPostId = postId;
    _deleteError = null;
    notifyListeners();

    try {
      await _deleteWastePostUseCase(postId);
      _posts = _posts.where((p) => p.id != postId).toList();
      _deleteStatus = DeletePostStatus.done;
      _deletingPostId = null;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _deleteError = e.message;
      _deleteStatus = DeletePostStatus.error;
      _deletingPostId = null;
      notifyListeners();
      return false;
    } catch (_) {
      _deleteError = 'Ocurrió un error al eliminar la publicación';
      _deleteStatus = DeletePostStatus.error;
      _deletingPostId = null;
      notifyListeners();
      return false;
    }
  }

  void resetDeleteStatus() {
    _deleteStatus = DeletePostStatus.idle;
    _deleteError = null;
    notifyListeners();
  }
}
