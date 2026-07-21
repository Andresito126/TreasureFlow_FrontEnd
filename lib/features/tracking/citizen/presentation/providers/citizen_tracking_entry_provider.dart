import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';

class CitizenTrackingEntryProvider extends ChangeNotifier {
  final RoutesRepository _repository;

  CitizenTrackingEntryProvider({required RoutesRepository repository})
    : _repository = repository;

  String? _routeId;
  Timer? _passiveRefreshTimer;
  bool _disposed = false;

  String? get routeId => _routeId;
  bool get hasActiveRoute => _routeId != null;

  Future<void> check() async {
    try {
      final info = await _repository.getActiveTrackingInfo();
      _routeId = info?.routeId;
    } catch (_) {
      _routeId = null;
    }
    _safeNotify();
  }

  void startPassiveRefresh({int seconds = 10}) {
    if (_passiveRefreshTimer != null) return;
    _passiveRefreshTimer = Timer.periodic(
      Duration(seconds: seconds),
      (_) => check(),
    );
  }

  void stopPassiveRefresh() {
    _passiveRefreshTimer?.cancel();
    _passiveRefreshTimer = null;
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stopPassiveRefresh();
    super.dispose();
  }
}
