import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class TrackingMapView extends StatelessWidget {
  final double? truckLat;
  final double? truckLng;
  final double? selfLat;
  final double? selfLng;
  final bool driverInactive;
  final BitmapDescriptor? truckIcon;
  final void Function(GoogleMapController controller) onMapCreated;

  static const _defaultCenter = LatLng(16.7569, -93.1292);

  const TrackingMapView({
    super.key,
    required this.truckLat,
    required this.truckLng,
    required this.selfLat,
    required this.selfLng,
    required this.driverInactive,
    required this.truckIcon,
    required this.onMapCreated,
  });

  bool get _hasTruck => truckLat != null && truckLng != null;
  bool get _hasSelf => selfLat != null && selfLng != null;

  @override
  Widget build(BuildContext context) {
    final initialCenter = _hasTruck
        ? LatLng(truckLat!, truckLng!)
        : _hasSelf
        ? LatLng(selfLat!, selfLng!)
        : _defaultCenter;

    return GoogleMap(
      initialCameraPosition: CameraPosition(target: initialCenter, zoom: 14),
      markers: _markers(),

      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      onMapCreated: onMapCreated,
    );
  }

  Set<Marker> _markers() {
    return {
      if (_hasTruck)
        Marker(
          markerId: const MarkerId('truck'),
          position: LatLng(truckLat!, truckLng!),
          icon:
              truckIcon ??
              BitmapDescriptor.defaultMarkerWithHue(
                driverInactive
                    ? BitmapDescriptor.hueOrange
                    : BitmapDescriptor.hueGreen,
              ),
          alpha: driverInactive ? 0.55 : 1.0,
          anchor: const Offset(0.5, 0.5),
          infoWindow: InfoWindow(
            title: 'Recolector',
            snippet: driverInactive ? 'Última posición conocida' : null,
          ),
        ),
    };
  }
}
