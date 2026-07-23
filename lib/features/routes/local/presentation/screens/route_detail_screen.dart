import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/maps/presentation/screens/location_picker_screen.dart';
import 'package:treasureflow/features/routes/local/di/routes_module.dart';
import 'package:treasureflow/features/routes/local/domain/entities/confirmed_pickup.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_status.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route.dart';
import 'package:treasureflow/features/routes/local/domain/entities/today_route_stop.dart';
import 'package:treasureflow/features/routes/local/presentation/providers/route_broadcast_provider.dart';
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

/// Pantalla de detalle de una ruta. Orquesta dos providers — [RouteDetailProvider]
/// (datos de la ruta y acciones) y [RouteBroadcastProvider] (transmisión de
/// ubicación en un recorrido activo) — y solo conserva aquí lo que
/// genuinamente requiere `BuildContext` (navegación, bottom sheets, date
/// pickers, deep links). Toda decisión de negocio (fechas permitidas, estado
/// del GPS/socket) vive en los providers y se expone como enums; el pintado
/// de cada estado vive en los widgets `Route*View`.
class RouteDetailScreen extends StatefulWidget {
  final String date;

  const RouteDetailScreen({super.key, required this.date});

  @override
  State<RouteDetailScreen> createState() => _RouteDetailScreenState();
}

class _RouteDetailScreenState extends State<RouteDetailScreen> {
  late final RouteDetailProvider _provider;
  late final RouteBroadcastProvider _broadcast;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    final module = RoutesModule(container);

    _provider = module.provideRouteDetailProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load(widget.date);

    _broadcast = module.provideRouteBroadcastProvider();
    _broadcast.addListener(_onBroadcastChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _broadcast.removeListener(_onBroadcastChanged);
    _broadcast.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
// Si la ruta dejó de estar activa (p. ej. se completó la última parada),
// detenemos la transmisión de ubicación.
    if (_provider.route?.status != RouteExecutionStatus.active &&
        _broadcast.status != BroadcastStatus.idle) {
      _broadcast.stop();
    }
    if (mounted) setState(() {});
  }

  void _onBroadcastChanged() {
// El heartbeat recibió 404: la ruta ya no es `active` del lado del
// servidor (se completó desde otro dispositivo, o el barredor la cerró
// por abandono). Refrescamos para mostrar su estado real.
    if (_broadcast.status == BroadcastStatus.routeClosed) {
      _provider.load(widget.date);
    }
    if (mounted) setState(() {});
  }

// ── Generación de ruta (estado draft inexistente) ─────────────────────────
// La resolución de GPS y la validación de fecha viven en RouteDetailProvider;
// aquí solo se reacciona al resultado y se abre el picker de mapa (requiere
// context).

  Future<void> _onUseCurrentLocation() async {
    final ok = await _provider.generateFromCurrentLocation();
    if (!mounted) return;
    _showGenerateResultToast(ok);
  }

  Future<void> _onPickOnMap() async {
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result == null || !mounted) return;
    final ok = await _provider.generateRoute(
      driverLat: result.latLng.latitude,
      driverLng: result.latLng.longitude,
    );
    if (!mounted) return;
    _showGenerateResultToast(ok);
  }

  void _showGenerateResultToast(bool ok) {
    AppToast.show(
      context,
      ok ? 'Ruta generada' : (_provider.generateError ?? 'No se pudo generar la ruta'),
      type: ok ? ToastType.success : ToastType.error,
    );
  }

// ── Recorrido activo: fallback de ubicación en el mapa ────────────────────
// (requiere Navigator; el resto de la transmisión vive en RouteBroadcastProvider)

  Future<void> _broadcastFromMap() async {
    final route = _provider.route;
    if (route == null) return;
    final result = await Navigator.of(context).push<LocationPickerResult>(
      MaterialPageRoute(builder: (_) => const LocationPickerScreen()),
    );
    if (result == null || !mounted) return;
    await _broadcast.startFromFixedPoint(
      route.routeId,
      result.latLng.latitude,
      result.latLng.longitude,
    );
  }

