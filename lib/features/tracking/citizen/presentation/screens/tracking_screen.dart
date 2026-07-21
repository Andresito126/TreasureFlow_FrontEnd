import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/core/maps/utils/marker_icon_factory.dart';
import 'package:treasureflow/core/notifications/domain/entities/notification_payload.dart';
import 'package:treasureflow/features/tracking/citizen/di/tracking_module.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/providers/citizen_tracking_provider.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/widgets/tracking_map_view.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/widgets/tracking_message_view.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/widgets/tracking_status_bar_widget.dart';

class TrackingScreen extends StatefulWidget {
  final Object? extra;

  const TrackingScreen({super.key, this.extra});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  late final CitizenTrackingProvider _provider;
  StreamSubscription<RemoteMessage>? _fcmSub;
  GoogleMapController? _mapController;
  BitmapDescriptor? _truckIcon;
  bool _truckIconRequested = false;
  String? _routeId;
  late String _etaText;

  @override
  void initState() {
    super.initState();
    _routeId = _extractRouteId(widget.extra);
    final payload = widget.extra;
    _etaText = (payload is NotificationPayload && payload.body.isNotEmpty)
        ? payload.body
        : 'El recolector va en camino.';

    final container = context.read<AppContainer>();
    _provider = TrackingModule(container).provideCitizenTrackingProvider();
    _provider.addListener(_onProviderChanged);

    final id = _routeId;
    if (id != null) _provider.connect(id);

    _listenForegroundMessages();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_truckIconRequested) return;
    _truckIconRequested = true;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    MarkerIconFactory.vehicle(
      devicePixelRatio: dpr,
      background: const Color(0xFF2E7D32),
    ).then((icon) {
      if (mounted) setState(() => _truckIcon = icon);
    });
  }

  @override
  void dispose() {
    _fcmSub?.cancel();
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;

    if (_provider.hasTruck && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(_provider.truckLat!, _provider.truckLng!),
        ),
      );
    }
    setState(() {});
  }

  void _listenForegroundMessages() {
    _fcmSub = FirebaseMessaging.onMessage.listen((message) {
      if (message.data.isEmpty) return;
      final payload = NotificationPayload.fromMap(message.data);
      final sameRoute = payload.metadata['routeId']?.toString() == _routeId;
      if (!sameRoute) return;

      if (payload.type == 'DRIVER_APPROACHING' && payload.body.isNotEmpty) {
        setState(() => _etaText = payload.body);
      } else if (payload.type == 'PICKUP_POSTPONED') {
        _showPostponedAndClose(payload);
      }
    });
  }

  Future<void> _showPostponedAndClose(NotificationPayload payload) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          payload.title.isNotEmpty ? payload.title : 'Recolección pospuesta',
        ),
        content: Text(
          payload.body.isNotEmpty
              ? payload.body
              : 'Tu recolección fue pospuesta.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.of(context).maybePop();
  }

  String? _extractRouteId(Object? extra) {
    if (extra is NotificationPayload) {
      return extra.metadata['routeId']?.toString();
    }
    if (extra is Map && extra['routeId'] != null) {
      return extra['routeId'].toString();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const Text('Seguimiento en vivo'),
      ),
      body: SafeArea(
        child: _routeId == null
            ? const TrackingMessageView(text: 'No se pudo identificar la ruta.')
            : _content(),
      ),
    );
  }

  Widget _content() {
    return Column(
      children: [
        Expanded(
          child: TrackingMapView(
            truckLat: _provider.truckLat,
            truckLng: _provider.truckLng,
            selfLat: _provider.selfLat,
            selfLng: _provider.selfLng,
            truckIcon: _truckIcon,
            onMapCreated: (controller) => _mapController = controller,
          ),
        ),
        TrackingStatusBarWidget(
          status: _provider.status,
          hasTruck: _provider.hasTruck,
          etaText: _etaText,
          errorMessage: _provider.errorMessage,
        ),
      ],
    );
  }
}
