import 'package:flutter/material.dart';

class OfferItemWidget extends StatelessWidget {
  final String name;
  final String pricePerUnit;
  final String status;
  final bool isAccepting;
  final VoidCallback? onAccept;

  const OfferItemWidget({
    super.key,
    required this.name,
    required this.pricePerUnit,
    required this.status,
    this.isAccepting = false,
    this.onAccept,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: colors.primary.withValues(alpha: 0.1),
            child: Text(
              name.substring(0, 1),
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  pricePerUnit,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildAction(context, colors, textTheme),
        ],
      ),
    );
  }

  Widget _buildAction(BuildContext context, ColorScheme colors, TextTheme textTheme) {
    if (status == 'accepted') {
      return _statusBadge('Aceptada', const Color(0xFF2D7D46), textTheme);
    }
    if (status == 'rejected') {
      return _statusBadge('Rechazada', colors.error, textTheme);
    }

    // pending
    if (isAccepting) {
      return SizedBox(
        width: 70,
        child: Center(
          child: SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: colors.primary),
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onAccept,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          'Aceptar',
          style: textTheme.bodySmall?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _statusBadge(String label, Color color, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }
}