// ── Acciones sobre paradas ─────────────────────────────────────────────────

  Future<void> _onStartRoute() async {
    final ok = await _provider.startRoute();
    if (!mounted) return;
    AppToast.show(
      context,
      ok ? 'Recorrido iniciado' : (_provider.stopActionError ?? 'No se pudo iniciar'),
      type: ok ? ToastType.success : ToastType.error,
    );
  }

  Future<void> _onArriveStop(TodayRouteStop stop) async {
    final ok = await _provider.arriveAtStop(stop.stopId);
    if (!mounted) return;
    AppToast.show(
      context,
      ok ? 'Llegada confirmada' : (_provider.stopActionError ?? 'No se pudo confirmar'),
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
    final ok = await _provider.postponeStop(stop.stopId, newDate, result.reason);
    if (!mounted) return;
    AppToast.show(
      context,
      ok
          ? 'Parada pospuesta'
          : (_provider.stopActionError ?? 'No se pudo posponer'),
      type: ok ? ToastType.success : ToastType.error,
    );
  }

  void _onViewSale(TodayRouteStop stop) {
    final collectionId = stop.collectionId;
    if (collectionId == null) return;
    context.push('/purchaseDetail/$collectionId');
  }

  Future<void> _callCitizen(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(uri) && mounted) {
      AppToast.show(context, 'No se pudo abrir el teléfono', type: ToastType.error);
    }
  }

  Future<void> _openMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      AppToast.show(context, 'No se pudo abrir Maps', type: ToastType.error);
    }
  }

// ── Reagendado (permitido cualquier día, no solo hoy) ─────────────────────

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

// ── Recolecciones confirmadas sin ruta aún (cualquier día) ────────────────

  Future<void> _onPickupTap(ConfirmedPickup pickup) async {
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
                pickup.citizenName,
                style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              if (pickup.addressText != null)
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pickup.addressText!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  ],
                ),
              if (pickup.citizenPhone != null) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.phone_outlined, size: 16, color: colors.primary),
                    const SizedBox(width: 6),
                    Text(
                      pickup.citizenPhone!,
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
                  _onReschedulePickupTap(pickup);
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

  Future<void> _onReschedulePickupTap(ConfirmedPickup pickup) async {
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
      pickupId: pickup.scheduledPickupId,
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

// ── Build ───────────────────────────────────────────────────────────────

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
            isBusy: _provider.generateStatus == GenerateRouteStatus.resolvingLocation ||
                _provider.generateStatus == GenerateRouteStatus.generating,
            pickups: _provider.confirmedPickups,
            onPickupTap: _onPickupTap,
            onUseCurrentLocation: _onUseCurrentLocation,
            onPickOnMap: _onPickOnMap,
          );
        }
        switch (route.status) {
          case RouteExecutionStatus.draft:
            return RouteDraftView(
              route: route,
              canStartToday: _provider.canStartRoute,
              isStarting: _provider.stopActionStatus == StopActionStatus.working,
              onStopTap: _onStopTap,
              onStartRoute: _onStartRoute,
            );
          case RouteExecutionStatus.active:
            return _buildActiveBody(route);
          case RouteExecutionStatus.completed:
          case RouteExecutionStatus.abandoned:
            return RouteCompletedView(
              abandoned: route.status == RouteExecutionStatus.abandoned,
              onViewSummary: () => context.push(
                '/route-summary',
                extra: {'routeId': route.routeId},
              ),
            );
        }
    }
  }

  Widget _buildActiveBody(TodayRoute route) {
    switch (_broadcast.status) {
      case BroadcastStatus.permissionDenied:
        return RouteGpsDeniedView(
          onRetryGps: () => _broadcast.retryGps(),
          onPickOnMap: _broadcastFromMap,
        );
      case BroadcastStatus.idle:
// Arranca el GPS en vivo automáticamente la primera vez que se entra
// a esta ruta activa (nunca recuerda la elección entre visitas: este
// provider se crea fresco cada vez que se abre la pantalla).
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _broadcast.startFromGps(route.routeId),
        );
        return const RouteObtainingLocationView();
      case BroadcastStatus.resolvingLocation:
        return const RouteObtainingLocationView();
      case BroadcastStatus.routeClosed:
// Transitorio: _onBroadcastChanged ya disparó _provider.load(), que
// en un instante mostrará el estado real (completed/abandoned).
        return const Center(child: CircularProgressIndicator());
      case BroadcastStatus.broadcasting:
        return RouteActiveView(
          route: route,
          selfLat: _broadcast.selfLat!,
          selfLng: _broadcast.selfLng!,
          busy: _provider.stopActionStatus == StopActionStatus.working,
          onCall: (stop) => _callCitizen(stop.citizenPhone!),
          onOpenMaps: (stop) => _openMaps(stop.latitude, stop.longitude),
          onArrive: _onArriveStop,
          onComplete: _onCompleteStop,
          onPostpone: _onPostponeStop,
          onViewSale: _onViewSale,
        );
    }
  }
}
