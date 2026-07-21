import 'package:flutter/material.dart';
import 'package:treasureflow/features/routes/local/domain/entities/route_status.dart';

class FinishedStopTileWidget extends StatelessWidget {
  final String citizenName;
  final StopStatus status;

  const FinishedStopTileWidget({
    super.key,
    required this.citizenName,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final (label, color, icon) = switch (status) {
      StopStatus.completed => (
        'Completada',
        colors.primary,
        Icons.check_circle_outline_rounded,
      ),
      StopStatus.postponed => (
        'Pospuesta',
        colors.tertiary,
        Icons.schedule_rounded,
      ),
      StopStatus.cancelled => (
        'Cancelada',
        colors.error,
        Icons.cancel_outlined,
      ),

      StopStatus.pending => (
        'Pendiente',
        colors.primary,
        Icons.circle_outlined,
      ),
      StopStatus.inProgress => (
        'En el domicilio',
        colors.primary,
        Icons.location_on_rounded,
      ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.onSurface.withValues(alpha: 0.12)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              citizenName,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
