import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class LocationPreviewWidget extends StatelessWidget {
  final LatLng? location;
  final String? address;
  final VoidCallback? onEdit;

  const LocationPreviewWidget({
    super.key,
    this.location,
    this.address,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 160,
            width: double.infinity,
            child: location != null
                ? GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: location!,
                      zoom: 15,
                    ),
                    liteModeEnabled: true,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: false,
                    scrollGesturesEnabled: false,
                    zoomGesturesEnabled: false,
                    rotateGesturesEnabled: false,
                    tiltGesturesEnabled: false,
                    markers: {
                      Marker(
                        markerId: const MarkerId('selected'),
                        position: location!,
                      ),
                    },
                  )
                : Container(
                    color: colors.outline.withValues(alpha:0.1),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 40,
                            color: colors.onSurface.withValues(alpha:0.3),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Sin ubicación seleccionada',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withValues(alpha:0.4),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
        if (address != null && address!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: colors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  address!,
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha:0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
        if (onEdit != null) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_location_alt_outlined, size: 18),
              label: Text(
                location != null ? 'Cambiar ubicación' : 'Seleccionar ubicación',
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(color: colors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
