import 'package:flutter/material.dart';

class DeliveryModeBanner extends StatelessWidget {
  final String deliveryMode;
  const DeliveryModeBanner({super.key, required this.deliveryMode});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final (icon, label, color) = switch (deliveryMode) {
      'home_delivery' => (
        Icons.local_shipping_outlined,
        'Disponible para recolección a domicilio',
        colors.primary,
      ),
      'drop_off' => (
        Icons.storefront_outlined,
        'Debes llevarlo a un punto de acopio',
        const Color(0xFF30A3F3),
      ),
      _ => (
        Icons.swap_horiz_rounded,
        'Recolección a domicilio o entrega en punto',
        const Color(0xFF6D53ED),
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: textTheme.bodySmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
