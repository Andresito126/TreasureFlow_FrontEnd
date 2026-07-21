import 'package:flutter/material.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class RouteCompletedView extends StatelessWidget {
  final bool abandoned;
  final VoidCallback onViewSummary;

  const RouteCompletedView({
    super.key,
    required this.onViewSummary,
    this.abandoned = false,
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
                      abandoned
                          ? Icons.warning_amber_rounded
                          : Icons.check_circle_rounded,
                      size: 20,
                      color: abandoned ? colors.tertiary : colors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        abandoned
                            ? 'Recorrido cerrado automáticamente'
                            : 'Recorrido completado',
                        style: textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  abandoned
                      ? 'No hubo señal del conductor por un tiempo prolongado. Las paradas que quedaron pendientes ya se reprogramaron automáticamente para el siguiente día laboral.'
                      : 'Este recorrido ya finalizó. Consulta el resumen para ver el detalle de las paradas.',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          PrimaryButtonGreenWidget(
            text: 'Ver resumen',
            onPressed: onViewSummary,
          ),
        ],
      ),
    );
  }
}
