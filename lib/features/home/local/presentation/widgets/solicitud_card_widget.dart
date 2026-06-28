import 'package:flutter/material.dart';

class SolicitudCardWidget extends StatelessWidget {
  final String title;
  final String date;
  final String views;
  final String offersCount;
  final String address;
  final String status;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback? onTap;

  const SolicitudCardWidget({
    super.key,
    required this.title,
    required this.date,
    required this.views,
    required this.offersCount,
    required this.address,
    this.status = 'Activa',
    this.actionLabel,
    this.onAction,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.outline.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.inventory_2, size: 28, color: colors.primary.withValues(alpha: 0.4)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(
                                color: colors.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            _infoChip(Icons.calendar_today, date, textTheme, colors),
                            const SizedBox(width: 10),
                            _infoChip(Icons.visibility_outlined, views, textTheme, colors),
                            const SizedBox(width: 10),
                            _infoChip(Icons.chat_bubble_outline, offersCount, textTheme, colors),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          address,
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            color: colors.onSurface.withValues(alpha: 0.6),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (actionLabel != null)
              InkWell(
                onTap: onAction,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: colors.outline.withValues(alpha: 0.3)),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star_outline, size: 16, color: colors.primary),
                      const SizedBox(width: 6),
                      Text(
                        actionLabel!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String text, TextTheme textTheme, ColorScheme colors) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: colors.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 3),
        Text(
          text,
          style: textTheme.bodySmall?.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}
