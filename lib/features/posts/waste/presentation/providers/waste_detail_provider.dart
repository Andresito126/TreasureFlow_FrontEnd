import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/domain/usecases/get_waste_post_detail_usecase.dart';

enum WasteDetailStatus { idle, loading, success, error }

class WasteDetailProvider extends ChangeNotifier {
  final GetWastePostDetailUseCase _getWastePostDetailUseCase;

  WasteDetailProvider({required GetWastePostDetailUseCase getWastePostDetailUseCase})
      : _getWastePostDetailUseCase = getWastePostDetailUseCase;

  WasteDetailStatus _status = WasteDetailStatus.idle;
  String? _errorMessage;
  WastePostDetail? _post;

  WasteDetailStatus get status => _status;
  String? get errorMessage => _errorMessage;
  WastePostDetail? get post => _post;

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
}