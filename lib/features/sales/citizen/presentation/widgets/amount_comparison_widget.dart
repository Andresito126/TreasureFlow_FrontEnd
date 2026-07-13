import 'package:flutter/material.dart';


class AmountComparisonWidget extends StatelessWidget {
  final double estimatedAmount;
  final double finalAmount;

  const AmountComparisonWidget({
    super.key,
    required this.estimatedAmount,
    required this.finalAmount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final difference = finalAmount - estimatedAmount;
    final inFavor = difference >= 0;
    final diffColor = inFavor ? colors.primary : const Color(0xFFE8A13D);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _amountBox(
                context,
                label: 'Oferta inicial',
                amount: estimatedAmount,
                highlighted: false,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
            ),
            Expanded(
              child: _amountBox(
                context,
                label: 'Monto final',
                amount: finalAmount,
                highlighted: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: diffColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                inFavor ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                size: 14,
                color: diffColor,
              ),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  inFavor
                      ? '+\$${difference.toStringAsFixed(2)} a tu favor'
                      : '-\$${difference.abs().toStringAsFixed(2)} del estimado',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: diffColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _amountBox(
    BuildContext context, {
    required String label,
    required double amount,
    required bool highlighted,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: highlighted
            ? colors.primary.withValues(alpha: 0.08)
            : colors.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: highlighted ? colors.primary : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: highlighted
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              '\$${amount.toStringAsFixed(2)}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: highlighted
                    ? colors.primary
                    : colors.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
