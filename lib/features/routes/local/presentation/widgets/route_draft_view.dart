import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route_stop.dart';
import 'package:treasureflow/features/routes/local/presentation/utils/route_map_utils.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_stops_header_widget.dart';
import 'package:treasureflow/features/routes/shared/widgets/route_stop_tile_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class RouteDraftView extends StatelessWidget {
  final TodayRoute route;
  final bool canStartToday;
  final bool isStarting;
  final void Function(TodayRouteStop stop) onStopTap;
  final VoidCallback onStartRoute;

  const RouteDraftView({
    super.key,
    required this.route,
    required this.canStartToday,
    required this.isStarting,
    required this.onStopTap,
    required this.onStartRoute,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final stops = route.stops;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.30,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: RouteMapUtils.centerOf(stops),
              zoom: 13,
            ),
            markers: RouteMapUtils.stopMarkers(stops),
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RouteStopsHeaderWidget(
                  stopCount: stops.length,
                  totalDistanceMeters: route.totalDistanceMeters,
                ),
                const SizedBox(height: 12),
                for (final stop in stops)
                  RouteStopTileWidget(
                    order: stop.stopOrder,
                    citizenName: stop.citizenName,
                    addressLabel: stop.addressText ?? 'Sin dirección',
                    etaLabel: RouteMapUtils.formatEta(stop.estimatedArrival),
                    distanceLabel:
                        '${(stop.distanceFromPrevMeters / 1000).toStringAsFixed(1)} km',
                    onTap: () => onStopTap(stop),
                  ),
                const SizedBox(height: 8),
                if (!canStartToday) ...[
                  Text(
                    'Podrás iniciar este recorrido el día ${RouteMapUtils.formatIsoDateForDisplay(route.routeDate)}.',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                PrimaryButtonGreenWidget(
                  text: 'Iniciar recorrido',
                  isLoading: isStarting,
                  onPressed: canStartToday ? onStartRoute : null,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
