import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/maps/presentation/screens/location_picker_screen.dart';
import 'package:treasureflow/features/routes/local/di/routes_module.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_status.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route_stop.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/route_detail_provider.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/postpone_reason_sheet.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_active_view.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_completed_view.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_draft_view.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_error_view.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_generate_view.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_gps_denied_view.dart';
import 'package:treasureflow/features/routes/local/presentation/widgets/route_obtaining_location_view.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteDetailScreen extends StatefulWidget {
  final String date;

  const RouteDetailScreen({super.key, required this.date});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late final RouteDetailProvider _provider;
  bool _requestingGps = false;

  bool _broadcastAttempted = false;
  bool _gpsDenied = false;
  double? _selfLat;
  double? _selfLng;
  io.Socket? _socket;
  bool _socketConnected = false;
  bool _liveGps = true;
  Timer? _heartbeat;

  bool get _hasSelfLocation => _selfLat != null && _selfLng != null;

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
    _stopBroadcast();
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (_socket != null &&
        _provider.route?.status != RouteExecutionStatus.active) {
      _stopBroadcast();
    }
    if (mounted) setState(() {});
  }

  Future<void> _onUseCurrentLocation() async {
    setState(() => _requestingGps = true);
    try {
      final position = await _resolveGps();
      if (position == null) return;
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

  Future<Position?> _resolveGps() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        AppToast.show(
          context,
          'Activa la ubicación de tu dispositivo',
          type: ToastType.warning,
        );
      }
      return null;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      if (mounted) {
        AppToast.show(
          context,
          'Necesitamos permiso de ubicación',
          type: ToastType.warning,
        );
      }
      return null;
    }

    return Geolocator.getCurrentPosition();
  }

  Future<void> _autoStartBroadcast() async {
    if (_broadcastAttempted) return;
    _broadcastAttempted = true;

    final position = await _resolveGps();
    if (!mounted) return;
    if (position == null) {
      setState(() => _gpsDenied = true);
      return;
    }
    await _startBroadcast(position.latitude, position.longitude, live: true);
  }

  Future<void> _retryBroadcast() async {
    setState(() {
      _gpsDenied = false;
      _broadcastAttempted = false;
    });
    await _autoStartBroadcast();
  }

  Future<void> _broadcastFromMap() async {
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result == null || !mounted) return;
    setState(() => _gpsDenied = false);
    await _startBroadcast(
      result.latLng.latitude,
      result.latLng.longitude,
      live: false,
    );
  }

  Future<void> _startBroadcast(
    double lat,
    double lng, {
    required bool live,
  }) async {
    _liveGps = live;
    setState(() {
      _selfLat = lat;
      _selfLng = lng;
    });

    final factory = context.read<AppContainer>().trackingSocketClientFactory;
    final socket = await factory.create();
    _socket = socket;
    socket.onConnect((_) {
      _socketConnected = true;
      _emitLocation();
    });
    socket.onDisconnect((_) => _socketConnected = false);
    socket.connect();

    _heartbeat = Timer.periodic(
      const Duration(seconds: 4),
      (_) => _tickBroadcast(),
    );
  }

  Future<void> _tickBroadcast() async {
    if (_liveGps) {
      try {
        final position = await Geolocator.getCurrentPosition();
        if (!mounted) return;
        setState(() {
          _selfLat = position.latitude;
          _selfLng = position.longitude;
        });
      } catch (_) {}
    }
    _emitLocation();
  }

  void _emitLocation() {
    final route = _provider.route;
    if (route == null || !_socketConnected || !_hasSelfLocation) return;
    _socket?.volatile.emit('driver:location', {
      'routeId': route.routeId,
      'lat': _selfLat,
      'lng': _selfLng,
    });
  }

  void _stopBroadcast() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _socket?.dispose();
    _socket = null;
    _socketConnected = false;
  }

  Future<void> _onStartRoute() async {
    final ok = await _provider.startRoute();
    if (!mounted) return;
    AppToast.show(
      context,
      ok
          ? 'Recorrido iniciado'
          : (_provider.stopActionError ?? 'No se pudo iniciar'),
      type: ok ? ToastType.success : ToastType.error,
    );
  }

  Future<void> _onCompleteStop(TodayRouteStop stop) async {
    final ok = await _provider.completeStop(stop.stopId);
    if (!mounted) return;
    AppToast.show(
      context,
      ok
          ? 'Parada completada'
          : (_provider.stopActionError ?? 'No se pudo completar'),
      type: ok ? ToastType.success : ToastType.error,
    );
  }

  Future<void> _onPostponeStop(TodayRouteStop stop) async {
    final result = await showPostponeReasonSheet(context);
    if (result == null || !mounted) return;
    final newDate =
        '${result.newDate.year.toString().padLeft(4, '0')}-${result.newDate.month.toString().padLeft(2, '0')}-${result.newDate.day.toString().padLeft(2, '0')}';
    final ok = await _provider.postponeStop(
      stop.stopId,
      newDate,
      result.reason,
    );
    if (!mounted) return;
    AppToast.show(
      context,
      ok
          ? 'Parada pospuesta'
          : (_provider.stopActionError ?? 'No se pudo posponer'),
      type: ok ? ToastType.success : ToastType.error,
    );
  }

  Future<void> _callCitizen(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri) && mounted) {
      AppToast.show(
        context,
        'No se pudo abrir el teléfono',
        type: ToastType.error,
      );
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) &&
        mounted) {
      AppToast.show(context, 'No se pudo abrir Maps', type: ToastType.error);
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
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: colors.primary,
                    ),
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text('Ruta del ${widget.date}'),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    switch (_provider.status) {
      case RouteDetailStatus.idle:
      case RouteDetailStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case RouteDetailStatus.error:
        return RouteErrorView(
          message: _provider.errorMessage,
          onRetry: () => _provider.load(widget.date),
        );
      case RouteDetailStatus.success:
        final route = _provider.route;
        if (route == null) {
          return RouteGenerateView(
            date: widget.date,
            canGenerateToday: _provider.canGenerateRoute,
            isBusy:
                _requestingGps ||
                _provider.generateStatus == GenerateRouteStatus.generating,
            onUseCurrentLocation: _onUseCurrentLocation,
            onPickOnMap: _onPickOnMap,
          );
        }
        switch (route.status) {
          case RouteExecutionStatus.draft:
            return RouteDraftView(
              route: route,
              canStartToday: _provider.canStartRoute,
              isStarting:
                  _provider.stopActionStatus == StopActionStatus.working,
              onStopTap: _onStopTap,
              onStartRoute: _onStartRoute,
            );
          case RouteExecutionStatus.active:
            if (_gpsDenied) {
              return RouteGpsDeniedView(
                onRetryGps: _retryBroadcast,
                onPickOnMap: _broadcastFromMap,
              );
            }
            if (!_hasSelfLocation) {
              if (!_broadcastAttempted) {
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _autoStartBroadcast(),
                );
              }
              return const RouteObtainingLocationView();
            }
            return RouteActiveView(
              route: route,
              selfLat: _selfLat!,
              selfLng: _selfLng!,
              socketConnected: _socketConnected,
              busy: _provider.stopActionStatus == StopActionStatus.working,
              onCall: (stop) => _callCitizen(stop.citizenPhone!),
              onOpenMaps: (stop) => _openMaps(stop.latitude, stop.longitude),
              onComplete: _onCompleteStop,
              onPostpone: _onPostponeStop,
            );
          case RouteExecutionStatus.completed:
            return RouteCompletedView(
              onViewSummary: () => context.push(
                '/route-summary',
                extra: {'routeId': route.routeId},
              ),
            );
        }
    }
  }
}
