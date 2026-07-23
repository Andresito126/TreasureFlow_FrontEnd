import 'package:flutter/material.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class RouteGpsDeniedView extends StatelessWidget {
  final VoidCallback onRetryGps;
  final VoidCallback onPickOnMap;

  const RouteGpsDeniedView({
    super.key,
    required this.onRetryGps,
    required this.onPickOnMap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

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
                    Icon(
                      Icons.location_off_rounded,
                      size: 18,
                      color: colors.error,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No pudimos acceder a tu ubicación',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Para que los ciudadanos vean por dónde vas, activa el permiso de ubicación. Si no puedes, elige tu punto en el mapa.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButtonGreenWidget(
            text: 'Reintentar con GPS',
            onPressed: onRetryGps,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: onPickOnMap,
            icon: const Icon(Icons.map_outlined, size: 18),
            label: const Text('Elegir mi ubicación en el mapa'),
          ),
        ],
      ),
    );
  }
}
