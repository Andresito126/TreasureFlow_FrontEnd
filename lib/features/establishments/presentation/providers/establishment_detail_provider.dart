import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/establishments/domain/entities/establishment_detail.dart';
import 'package:treasureflow/features/establishments/domain/usecases/get_establishment_detail_usecase.dart';
import 'package:treasureflow/features/establishments/presentation/state/establishments_ui_state.dart';

export 'package:treasureflow/features/establishments/presentation/state/establishments_ui_state.dart'
    show EstablishmentDetailStatus;

class EstablishmentDetailProvider extends ChangeNotifier {
  final GetEstablishmentDetailUseCase _getEstablishmentDetailUseCase;

  EstablishmentDetailProvider(this._getEstablishmentDetailUseCase);

  EstablishmentDetailStatus _status = EstablishmentDetailStatus.idle;
  EstablishmentDetail? _detail;
  String? _errorMessage;

  EstablishmentDetailStatus get status => _status;
  EstablishmentDetail? get detail => _detail;
  String? get errorMessage => _errorMessage;

  Future<void> load(String id) async {
    _status = EstablishmentDetailStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _detail = await _getEstablishmentDetailUseCase(id);
      _status = EstablishmentDetailStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = EstablishmentDetailStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = EstablishmentDetailStatus.error;
    }

    notifyListeners();
  }
}
