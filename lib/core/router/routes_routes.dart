import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/routes/local/presentation/screens/route_detail_screen.dart';
import 'package:treasureflow/features/routes/local/presentation/screens/route_planning_screen.dart';

final List<GoRoute> routesRoutes = [
  GoRoute(
    path: '/routePlanning',
    builder: (context, state) => const RoutePlanningScreen(),
  ),
  GoRoute(
    path: '/routeDetail/:date',
    builder: (context, state) =>
        RouteDetailScreen(date: state.pathParameters['date']!),
  ),
];
