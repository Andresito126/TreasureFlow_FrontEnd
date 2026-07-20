import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/get_waste_post_detail_usecase.dart';

enum WasteDetailStatus { idle, loading, success, error }

enum AcceptOfferStatus { idle, accepting, done, error }

enum RejectOfferStatus { idle, rejecting, done, error }

class WasteDetailProvider extends ChangeNotifier {
  final GetWastePostDetailUseCase _getWastePostDetailUseCase;
  final WastePostRepository _repository;

  WasteDetailProvider({
    required GetWastePostDetailUseCase getWastePostDetailUseCase,
    required WastePostRepository repository,
  }) : _getWastePostDetailUseCase = getWastePostDetailUseCase,
       _repository = repository;

  WasteDetailStatus _status = WasteDetailStatus.idle;
  String? _errorMessage;
  WastePostDetail? _post;

  AcceptOfferStatus _acceptStatus = AcceptOfferStatus.idle;
  String? _acceptError;
  String? _acceptingOfferId;

  RejectOfferStatus _rejectStatus = RejectOfferStatus.idle;
  String? _rejectError;
  String? _rejectingOfferId;

  WasteDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;
  WastePostDetail? get post => _post;

  AcceptOfferStatus get acceptStatus => _acceptStatus;
  String? get acceptError => _acceptError;
  String? get acceptingOfferId => _acceptingOfferId;

  RejectOfferStatus get rejectStatus => _rejectStatus;
  String? get rejectError => _rejectError;
  String? get rejectingOfferId => _rejectingOfferId;

  Future<void> load(String id) async {
    _status = WasteDetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _post = await _getWastePostDetailUseCase(id);
      _status = WasteDetailStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = WasteDetailStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = WasteDetailStatus.error;
    }

    notifyListeners();
  }

  Future<void> _silentReload(String id) async {
    try {
      _post = await _getWastePostDetailUseCase(id);
      notifyListeners();
    } catch (_) {}
  }

  Future<bool> acceptOffer({
    required String postId,
    required String offerId,
  }) async {
    _acceptStatus = AcceptOfferStatus.accepting;
    _acceptingOfferId = offerId;
    _acceptError = null;
    notifyListeners();

    try {
      await _repository.acceptOffer(postId: postId, offerId: offerId);
      _acceptStatus = AcceptOfferStatus.done;
      notifyListeners();
      await _silentReload(postId);
      return true;
    } on ApiException catch (e) {
      _acceptError = e.message;
      _acceptStatus = AcceptOfferStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _acceptError = 'Ocurrió un error al aceptar la oferta';
      _acceptStatus = AcceptOfferStatus.error;
      notifyListeners();
      return false;
    } finally {
      _acceptingOfferId = null;
      notifyListeners();
    }
  }

  Future<bool> rejectOffer({
    required String postId,
    required String offerId,
  }) async {
    _rejectStatus = RejectOfferStatus.rejecting;
    _rejectingOfferId = offerId;
    _rejectError = null;
    notifyListeners();

    try {
      await _repository.rejectOffer(postId: postId, offerId: offerId);
      _rejectStatus = RejectOfferStatus.done;
      notifyListeners();
      await _silentReload(postId);
      return true;
    } on ApiException catch (e) {
      _rejectError = e.message;
      _rejectStatus = RejectOfferStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _rejectError = 'Ocurrió un error al rechazar la oferta';
      _rejectStatus = RejectOfferStatus.error;
      notifyListeners();
      return false;
    } finally {
      _rejectingOfferId = null;
      notifyListeners();
    }
  }

  void resetAcceptStatus() {
    _acceptStatus = AcceptOfferStatus.idle;
    _acceptError = null;
    notifyListeners();
  }
}
