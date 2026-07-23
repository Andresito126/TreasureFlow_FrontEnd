import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/maps/presentation/providers/map_provider.dart';

class LocationPickerResult {
  final LatLng latLng;
  final String address;

  const LocationPickerResult({required this.latLng, required this.address});
}

class LocationPickerScreen extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerScreen({super.key, this.initialLocation});

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  GoogleMapController? _mapController;
  final _searchController = TextEditingController();
  bool _showSuggestions = false;
  List suggestions = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MapProvider>();
      if (widget.initialLocation != null) {
        // ya tiene ubicación previa, solo centra
        _mapController?.animateCamera(
          CameraUpdate.newLatLng(widget.initialLocation!),
        );
      } else {
        await provider.initializeLocation();
        if (mounted && provider.pinLocation != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(provider.pinLocation!),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String input) async {
    if (input.trim().isEmpty) {
      setState(() {
        suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    final provider = context.read<MapProvider>();
    final results = await provider.fetchSuggestions(input, 'es');
    if (mounted) {
      setState(() {
        suggestions = results;
        _showSuggestions = results.isNotEmpty;
      });
    }
  }

  Future<void> _onSuggestionTap(dynamic suggestion) async {
    final provider = context.read<MapProvider>();
    final place = await provider.selectSuggestion(suggestion.placeId);
    _searchController.clear();
    setState(() {
      suggestions = [];
      _showSuggestions = false;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(place.latitude, place.longitude), 16),
    );
  }

  void _confirm() {
    final provider = context.read<MapProvider>();
    final place = provider.currentPlace;
    final pin = provider.pinLocation;

    if (pin == null) return;

    final address = place != null
        ? '${place.street} ${place.streetNumber}, ${place.city}'.trim()
        : '${pin.latitude.toStringAsFixed(5)}, ${pin.longitude.toStringAsFixed(5)}';

    Navigator.of(context).pop(
      LocationPickerResult(latLng: pin, address: address),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          // ── Mapa ──────────────────────────────────────────────────────────
          Consumer<MapProvider>(
            builder: (context, provider, _) {
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.initialLocation ?? provider.initialTarget,
                  zoom: 15,
                ),
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                onCameraMove: (pos) => provider.onCameraMove(pos.target),
                onCameraIdle: provider.onCameraIdle,
              );
            },
          ),

          // ── Pin fijo en el centro ──────────────────────────────────────────
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on, size: 40, color: colors.primary),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // ── Barra de búsqueda + resultados ────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            right: 12,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: 'Buscar dirección…',
                            hintStyle: textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.4),
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            setState(() {
                              suggestions = [];
                              _showSuggestions = false;
                            });
                          },
                        ),
                    ],
                  ),
                ),

                if (_showSuggestions)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    decoration: BoxDecoration(
                      color: colors.surface,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: suggestions.length,
                      separatorBuilder: (_, _) => Divider(
                        height: 1,
                        color: colors.outline.withValues(alpha: 0.2),
                      ),
                      itemBuilder: (context, i) {
                        final s = suggestions[i];
                        return ListTile(
                          dense: true,
                          leading: Icon(Icons.place_outlined, size: 18, color: colors.primary),
                          title: Text(
                            s.mainText,
                            style: textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            s.secondaryText,
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 11,
                              color: colors.onSurface.withValues(alpha: 0.5),
                            ),
                          ),
                          onTap: () => _onSuggestionTap(s),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // ── Botón mi ubicación ────────────────────────────────────────────
          Positioned(
            right: 12,
            bottom: 120,
            child: FloatingActionButton.small(
              heroTag: 'myLocation',
              backgroundColor: colors.surface,
              onPressed: () async {
                final provider = context.read<MapProvider>();
                await provider.goToCurrentLocation();
                if (mounted && provider.pinLocation != null) {
                  _mapController?.animateCamera(
                    CameraUpdate.newLatLng(provider.pinLocation!),
                  );
                }
              },
              child: Icon(Icons.my_location, color: colors.primary, size: 20),
            ),
          ),

          // ── Dirección detectada + botón confirmar ──────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Consumer<MapProvider>(
              builder: (context, provider, _) {
                final place = provider.currentPlace;
                final address = place != null
                    ? '${place.street} ${place.streetNumber}, ${place.city}'.trim()
                    : null;
                final isLoading = provider.isLoadingAddress || provider.isLoadingLocation;

                return Container(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    MediaQuery.of(context).padding.bottom + 16,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 16, color: colors.primary),
                          const SizedBox(width: 6),
                          Expanded(
                            child: isLoading
                                ? Text(
                                    'Obteniendo dirección…',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.onSurface.withValues(alpha: 0.4),
                                    ),
                                  )
                                : Text(
                                    address ?? 'Mueve el mapa para seleccionar',
                                    style: textTheme.bodySmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isLoading ? null : _confirm,
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            'Usar esta ubicación',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colors.onPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
