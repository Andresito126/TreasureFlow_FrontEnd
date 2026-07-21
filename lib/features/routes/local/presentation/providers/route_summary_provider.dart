import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_summary.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';
import 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart';

export 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart'
    show RouteSummaryStatus;

class RouteSummaryProvider extends ChangeNotifier {
  final RoutesRepository _repository;

  RouteSummaryProvider({required RoutesRepository repository})
      : _repository = repository;

  RouteSummaryStatus _status = RouteSummaryStatus.idle;
  String? _errorMessage;
  RouteSummary? _summary;

  RouteSummaryStatus get status => _status;
  String? get errorMessage => _errorMessage;
  RouteSummary? get summary => _summary;

  Future<void> load(String routeId) async {
    _status = RouteSummaryStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _summary = await _repository.getRouteSummary(routeId);
      _status = RouteSummaryStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = RouteSummaryStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = RouteSummaryStatus.error;
    }

    notifyListeners();
  }
}
