import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';
import 'address_card_widget.dart';
import 'place_search_field.dart';

class TreasureMapWidget extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const TreasureMapWidget({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<TreasureMapWidget> createState() => _TreasureMapWidgetState();
}

class _TreasureMapWidgetState extends State<TreasureMapWidget> {
  GoogleMapController? _mapController;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MapProvider>().initializeLocation();
    });
  }

  Future<void> _goToCurrentLocation(MapProvider provider) async {
    await provider.goToCurrentLocation();
    if (provider.pinLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: provider.pinLocation!, zoom: 17),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Consumer<MapProvider>(
      builder: (context, provider, _) {
        if (provider.isLoadingLocation) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.status == MapStatus.error) {
          return Center(child: Text(provider.error ?? 'Error de ubicación'));
        }

        return Scaffold(
          resizeToAvoidBottomInset: false,
          body: Stack(
            children: [
              // ── 1. Mapa ───────────────────────────────────────────────
              GoogleMap(
                // mapId: '',
                onMapCreated: (c) => _mapController = c,
                initialCameraPosition: CameraPosition(
                  target: provider.initialTarget,
                  zoom: 15,
                ),
                onCameraMove: (pos) => provider.onCameraMove(pos.target),
                onCameraIdle: provider.onCameraIdle,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                scrollGesturesEnabled: provider.isEditing,
                zoomGesturesEnabled: provider.isEditing,
                rotateGesturesEnabled: provider.isEditing,
                tiltGesturesEnabled: provider.isEditing,
              ),

              // ── 2. Pin fijo en el centro ──────────────────────────────
              const IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 35),
                    child: Icon(
                      Icons.location_on,
                      size: 50,
                      color: Color(0xFF418839),
                    ),
                  ),
                ),
              ),

              // ── 3. Buscador (solo en modo edición) ────────────────────
              if (provider.isEditing)
                Positioned(
                  top: 12,
                  left: 12,
                  right: 12,
                  child: PlaceSearchField(
                    provider: provider,
                    // Oculta card y FAB mientras el teclado está abierto
                    onFocusChanged: (hasFocus) =>
                        setState(() => _isSearching = hasFocus),
                    onSuggestionSelected: (placeId) async {
                      final result = await provider.selectSuggestion(placeId);
                      _mapController?.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(result.latitude, result.longitude),
                            zoom: 17,
                          ),
                        ),
                      );
                    },
                  ),
                ),

              // ── 4. Botón "mi ubicación" — se oculta al buscar ─────────
              if (!_isSearching)
                Positioned(
                  bottom: 260,
                  right: 12,
                  child: FloatingActionButton.small(
                    heroTag: 'myLocation',
                    backgroundColor: colors.surface, // backgroundBoxLight/Dark
                    foregroundColor:
                        colors.onSurface, // negro/blanco según modo
                    onPressed: () => _goToCurrentLocation(provider),
                    child: const Icon(Icons.my_location),
                  ),
                ),

              // ── 5. AddressCard — se oculta al buscar ──────────────────
              if (!_isSearching)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AddressCard(
                    place: provider.currentPlace,
                    isEditing: provider.isEditing,
                    loadingAddress: provider.isLoadingAddress,
                    onEdit: provider.enterEditMode,
                    onBack: provider.isEditing
                        ? provider.exitEditMode
                        : widget.onBack,
                    onNext: widget.onNext,
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
