import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treasureflow/features/collections/local/domain/entities/create_payment_result.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collection_detail_provider.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';

/// Voucher de pago OXXO (referencia + código de barras) o SPEI (CLABE),
/// con indicador del polling que verifica el pago contra Conekta.
class PaymentVoucherWidget extends StatelessWidget {
  final CreatePaymentResult result;
  final PaymentPollingStatus pollingStatus;
  final VoidCallback onRetry;
  final VoidCallback onCheckNow;

  const PaymentVoucherWidget({
    super.key,
    required this.result,
    required this.pollingStatus,
    required this.onRetry,
    required this.onCheckNow,
  });

  bool get _isCash => result.method == PaymentMethodType.cash;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _isCash
                        ? Icons.storefront_outlined
                        : Icons.account_balance_outlined,
                    size: 18,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isCash ? 'Paga en cualquier OXXO' : 'Transfiere por SPEI',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                _isCash
                    ? 'Muestra esta referencia en caja y paga el monto exacto.'
                    : 'Transfiere el monto exacto a esta CLABE desde tu banca.',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              if (_isCash && result.barcodeUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    width: double.infinity,
                    color: Colors.white,
                    padding: const EdgeInsets.all(10),
                    child: Image.network(
                      result.barcodeUrl!,
                      height: 70,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (result.reference != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _isCash ? 'Referencia' : 'CLABE',
                              style: textTheme.bodySmall?.copyWith(
                                fontSize: 11,
                                color: colors.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              result.reference!,
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.1,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 20),
                        onPressed: () {
                          Clipboard.setData(
                            ClipboardData(text: result.reference!),
                          );
                          AppToast.show(
                            context,
                            'Copiado al portapapeles',
                            type: ToastType.info,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Monto a pagar',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                  Text(
                    '\$${result.amount.toStringAsFixed(2)}',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              if (result.expiresAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Vence: ${_formatDate(result.expiresAt!)}',
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildPollingIndicator(context),
      ],
    );
  }

  Widget _buildPollingIndicator(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    switch (pollingStatus) {
      case PaymentPollingStatus.polling:
        return AppCardContainer(
          child: Column(
            children: [
              const SizedBox(height: 4),
              LinearProgressIndicator(
                minHeight: 3,
                color: colors.primary,
                backgroundColor: colors.primary.withValues(alpha: 0.15),
              ),
              const SizedBox(height: 12),
              Text(
                'Esperando confirmación del pago…',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'En cuanto Conekta confirme el pago, la recolección se completará automáticamente.',
                textAlign: TextAlign.center,
                style: textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  color: colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        );
      case PaymentPollingStatus.failedOrExpired:
        return Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded,
                      size: 18, color: colors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El pago fue rechazado o el voucher venció.',
                      style:
                          textTheme.bodySmall?.copyWith(color: colors.error),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Elegir otro método de pago'),
            ),
          ],
        );
      case PaymentPollingStatus.timedOut:
        return Column(
          children: [
            Text(
              'Seguimos esperando el pago. Puedes verificarlo manualmente.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: onCheckNow,
              icon: const Icon(Icons.sync_rounded, size: 18),
              label: const Text('Verificar ahora'),
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  String _formatDate(DateTime date) {
    final local = date.toLocal();
    final dd = local.day.toString().padLeft(2, '0');
    final mm = local.month.toString().padLeft(2, '0');
    final hh = local.hour.toString().padLeft(2, '0');
    final min = local.minute.toString().padLeft(2, '0');
    return '$dd/$mm ${'$hh:$min'}';
  }
}
