import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route_stop.dart';
import 'package:treasureflow/features/routes/local/presentation/utils/route_map_utils.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/active_stop_card_widget.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/finished_stop_tile_widget.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_stops_header_widget.dart';

class RouteActiveView extends StatelessWidget {
  final TodayRoute route;
  final double selfLat;
  final double selfLng;
  final bool socketConnected;
  final bool busy;
  final void Function(TodayRouteStop stop) onCall;
  final void Function(TodayRouteStop stop) onOpenMaps;
  final void Function(TodayRouteStop stop) onComplete;
  final void Function(TodayRouteStop stop) onPostpone;

  const RouteActiveView({
    super.key,
    required this.route,
    required this.selfLat,
    required this.selfLng,
    required this.socketConnected,
    required this.busy,
    required this.onCall,
    required this.onOpenMaps,
    required this.onComplete,
    required this.onPostpone,
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
              target: LatLng(selfLat, selfLng),
              zoom: 14,
            ),
            markers: RouteMapUtils.stopMarkers(stops),

            myLocationEnabled: true,
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
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        socketConnected
                            ? Icons.podcasts_rounded
                            : Icons.wifi_off_rounded,
                        size: 16,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          socketConnected
                              ? 'Transmitiendo tu ubicación en vivo'
                              : 'Conectando la transmisión…',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                RouteStopsHeaderWidget(
                  stopCount: stops.length,
                  totalDistanceMeters: route.totalDistanceMeters,
                ),
                const SizedBox(height: 12),
                for (final stop in stops)
                  if (stop.status.isPending)
                    ActiveStopCardWidget(
                      order: stop.stopOrder,
                      citizenName: stop.citizenName,
                      addressLabel: stop.addressText ?? 'Sin dirección',
                      etaLabel: RouteMapUtils.formatEta(stop.estimatedArrival),
                      hasPhone: stop.citizenPhone != null,
                      busy: busy,
                      onCall: stop.citizenPhone != null
                          ? () => onCall(stop)
                          : null,
                      onOpenMaps: () => onOpenMaps(stop),
                      onComplete: () => onComplete(stop),
                      onPostpone: () => onPostpone(stop),
                    )
                  else
                    FinishedStopTileWidget(
                      citizenName: stop.citizenName,
                      status: stop.status,
                    ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
