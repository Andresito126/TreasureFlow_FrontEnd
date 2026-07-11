import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';

enum PaymentMethod { paypal, cash, transfer }

class PaymentMethodSelectorWidget extends StatelessWidget {
  final PaymentMethod? selected;
  final ValueChanged<PaymentMethod> onChanged;

  const PaymentMethodSelectorWidget({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _methodCard(
          context,
          method: PaymentMethod.paypal,
          icon: Icons.account_balance_wallet_outlined,
          title: 'PayPal',
          subtitle: 'Recibe tu pago directo a tu cuenta',
          comingSoon: true,
        ),
        const SizedBox(height: 10),
        _methodCard(
          context,
          method: PaymentMethod.cash,
          icon: Icons.payments_outlined,
          title: 'Efectivo',
          subtitle: 'El establecimiento te paga en persona',
        ),
        const SizedBox(height: 10),
        _methodCard(
          context,
          method: PaymentMethod.transfer,
          icon: Icons.swap_horiz_rounded,
          title: 'Transferencia',
          subtitle: 'Acuerden la transferencia entre ustedes',
        ),
      ],
    );
  }

  Widget _methodCard(
    BuildContext context, {
    required PaymentMethod method,
    required IconData icon,
    required String title,
    required String subtitle,
    bool comingSoon = false,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isSelected = selected == method;

    return GestureDetector(
      onTap: () {
        if (comingSoon) {
          AppToast.show(
            context,
            'PayPal estará disponible próximamente',
            type: ToastType.info,
          );
          return;
        }
        onChanged(method);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: colors.primary),
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
                          title,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (comingSoon) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFFE8A13D,
                            ).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            'Próximamente',
                            style: textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFFC77F1A),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              size: 20,
              color: isSelected
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.3),
            ),
          ],
        ),
      ),
    );
  }
}
