import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:treasureflow/features/sales/local/presentation/models/purchase_ui_model.dart';
import 'package:treasureflow/features/sales/local/presentation/ui_states/purchase_status.dart';
import 'package:treasureflow/features/sales/local/presentation/widgets/route_stop_card_widget.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

// RITA DEL DIA

class CollectionRouteScreen extends StatefulWidget {
  const CollectionRouteScreen({super.key});

  @override
  State<CollectionRouteScreen> createState() => _CollectionRouteScreenState();
}

class _CollectionRouteScreenState extends State<CollectionRouteScreen> {
  late List<PurchaseUiModel> _inRoute;
  final List<PurchaseUiModel> _removed = [];
  bool _confirmed = false;

  void _onConfirmRoute() {
    setState(() => _confirmed = true);
    AppToast.show(
      context,
      'Ruta confirmada, ¡buen viaje!',
      type: ToastType.success,
    );
  }

  @override
  void initState() {
    super.initState();
    _inRoute = mockPurchases
        .where((p) => p.isToday && p.status != PurchaseStatus.completed)
        .toList();
  }

  void _remove(PurchaseUiModel p) {
    setState(() {
      _inRoute.remove(p);
      _removed.add(p);
    });
  }

  void _add(PurchaseUiModel p) {
    setState(() {
      _removed.remove(p);
      _inRoute.add(p);
    });
  }

  Set<Marker> get _markers => {
        for (int i = 0; i < _inRoute.length; i++)
          Marker(
            markerId: MarkerId(_inRoute[i].id),
            position: LatLng(_inRoute[i].latitude, _inRoute[i].longitude),
            infoWindow: InfoWindow(
              title: 'Parada ${i + 1}',
              snippet: _inRoute[i].wasteTitle,
            ),
          ),
      };

  Set<Polyline> get _polylines => {
        if (_inRoute.length > 1)
          Polyline(
            polylineId: const PolylineId('route'),
            color: Theme.of(context).colorScheme.primary,
            width: 4,
            points: [
              for (final p in _inRoute) LatLng(p.latitude, p.longitude),
            ],
          ),
      };

  LatLng get _center {
    if (_inRoute.isEmpty) return const LatLng(16.7569, -93.1292);
    final lat =
        _inRoute.map((p) => p.latitude).reduce((a, b) => a + b) /
            _inRoute.length;
    final lng =
        _inRoute.map((p) => p.longitude).reduce((a, b) => a + b) /
            _inRoute.length;
    return LatLng(lat, lng);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(_confirmed ? 'Ruta en curso' : 'Ruta de hoy'),
      ),
      body: Column(
        children: [
          SizedBox(
            height: screenHeight * 0.35,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(target: _center, zoom: 13),
              markers: _markers,
              polylines: _polylines,
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
                      Icon(Icons.route_rounded,
                          size: 18, color: colors.primary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Paradas de la ruta (${_inRoute.length})',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        'Total ~\$${_inRoute.fold<double>(0, (sum, p) => sum + p.estimatedAmount).toStringAsFixed(0)}',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_confirmed) ...[
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 16, color: colors.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Ruta confirmada. Toca una parada para iniciar la entrega.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  if (_inRoute.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'No hay paradas en la ruta. Agrega alguna de abajo.',
                          textAlign: TextAlign.center,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      ),
                    ),
                  for (int i = 0; i < _inRoute.length; i++)
                    RouteStopCardWidget(
                      purchase: _inRoute[i],
                      order: i + 1,
                      inRoute: true,
                      onTap: () =>
                          context.push('/purchaseDetail/${_inRoute[i].id}'),
                      onRemove: _confirmed
                          ? null
                          : _inRoute.length > 1
                              ? () => _remove(_inRoute[i])
                              : () => AppToast.show(
                                    context,
                                    'La ruta debe tener al menos una parada',
                                    type: ToastType.warning,
                                  ),
                    ),
                  if (!_confirmed && _removed.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Disponibles hoy',
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Recolecciones de hoy fuera de la ruta.',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final purchase in _removed)
                      RouteStopCardWidget(
                        purchase: purchase,
                        order: 0,
                        onTap: () =>
                            context.push('/purchaseDetail/${purchase.id}'),
                        onAdd: () => _add(purchase),
                      ),
                  ],
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          if (!_confirmed)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: colors.surface,
                boxShadow: [
                  BoxShadow(
                    color: colors.shadow.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: PrimaryButtonGreenWidget(
                  text: 'Confirmar ruta',
                  onPressed: _inRoute.isEmpty
                      ? () => AppToast.show(
                            context,
                            'Agrega al menos una parada a la ruta',
                            type: ToastType.warning,
                          )
                      : _onConfirmRoute,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
