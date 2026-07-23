import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/reviews/domain/entities/review.dart';
import 'package:treasureflow/features/reviews/domain/usecases/delete_review_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/list_establishment_reviews_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/list_my_reviews_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/update_review_usecase.dart';
import 'package:treasureflow/features/reviews/presentation/state/reviews_ui_state.dart';

export 'package:treasureflow/features/reviews/presentation/state/reviews_ui_state.dart'
    show ReviewsListStatus;

/// Lista paginada de reseñas — si se construye con [establishmentId] consulta
/// GET /reviews/establishment/:id (detalle público del local visto por
/// cualquiera); si no, consulta GET /reviews/me (el local viendo las suyas).
class EstablishmentReviewsProvider extends ChangeNotifier {
  final ListEstablishmentReviewsUseCase _listEstablishmentReviewsUseCase;
  final ListMyReviewsUseCase _listMyReviewsUseCase;
  final UpdateReviewUseCase _updateReviewUseCase;
  final DeleteReviewUseCase _deleteReviewUseCase;
  final String? establishmentId;

  static const _pageSize = 10;

  EstablishmentReviewsProvider({
    required ListEstablishmentReviewsUseCase listEstablishmentReviewsUseCase,
    required ListMyReviewsUseCase listMyReviewsUseCase,
    required UpdateReviewUseCase updateReviewUseCase,
    required DeleteReviewUseCase deleteReviewUseCase,
    this.establishmentId,
  }) : _listEstablishmentReviewsUseCase = listEstablishmentReviewsUseCase,
       _listMyReviewsUseCase = listMyReviewsUseCase,
       _updateReviewUseCase = updateReviewUseCase,
       _deleteReviewUseCase = deleteReviewUseCase;

  ReviewsListStatus _status = ReviewsListStatus.idle;
  List<Review> _items = [];
  int _total = 0;
  String? _errorMessage;
  bool _isLoadingMore = false;

  ReviewsListStatus get status => _status;
  List<Review> get items => List.unmodifiable(_items);
  int get total => _total;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _items.length < _total;
  bool get isLoadingMore => _isLoadingMore;

  Future<ReviewsPage> _fetch(int offset) {
    return establishmentId != null
        ? _listEstablishmentReviewsUseCase(
            establishmentId: establishmentId!,
            limit: _pageSize,
            offset: offset,
          )
        : _listMyReviewsUseCase(limit: _pageSize, offset: offset);
  }

  Future<void> load() async {
    if (_status == ReviewsListStatus.loading) return;
    _status = ReviewsListStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final page = await _fetch(0);
      _items = page.items;
      _total = page.total;
      _status = ReviewsListStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = ReviewsListStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = ReviewsListStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore || _status != ReviewsListStatus.success) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final page = await _fetch(_items.length);
      _items = [..._items, ...page.items];
      _total = page.total;
    } catch (_) {}

    _isLoadingMore = false;
    notifyListeners();
  }

  Future<bool> updateReview({
    required String reviewId,
    required int rating,
    String? comment,
  }) async {
    try {
      await _updateReviewUseCase(reviewId: reviewId, rating: rating, comment: comment);
      final index = _items.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        final old = _items[index];
        _items = [..._items]
          ..[index] = Review(
            id: old.id,
            citizenId: old.citizenId,
            citizenName: old.citizenName,
            rating: rating,
            comment: comment,
            createdAt: old.createdAt,
          );
        notifyListeners();
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteReview(String reviewId) async {
    try {
      await _deleteReviewUseCase(reviewId);
      _items = _items.where((r) => r.id != reviewId).toList();
      _total = _total > 0 ? _total - 1 : 0;
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }
}
