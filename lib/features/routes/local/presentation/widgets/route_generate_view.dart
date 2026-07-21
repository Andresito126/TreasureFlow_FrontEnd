import 'package:flutter/material.dart';
import 'package:treasureflow/features/routes/local/presentation/utils/route_map_utils.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class RouteGenerateView extends StatelessWidget {
  final String date;
  final bool canGenerateToday;
  final bool isBusy;
  final VoidCallback onUseCurrentLocation;
  final VoidCallback onPickOnMap;

  const RouteGenerateView({
    super.key,
    required this.date,
    required this.canGenerateToday,
    required this.isBusy,
    required this.onUseCurrentLocation,
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
                  canGenerateToday
                      ? 'Indica desde dónde saldrá el conductor para calcular el orden óptimo de las paradas.'
                      : 'Solo puedes generar esta ruta el día ${RouteMapUtils.formatIsoDateForDisplay(date)}.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          if (canGenerateToday) ...[
            const SizedBox(height: 20),
            PrimaryButtonGreenWidget(
              text: 'Usar mi ubicación',
              isLoading: isBusy,
              onPressed: onUseCurrentLocation,
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: isBusy ? null : onPickOnMap,
              icon: const Icon(Icons.map_outlined, size: 18),
              label: const Text('Elegir ubicación en el mapa'),
            ),
          ],
        ],
      ),
    );
  }
}
