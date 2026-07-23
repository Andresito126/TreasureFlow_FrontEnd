import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/reviews/domain/entities/review.dart';
import 'package:treasureflow/features/reviews/domain/usecases/get_review_eligibility_usecase.dart';
import 'package:treasureflow/features/reviews/domain/usecases/submit_review_usecase.dart';
import 'package:treasureflow/features/reviews/presentation/state/reviews_ui_state.dart';

export 'package:treasureflow/features/reviews/presentation/state/reviews_ui_state.dart'
    show EligibilityStatus, SubmitReviewStatus;

class SubmitReviewProvider extends ChangeNotifier {
  final GetReviewEligibilityUseCase _getReviewEligibilityUseCase;
  final SubmitReviewUseCase _submitReviewUseCase;

  SubmitReviewProvider({
    required GetReviewEligibilityUseCase getReviewEligibilityUseCase,
    required SubmitReviewUseCase submitReviewUseCase,
  }) : _getReviewEligibilityUseCase = getReviewEligibilityUseCase,
       _submitReviewUseCase = submitReviewUseCase;

  EligibilityStatus _eligibilityStatus = EligibilityStatus.idle;
  List<EligibleCollection> _eligibleCollections = [];
  String? _eligibilityError;

  SubmitReviewStatus _submitStatus = SubmitReviewStatus.idle;
  String? _submitError;

  EligibilityStatus get eligibilityStatus => _eligibilityStatus;
  List<EligibleCollection> get eligibleCollections =>
      List.unmodifiable(_eligibleCollections);
  String? get eligibilityError => _eligibilityError;

  SubmitReviewStatus get submitStatus => _submitStatus;
  String? get submitError => _submitError;
  bool get isSubmitting => _submitStatus == SubmitReviewStatus.submitting;

  Future<void> loadEligibility(String establishmentId) async {
    _eligibilityStatus = EligibilityStatus.loading;
    _eligibilityError = null;
    notifyListeners();

    try {
      _eligibleCollections = await _getReviewEligibilityUseCase(establishmentId);
      _eligibilityStatus = EligibilityStatus.success;
    } on ApiException catch (e) {
      _eligibilityError = e.message;
      _eligibilityStatus = EligibilityStatus.error;
    } catch (_) {
      _eligibilityError = 'Ocurrió un error inesperado';
      _eligibilityStatus = EligibilityStatus.error;
    }

    notifyListeners();
  }

  Future<bool> submit({
    required String collectionId,
    required int rating,
    String? comment,
  }) async {
    _submitStatus = SubmitReviewStatus.submitting;
    _submitError = null;
    notifyListeners();

    try {
      await _submitReviewUseCase(
        collectionId: collectionId,
        rating: rating,
        comment: comment,
      );
      _submitStatus = SubmitReviewStatus.submitted;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _submitError = e.message;
      _submitStatus = SubmitReviewStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _submitError = 'Ocurrió un error al enviar tu reseña';
      _submitStatus = SubmitReviewStatus.error;
      notifyListeners();
      return false;
    }
  }
}
