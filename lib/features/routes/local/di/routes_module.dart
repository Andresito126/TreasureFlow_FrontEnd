import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/route_detail_provider.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/route_summary_provider.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/weekly_planning_provider.dart';

class RoutesModule {
  final AppContainer _appContainer;

  RoutesModule(this._appContainer);

  WeeklyPlanningProvider provideWeeklyPlanningProvider() {
    return WeeklyPlanningProvider(repository: _appContainer.routesRepository);
  }

  RouteDetailProvider provideRouteDetailProvider() {
    return RouteDetailProvider(repository: _appContainer.routesRepository);
  }

  RouteSummaryProvider provideRouteSummaryProvider() {
    return RouteSummaryProvider(repository: _appContainer.routesRepository);
  }
}
