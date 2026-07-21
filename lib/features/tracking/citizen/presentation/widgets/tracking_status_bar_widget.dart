import 'package:flutter/material.dart';
import 'package:treasureflow/features/tracking/citizen/presentation/state/tracking_ui_state.dart';

class TrackingStatusBarWidget extends StatelessWidget {
  final TrackingConnStatus status;
  final bool hasTruck;
  final String etaText;
  final String? errorMessage;

  const TrackingStatusBarWidget({
    super.key,
    required this.status,
    required this.hasTruck,
    required this.etaText,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final (icon, text) = switch (status) {
      TrackingConnStatus.connected => (
        Icons.podcasts_rounded,
        hasTruck
            ? etaText
            : 'Conectado. Esperando la ubicación del recolector…',
      ),
      TrackingConnStatus.connecting => (
        Icons.sync_rounded,
        'Conectando con el recolector…',
      ),
      TrackingConnStatus.disconnected => (
        Icons.wifi_off_rounded,
        'Reconectando…',
      ),
      TrackingConnStatus.error => (
        Icons.error_outline_rounded,
        errorMessage ?? 'No se pudo seguir la ruta',
      ),
      TrackingConnStatus.idle => (Icons.hourglass_empty_rounded, 'Iniciando…'),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(color: colors.onSurface.withValues(alpha: 0.08)),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: colors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
