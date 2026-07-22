import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route_stop.dart';

class RouteMapUtils {
  const RouteMapUtils._();

  static Set<Marker> stopMarkers(List<TodayRouteStop> stops) {
    return {
      for (final stop in stops)
        Marker(
          markerId: MarkerId(stop.stopId),
          position: LatLng(stop.latitude, stop.longitude),
          infoWindow: InfoWindow(
            title: 'Parada ${stop.stopOrder}',
            snippet: stop.citizenName,
          ),
        ),
    };
  }

  static LatLng centerOf(List<TodayRouteStop> stops) {
    if (stops.isEmpty) return const LatLng(16.7569, -93.1292);
    final lat =
        stops.map((s) => s.latitude).reduce((a, b) => a + b) / stops.length;
    final lng =
        stops.map((s) => s.longitude).reduce((a, b) => a + b) / stops.length;
    return LatLng(lat, lng);
  }

  static String? formatEta(DateTime? eta) {
    if (eta == null) return null;
    final local = eta.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  static String formatIsoDateForDisplay(String isoDate) {
    final parts = isoDate.split('-');
    if (parts.length != 3) return isoDate;
    return '${parts[2]}/${parts[1]}/${parts[0]}';
  }
}
