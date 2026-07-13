import 'package:flutter/material.dart';

// el flujo de venta es  ofertaa, entrega, pesaje, pago.
class SaleStepperWidget extends StatelessWidget {
  final int currentStep; // 1..4

  const SaleStepperWidget({super.key, required this.currentStep});

  static const _labels = ['Oferta', 'Entrega', 'Pesaje', 'Pago'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.outline.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            final stepBefore = (i ~/ 2) + 1;
            final isDone = stepBefore < currentStep;
            return Expanded(
              child: Container(
                height: 2,
                margin: const EdgeInsets.only(bottom: 18),
                color: isDone
                    ? colors.primary
                    : colors.outline.withValues(alpha: 0.3),
              ),
            );
          }

          final step = (i ~/ 2) + 1;
          final isCompleted = step < currentStep;
          final isActive = step == currentStep;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted || isActive
                      ? colors.primary
                      : colors.outline.withValues(alpha: 0.15),
                ),
                alignment: Alignment.center,
                child: isCompleted
                    ? Icon(Icons.check, size: 15, color: colors.onPrimary)
                    : Text(
                        '$step',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isActive
                              ? colors.onPrimary
                              : colors.onSurface.withValues(alpha: 0.5),
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[step - 1],
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                  color: isCompleted || isActive
                      ? colors.primary
                      : colors.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
