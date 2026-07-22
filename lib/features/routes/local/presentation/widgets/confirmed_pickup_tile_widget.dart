import 'package:flutter/material.dart';

class ConfirmedPickupTileWidget extends StatelessWidget {
  final String citizenName;
  final String addressLabel;
  final VoidCallback onTap;

  const ConfirmedPickupTileWidget({
    super.key,
    required this.citizenName,
    required this.addressLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.onSurface.withValues(alpha: 0.12)),
        ),
        child: Row(
          children: [
            Icon(Icons.recycling_rounded, size: 20, color: colors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    citizenName,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    addressLabel,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colors.onSurface.withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.chevron_right_rounded,
              size: 18,
              color: colors.onSurface.withValues(alpha: 0.4),
            ),
          ],
        ),
      ),
    );
  }
}
