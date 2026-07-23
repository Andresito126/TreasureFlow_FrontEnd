import 'package:flutter/foundation.dart';
import 'package:treasureflow/core/network/api_client.dart';
import 'package:treasureflow/features/routes/local/domain/entities/weekly_planning_day.dart';
import 'package:treasureflow/features/routes/local/domain/repositories/routes_repository.dart';
import 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart';

export 'package:treasureflow/features/routes/local/presentation/state/route_local_ui_state.dart'
    show WeeklyPlanningStatus;

class WeeklyPlanningProvider extends ChangeNotifier {
  final RoutesRepository _repository;

  WeeklyPlanningProvider({required RoutesRepository repository})
    : _repository = repository;

  WeeklyPlanningStatus _status = WeeklyPlanningStatus.idle;
  String? _errorMessage;
  List<WeeklyPlanningDay> _days = [];
  late DateTime _from;

  WeeklyPlanningStatus get status => _status;
  String? get errorMessage => _errorMessage;
  List<WeeklyPlanningDay> get days => _days;
  DateTime get from => _from;

  Future<void> loadFromToday() => load(DateTime.now());

  Future<void> load(DateTime from) async {
    _from = DateTime(from.year, from.month, from.day);
    _status = WeeklyPlanningStatus.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _days = await _repository.getWeeklyPlanning(_formatDate(_from));
      _status = WeeklyPlanningStatus.success;
    } on ApiException catch (e) {
      _errorMessage = e.message;
      _status = WeeklyPlanningStatus.error;
    } catch (_) {
      _errorMessage = 'Ocurrió un error inesperado';
      _status = WeeklyPlanningStatus.error;
    }

    notifyListeners();
  }

  Future<void> nextWeek() => load(_from.add(const Duration(days: 7)));

  Future<void> previousWeek() {
    final today = DateTime.now();
    final target = _from.subtract(const Duration(days: 7));
    final floor = DateTime(today.year, today.month, today.day);
    return load(target.isBefore(floor) ? floor : target);
  }

  bool get canGoPrevious {
    final today = DateTime.now();
    final floor = DateTime(today.year, today.month, today.day);
    return _from.isAfter(floor);
  }

  static String _formatDate(DateTime date) {
    final y = date.year.toString().padLeft(4, '0');
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}
