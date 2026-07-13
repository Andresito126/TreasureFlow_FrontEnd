import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/available_slot.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/create_offer_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/get_available_slots_usecase.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/get_waste_post_detail_usecase.dart';

enum WasteDetailLocalStatus { idle, loading, success, error }

enum OfferStatus { idle, submitting, submitted, error }

class WasteDetailLocalProvider extends ChangeNotifier {
  final GetWastePostDetailUseCase _getDetailUseCase;
  final CreateOfferUseCase _createOfferUseCase;
  final GetAvailableSlotsUseCase _getAvailableSlotsUseCase;

  WasteDetailLocalProvider({
    required GetWastePostDetailUseCase getDetailUseCase,
    required CreateOfferUseCase createOfferUseCase,
    required GetAvailableSlotsUseCase getAvailableSlotsUseCase,
  }) : _getDetailUseCase = getDetailUseCase,
       _createOfferUseCase = createOfferUseCase,
       _getAvailableSlotsUseCase = getAvailableSlotsUseCase;

  WasteDetailLocalStatus _status = WasteDetailLocalStatus.idle;
  String? _errorMessage;
  WastePostDetail? _post;

  OfferStatus _offerStatus = OfferStatus.idle;
  String? _offerError;

  List<AvailableSlot> _slots = [];
  bool _slotsLoading = false;

  WasteDetailLocalStatus get status => _status;
  String? get errorMessage => _errorMessage;
  WastePostDetail? get post => _post;

  OfferStatus get offerStatus => _offerStatus;
  String? get offerError => _offerError;
  bool get isSubmitting => _offerStatus == OfferStatus.submitting;

  List<AvailableSlot> get slots => List.unmodifiable(_slots);
  bool get slotsLoading => _slotsLoading;

  Future<void> load(String id) async {
    _status = WasteDetailLocalStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _post = await _getDetailUseCase(id);
      _status = WasteDetailLocalStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = WasteDetailLocalStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = WasteDetailLocalStatus.error;
    }

    notifyListeners();
  }

  Future<void> loadSlots(String establishmentId) async {
    if (establishmentId.isEmpty) return;
    _slotsLoading = true;
    notifyListeners();

    try {
      _slots = await _getAvailableSlotsUseCase(establishmentId);
    } catch (_) {
      _slots = [];
    }

    _slotsLoading = false;
    notifyListeners();
  }

  Future<bool> createOffer({
    required String postId,
    required double pricePerUnit,
    String unit = 'kg',
    required String proposedPickupDate,
    required String proposedPickupStart,
    required String proposedPickupEnd,
  }) async {
    _offerStatus = OfferStatus.submitting;
    _offerError = null;
    notifyListeners();

    try {
      await _createOfferUseCase(
        postId: postId,
        pricePerUnit: pricePerUnit,
        unit: unit,
        proposedPickupDate: proposedPickupDate,
        proposedPickupStart: proposedPickupStart,
        proposedPickupEnd: proposedPickupEnd,
      );
      _offerStatus = OfferStatus.submitted;
      notifyListeners();
      await load(postId);
      return true;
    } on ApiException catch (e) {
      _offerError = e.message;
      _offerStatus = OfferStatus.error;
      notifyListeners();
      return false;
    } catch (_) {
      _offerError = 'Ocurrió un error al enviar la oferta';
      _offerStatus = OfferStatus.error;
      notifyListeners();
      return false;
    }
  }

  void resetOfferStatus() {
    _offerStatus = OfferStatus.idle;
    _offerError = null;
    notifyListeners();
  }
}
