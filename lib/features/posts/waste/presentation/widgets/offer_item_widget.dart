import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/premium_badge_widget.dart';

class OfferItemWidget extends StatelessWidget {
  final String name;
  final bool isPremium;
  final String pricePerUnit;
  final String pickupLabel;
  final String status;
  final bool isAccepting;
  final bool isRejecting;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const OfferItemWidget({
    super.key,
    required this.name,
    this.isPremium = false,
    required this.pricePerUnit,
    required this.status,
    this.pickupLabel = '',
    this.isAccepting = false,
    this.isRejecting = false,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isPremium) ...[
                      const SizedBox(width: 6),
                      const PremiumBadgeWidget(),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  pricePerUnit,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
                if (pickupLabel.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today_outlined,
                          size: 12, color: colors.primary),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          pickupLabel,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 12),
          _buildAction(colors, textTheme),
        ],
      ),
    );
  }

  Widget _buildAction(ColorScheme colors, TextTheme textTheme) {
    if (status == 'accepted') {
      return _statusBadge('Aceptada', const Color(0xFF2D7D46), textTheme);
    }
    if (status == 'rejected') {
      return _statusBadge('Rechazada', colors.error, textTheme);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isAccepting)
          _actionSpinner(colors.primary)
        else
          GestureDetector(
            onTap: onAccept,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Aceptar',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
        if (isRejecting)
          _actionSpinner(colors.error)
        else
          GestureDetector(
            onTap: onReject,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: colors.error.withValues(alpha: 0.5)),
              ),
              child: Text(
                'Rechazar',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.error,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _actionSpinner(Color color) {
    return SizedBox(
      width: 70,
      height: 30,
      child: Center(
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
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
