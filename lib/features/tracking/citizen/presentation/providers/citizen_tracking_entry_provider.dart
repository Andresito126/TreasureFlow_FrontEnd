import 'package:flutter/foundation.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';

class CitizenTrackingEntryProvider extends ChangeNotifier {
  final RoutesRepository _repository;

  CitizenTrackingEntryProvider({required RoutesRepository repository})
    : _repository = repository;

  String? _routeId;
  String? get routeId => _routeId;
  bool get hasActiveRoute => _routeId != null;

  Future<void> check() async {
    try {
      _routeId = await _repository.getActiveTrackingRouteId();
    } catch (_) {
      _routeId = null;
    }
    notifyListeners();
  }
}
