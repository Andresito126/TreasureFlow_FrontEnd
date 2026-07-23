import 'package:go_router/go_router.dart';
import 'package:treasureflow/core/notifications/domain/entities/notification_payload.dart';
import 'package:treasureflow/features/routes/citizen/presentation/screens/pickup_detail_screen.dart';
import 'package:treasureflow/features/routes/local/presentation/screens/route_planning_screen.dart';
import 'package:treasureflow/features/routes/local/presentation/screens/route_summary_screen.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/screens/tracking_screen.dart';

final List<GoRoute> trackingRoutes = [
  GoRoute(
    path: '/tracking',
    builder: (context, state) => TrackingScreen(extra: state.extra),
  ),
  GoRoute(
    path: '/route-summary',
    builder: (context, state) => RouteSummaryScreen(extra: state.extra),
  ),
  GoRoute(
    path: '/pickup-detail',
    builder: (context, state) =>
        PickupDetailScreen(payload: state.extra as NotificationPayload?),
  ),

  GoRoute(
    path: '/route-detail',
    builder: (context, state) => const RoutePlanningScreen(),
  ),
];
