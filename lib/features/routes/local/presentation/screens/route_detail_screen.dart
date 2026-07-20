import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/maps/presentation/screens/location_picker_screen.dart';
import 'package:treasureflow/features/routes/local/di/routes_module.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route_stop.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/route_detail_provider.dart';
import 'package:treasureflow/features/routes/shared/widgets/route_stop_tile_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class RouteDetailScreen extends StatefulWidget {
  final String date;

  const RouteDetailScreen({super.key, required this.date});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late final RouteDetailProvider _provider;
  bool _requestingGps = false;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = RoutesModule(container).provideRouteDetailProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load(widget.date);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _onUseCurrentLocation() async {
    setState(() => _requestingGps = true);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          AppToast.show(
            context,
            'Activa la ubicación de tu dispositivo',
            type: ToastType.warning,
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          AppToast.show(
            context,
            'Necesitamos permiso de ubicación para generar la ruta',
            type: ToastType.warning,
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition();
      await _generate(position.latitude, position.longitude);
    } finally {
      if (mounted) setState(() => _requestingGps = false);
    }
  }

  Future<void> _onPickOnMap() async {
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result == null || !mounted) return;
    await _generate(result.latLng.latitude, result.latLng.longitude);
  }

  Future<void> _generate(double lat, double lng) async {
    final ok = await _provider.generateRoute(driverLat: lat, driverLng: lng);
    if (!mounted) return;
    if (ok) {
      AppToast.show(context, 'Ruta generada', type: ToastType.success);
    } else {
      AppToast.show(
        context,
        _provider.generateError ?? 'No se pudo generar la ruta',
        type: ToastType.error,
      );
    }
  }

  Future<void> _onStopTap(TodayRouteStop stop) async {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stop.citizenName,
                style: textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              if (stop.addressText != null)
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        stop.addressText!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              if (stop.citizenPhone != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      stop.citizenPhone!,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(sheetContext).pop();
                  _onRescheduleTap(stop);
                },
                icon: const Icon(Icons.event_repeat_rounded, size: 18),
                label: const Text('Mover a otro día'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onRescheduleTap(TodayRouteStop stop) async {
    final now = DateTime.now();
    final newDate = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      helpText: 'Nueva fecha de recolección',
    );
    if (newDate == null || !mounted) return;

    final formatted =
        '${newDate.year.toString().padLeft(4, '0')}-${newDate.month.toString().padLeft(2, '0')}-${newDate.day.toString().padLeft(2, '0')}';

    final ok = await _provider.reschedulePickup(
      pickupId: stop.scheduledPickupId,
      newDate: formatted,
    );
    if (!mounted) return;
    if (ok) {
      AppToast.show(
        context,
        'Recolección movida al $formatted',
        type: ToastType.success,
      );
    } else {
      AppToast.show(
        context,
        _provider.rescheduleError ?? 'No se pudo reagendar',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Ruta del ${widget.date}'),
      ),
      body: SafeArea(child: _buildBody(colors, textTheme)),
    );
  }

  Widget _buildBody(ColorScheme colors, TextTheme textTheme) {
    switch (_provider.status) {
      case RouteDetailStatus.idle:
      case RouteDetailStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case RouteDetailStatus.error:
        return _errorState(colors, textTheme);
      case RouteDetailStatus.success:
        return _provider.route == null
            ? _generateState(colors, textTheme)
            : _routeState(colors, textTheme);
    }
  }

  Widget _errorState(ColorScheme colors, TextTheme textTheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              _provider.errorMessage ?? 'No se pudo cargar la ruta',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            PrimaryButtonBlueWidget(
              text: 'Reintentar',
              onPressed: () => _provider.load(widget.date),
            ),
          ],
        ),
      ),
    );
  }

  Widget _generateState(ColorScheme colors, TextTheme textTheme) {
    final isBusy =
        _requestingGps || _provider.generateStatus == GenerateRouteStatus.generating;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.route_rounded, size: 18, color: colors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Aún no hay ruta generada para este día',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Indica desde dónde saldrá el conductor para calcular el orden óptimo de las paradas.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButtonGreenWidget(
            text: 'Usar mi ubicación',
            isLoading: isBusy,
            onPressed: _onUseCurrentLocation,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isBusy ? null : _onPickOnMap,
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Elegir ubicación en el mapa'),
          ),
        ],
      ),
    );
  }

  Widget _routeState(ColorScheme colors, TextTheme textTheme) {
    final route = _provider.route!;
    final stops = route.stops;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.32,
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _centerOf(stops),
              zoom: 13,
            ),
            markers: _markersOf(stops, colors),
            polylines: _polylinesOf(stops, colors),
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
                Row(
                  children: [
                    Icon(Icons.route_rounded, size: 18, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Paradas de la ruta (${stops.length})',
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${(route.totalDistanceMeters / 1000).toStringAsFixed(1)} km',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                for (final stop in stops)
                  RouteStopTileWidget(
                    order: stop.stopOrder,
                    citizenName: stop.citizenName,
                    addressLabel: stop.addressText ?? 'Sin dirección',
                    etaLabel: _formatEta(stop.estimatedArrival),
                    distanceLabel:
                        '${(stop.distanceFromPrevMeters / 1000).toStringAsFixed(1)} km',
                    onTap: () => _onStopTap(stop),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _formatEta(DateTime? eta) {
    if (eta == null) return null;
    final local = eta.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  Set<Marker> _markersOf(List<TodayRouteStop> stops, ColorScheme colors) {
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

  Set<Polyline> _polylinesOf(List<TodayRouteStop> stops, ColorScheme colors) {
    if (stops.length < 2) return {};
    return {
      Polyline(
        polylineId: const PolylineId('route'),
        color: colors.primary,
        width: 4,
        points: [for (final s in stops) LatLng(s.latitude, s.longitude)],
      ),
    };
  }

  LatLng _centerOf(List<TodayRouteStop> stops) {
    if (stops.isEmpty) return const LatLng(16.7569, -93.1292);
    final lat = stops.map((s) => s.latitude).reduce((a, b) => a + b) /
        stops.length;
    final lng = stops.map((s) => s.longitude).reduce((a, b) => a + b) /
        stops.length;
    return LatLng(lat, lng);
  }
}
