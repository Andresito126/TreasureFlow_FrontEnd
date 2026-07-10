import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/repositories/waste_post_repository.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/get_waste_post_detail_usecase.dart';

enum WasteDetailStatus { idle, loading, success, error }
enum AcceptOfferStatus { idle, accepting, done, error }

class WasteDetailProvider extends ChangeNotifier {
  final GetWastePostDetailUseCase _getWastePostDetailUseCase;
  final WastePostRepository _repository;

  WasteDetailProvider({
    required GetWastePostDetailUseCase getWastePostDetailUseCase,
    required WastePostRepository repository,
  })  : _getWastePostDetailUseCase = getWastePostDetailUseCase,
        _repository = repository;

  WasteDetailStatus _status = WasteDetailStatus.idle;
  String? _errorMessage;
  WastePostDetail? _post;

  AcceptOfferStatus _acceptStatus = AcceptOfferStatus.idle;
  String? _acceptError;
  String? _acceptingOfferId;

  WasteDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;
  WastePostDetail? get post => _post;

  AcceptOfferStatus get acceptStatus => _acceptStatus;
  String? get acceptError => _acceptError;
  String? get acceptingOfferId => _acceptingOfferId;

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

  Future<bool> acceptOffer({required String postId, required String offerId}) async {
    _acceptStatus = AcceptOfferStatus.accepting;
    _acceptingOfferId = offerId;
    _acceptError = null;
    notifyListeners();

    try {
      await _repository.acceptOffer(postId: postId, offerId: offerId);
      _acceptStatus = AcceptOfferStatus.done;
      notifyListeners();
      await load(postId);
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
    }
  }

  void resetAcceptStatus() {
    _acceptStatus = AcceptOfferStatus.idle;
    _acceptError = null;
    notifyListeners();
  }
}