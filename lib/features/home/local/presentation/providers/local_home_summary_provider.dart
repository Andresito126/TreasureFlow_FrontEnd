import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/home/local/domain/entities/local_home_summary.dart';
import 'package:treasureflow/features/home/local/domain/usecases/get_local_home_summary_usecase.dart';
import 'package:treasureflow/features/home/local/presentation/state/home_local_ui_state.dart';

export 'package:treasureflow/features/home/local/presentation/state/home_local_ui_state.dart'
    show LocalHomeSummaryStatus;

class LocalHomeSummaryProvider extends ChangeNotifier {
  final GetLocalHomeSummaryUseCase _getLocalHomeSummaryUseCase;

  LocalHomeSummaryStatus _status = LocalHomeSummaryStatus.idle;
  LocalHomeSummary? _data;
  String? _errorMessage;

  LocalHomeSummaryStatus get status => _status;
  LocalHomeSummary? get data => _data;
  String? get errorMessage => _errorMessage;

  LocalHomeSummaryProvider(this._getLocalHomeSummaryUseCase);

  Future<void> load() async {
    if (_status == LocalHomeSummaryStatus.loading) return;
    _status = LocalHomeSummaryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _data = await _getLocalHomeSummaryUseCase();
      _status = LocalHomeSummaryStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = LocalHomeSummaryStatus.error;
    } catch (_) {
      _errorMessage = 'Error al cargar el inicio';
      _status = LocalHomeSummaryStatus.error;
    }

    notifyListeners();
  }
}
