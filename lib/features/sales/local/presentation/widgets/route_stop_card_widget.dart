import 'package:flutter/material.dart';
import 'package:treasureflow/features/sales/local/presentation/models/purchase_ui_model.dart';

/// Card de una parada dentro de la ruta de recolección.
class RouteStopCardWidget extends StatelessWidget {
  final PurchaseUiModel purchase;
  final int order;
  final VoidCallback onTap;
  final VoidCallback? onRemove;
  final VoidCallback? onAdd;

  /// true cuando la parada forma parte de la ruta (muestra su número de orden).
  final bool inRoute;

  const RouteStopCardWidget({
    super.key,
    required this.purchase,
    required this.order,
    required this.onTap,
    this.onRemove,
    this.onAdd,
    this.inRoute = false,
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
          border: Border.all(
            color: inRoute
                ? colors.primary.withValues(alpha: 0.35)
                : colors.outline.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: inRoute
                    ? colors.primary
                    : colors.outline.withValues(alpha: 0.15),
              ),
              child: inRoute
                  ? Text(
                      '$order',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colors.onPrimary,
                      ),
                    )
                  : Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.wasteTitle,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    purchase.addressText,
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
            const SizedBox(width: 8),
            Text(
              '\$${purchase.estimatedAmount.toStringAsFixed(0)}',
              style: textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
            const SizedBox(width: 4),
            if (onRemove != null)
              IconButton(
                onPressed: onRemove,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.close_rounded,
                    size: 18, color: colors.error),
              )
            else if (onAdd != null)
              IconButton(
                onPressed: onAdd,
                visualDensity: VisualDensity.compact,
                icon: Icon(Icons.add_circle_outline_rounded,
                    size: 20, color: colors.primary),
              ),
          ],
        ),
      ),
    );
  }
}
