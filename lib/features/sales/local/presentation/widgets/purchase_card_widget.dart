import 'package:flutter/material.dart';
import 'package:treasureflow/features/sales/local/presentation/models/purchase_ui_model.dart';
import 'package:treasureflow/features/sales/local/presentation/ui_states/purchase_status.dart';

/// Card de una compra apartada en la lista "Mis compras" del establecimiento.
class PurchaseCardWidget extends StatelessWidget {
  final PurchaseUiModel purchase;
  final VoidCallback onTap;

  /// Acción para reprogramar la entrega a otra fecha (opcional).
  final VoidCallback? onMoveDate;

  const PurchaseCardWidget({
    super.key,
    required this.purchase,
    required this.onTap,
    this.onMoveDate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final amount = purchase.finalAmount ?? purchase.estimatedAmount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    purchase.wasteTitle,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Text(
                    purchase.status.label,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.person_outline_rounded,
                    size: 14, color: colors.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    purchase.citizenName,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: colors.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    purchase.addressText,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${purchase.materialTypeName} · ${purchase.estimatedQuantity.toStringAsFixed(0)} ${purchase.unit} aprox.',
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
                Text(
                  '\$${amount.toStringAsFixed(2)}',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            if (onMoveDate != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: onMoveDate,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: Icon(Icons.edit_calendar_outlined,
                      size: 15, color: colors.primary),
                  label: Text(
                    'Mover fecha',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: colors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
