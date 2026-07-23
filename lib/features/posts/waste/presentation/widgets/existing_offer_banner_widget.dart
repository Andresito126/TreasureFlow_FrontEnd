import 'package:flutter/material.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/my_offer.dart';

class ExistingOfferBanner extends StatelessWidget {
  final MyOffer offer;
  const ExistingOfferBanner({super.key, required this.offer});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isAccepted = offer.status == 'accepted';
    final color = isAccepted ? Colors.green : colors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isAccepted ? Icons.check_circle_outline : Icons.local_offer_outlined,
            size: 20,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isAccepted ? 'Tu oferta fue aceptada' : 'Ya enviaste una oferta',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${offer.pricePerUnit.toStringAsFixed(2)} / ${offer.unit}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                if (offer.pickupLabel.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    offer.pickupLabel,
                    style: textTheme.bodySmall?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w500,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
