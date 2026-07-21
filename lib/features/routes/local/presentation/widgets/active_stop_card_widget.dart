import 'package:flutter/material.dart';

class ActiveStopCardWidget extends StatelessWidget {
  final int order;
  final String citizenName;
  final String addressLabel;
  final String? etaLabel;
  final bool hasPhone;
  final bool isArrived;
  final bool paymentCompleted;
  final bool hasSale;
  final bool busy;
  final VoidCallback? onCall;
  final VoidCallback onOpenMaps;
  final VoidCallback onArrive;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;
  final VoidCallback? onViewSale;

  const ActiveStopCardWidget({
    super.key,
    required this.order,
    required this.citizenName,
    required this.addressLabel,
    required this.hasPhone,
    required this.isArrived,
    required this.paymentCompleted,
    required this.hasSale,
    required this.busy,
    required this.onOpenMaps,
    required this.onArrive,
    required this.onComplete,
    required this.onPostpone,
    this.etaLabel,
    this.onCall,
    this.onViewSale,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                ),
                child: Text(
                  '$order',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      citizenName,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addressLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        color: colors.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (etaLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  etaLabel!,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ],
          ),
          if (isArrived) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(100),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 13,
                        color: colors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'En el domicilio',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: colors.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!paymentCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: colors.tertiary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 13,
                          color: colors.tertiary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Pendiente de pago',
                          style: textTheme.bodySmall?.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: colors.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (busy || !hasPhone) ? null : onCall,
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Llamar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: isArrived
                    ? OutlinedButton.icon(
                        onPressed: busy ? null : onPostpone,
                        icon: const Icon(Icons.schedule_rounded, size: 16),
                        label: const Text('Posponer'),
                      )
                    : OutlinedButton.icon(
                        onPressed: busy ? null : onOpenMaps,
                        icon: const Icon(Icons.navigation_outlined, size: 16),
                        label: const Text('Maps'),
                      ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isArrived)
            SizedBox(
              width: double.infinity,
              child: paymentCompleted
                  ? FilledButton.icon(
                      onPressed: busy ? null : onComplete,
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Completar'),
                    )
                  : OutlinedButton.icon(
                      onPressed: (busy || !hasSale) ? null : onViewSale,
                      icon: const Icon(Icons.point_of_sale_rounded, size: 16),
                      label: const Text('Ver venta'),
                    ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: busy ? null : onPostpone,
                    icon: const Icon(Icons.schedule_rounded, size: 16),
                    label: const Text('Posponer'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: busy ? null : onArrive,
                    icon: const Icon(Icons.pin_drop_rounded, size: 16),
                    label: const Text('Llegué'),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
