import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/sales/presentation/models/sale_ui_model.dart';
import 'package:treasureflow/features/sales/presentation/ui_states/sale_status.dart';
import 'package:treasureflow/features/sales/presentation/widgets/amount_comparison_widget.dart';
import 'package:treasureflow/features/sales/presentation/widgets/delivery_qr_card_widget.dart';
import 'package:treasureflow/features/sales/presentation/widgets/payment_method_selector_widget.dart';
import 'package:treasureflow/features/sales/presentation/widgets/sale_stepper_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

/// Detalle de una venta: pantalla única cuyo contenido cambia según el
/// estado de la venta (stepper Oferta → Entrega → Pesaje → Pago).
class SaleDetailScreen extends StatefulWidget {
  final String saleId;

  const SaleDetailScreen({super.key, required this.saleId});

  @override
  State<SaleDetailScreen> createState() => _SaleDetailScreenState();
}

class _SaleDetailScreenState extends State<SaleDetailScreen> {
  late SaleUiModel _sale;
  PaymentMethod? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _sale = mockSales.firstWhere(
      (s) => s.id == widget.saleId,
      // Post real apartado que aún no está en los mocks → venta nueva
      orElse: () => mockSales.first.copyWith(status: SaleStatus.accepted),
    );
  }

  void _advanceTo(SaleStatus status, {double? finalWeight}) {
    setState(() {
      _sale = _sale.copyWith(status: status, finalWeight: finalWeight);
    });
  }

  void _onGenerateQr() => _advanceTo(SaleStatus.awaitingHandoff);

  void _onSimulateScan() => _advanceTo(SaleStatus.weighing);

  void _onSimulateWeighing() => _advanceTo(
        SaleStatus.amountReview,
        finalWeight: _sale.estimatedQuantity * 1.24,
      );

  void _onAcceptAmount() {
    _advanceTo(SaleStatus.paymentPending);
    AppToast.show(context, 'Monto aceptado', type: ToastType.success);
  }

  Future<void> _onReportIssue() async {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    final sent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reportar inconveniente',
          style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Cuéntanos qué pasó con el pesaje…',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );

    controller.dispose();
    if (sent == true && mounted) {
      AppToast.show(
        context,
        'Registramos tu reporte, el establecimiento se pondrá en contacto',
        type: ToastType.warning,
      );
    }
  }

  void _onConfirmPayment() {
    _advanceTo(SaleStatus.completed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isCompleted = _sale.status == SaleStatus.completed;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(isCompleted ? 'Venta completada' : 'Detalle de venta'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isCompleted) ...[
                SaleStepperWidget(currentStep: _sale.status.stepNumber),
                const SizedBox(height: 20),
              ],
              ..._buildStepContent(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStepContent() {
    return switch (_sale.status) {
      SaleStatus.accepted => _buildAcceptedStep(),
      SaleStatus.awaitingHandoff => _buildHandoffStep(),
      SaleStatus.weighing => _buildWeighingStep(),
      SaleStatus.amountReview => _buildAmountReviewStep(),
      SaleStatus.paymentPending => _buildPaymentStep(),
      SaleStatus.completed => _buildCompletedStep(),
    };
  }

  // ── Paso 1: Oferta aceptada ─────────────────────────────────────────
  List<Widget> _buildAcceptedStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final isDropOff = _sale.deliveryMode == 'drop_off';

    return [
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.recycling_rounded, 'Residuo'),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(Icons.recycling_rounded,
                      color: colors.primary, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _sale.wasteTitle,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _miniChip(_sale.materialTypeName),
                          _miniChip(
                            'Estimado: ${_sale.estimatedQuantity.toStringAsFixed(0)} ${_sale.unit}',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.storefront_outlined, 'Establecimiento'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _sale.establishmentName,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.star_rounded,
                    size: 16, color: const Color(0xFFE8A13D)),
                const SizedBox(width: 2),
                Text(
                  '${_sale.establishmentRating} · ${_sale.establishmentDistance}',
                  style: textTheme.bodySmall?.copyWith(
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.sell_outlined, 'Oferta del establecimiento'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Precio estimado',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Text(
                  '\$${_sale.estimatedAmount.toStringAsFixed(2)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '\$${_sale.pricePerUnit.toStringAsFixed(2)} por ${_sale.unit}',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8A13D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded,
                      size: 16, color: Color(0xFFC77F1A)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'El precio mostrado es una estimación. El monto final podrá cambiar después del pesaje del material.',
                      style: textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFC77F1A),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(
              Icons.location_on_outlined,
              isDropOff ? 'Punto de entrega' : 'Domicilio de recolección',
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  isDropOff
                      ? Icons.storefront_outlined
                      : Icons.home_outlined,
                  size: 20,
                  color: colors.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _sale.addressText,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isDropOff
                  ? 'Lleva tu material a la dirección del establecimiento.'
                  : 'El establecimiento pasará a tu domicilio por el material.',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonGreenWidget(
        text: 'Generar QR de entrega',
        onPressed: _onGenerateQr,
      ),
    ];
  }

  // ── Paso 2: Entrega (QR) ────────────────────────────────────────────
  List<Widget> _buildHandoffStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return [
      Text(
        'Muéstrale este código al establecimiento cuando llegues al punto de encuentro.',
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(height: 16),
      DeliveryQrCardWidget(payload: 'TF-SALE:${_sale.id}'),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Detalles de la entrega',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _detailRow('Residuo', _sale.wasteTitle),
            _detailRow('Establecimiento', _sale.establishmentName),
            _detailRow('Fecha', _sale.dateLabel),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFE8A13D).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.access_time_rounded,
                      size: 13, color: Color(0xFFC77F1A)),
                  const SizedBox(width: 4),
                  Text(
                    'Pendiente de pesaje',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFC77F1A),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      // Botón temporal de demo — se elimina al conectar el backend
      OutlinedButton.icon(
        onPressed: _onSimulateScan,
        icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
        label: const Text('Simular escaneo (demo)'),
      ),
    ];
  }

  // ── Paso 3a: Pesando ────────────────────────────────────────────────
  List<Widget> _buildWeighingStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return [
      AppCardContainer(
        child: Column(
          children: [
            const SizedBox(height: 12),
            SizedBox(
              width: 42,
              height: 42,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'El establecimiento está pesando tu material…',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'En cuanto registre el peso real, aquí verás el monto final para que lo confirmes.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      const SizedBox(height: 24),
      // Botón temporal de demo — se elimina al conectar el backend
      OutlinedButton.icon(
        onPressed: _onSimulateWeighing,
        icon: const Icon(Icons.scale_rounded, size: 18),
        label: const Text('Simular pesaje (demo)'),
      ),
    ];
  }

  // ── Paso 3b: Revisar monto ──────────────────────────────────────────
  List<Widget> _buildAmountReviewStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final finalWeight = _sale.finalWeight ?? _sale.estimatedQuantity;
    final finalAmount = _sale.finalAmount ?? _sale.estimatedAmount;

    return [
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del pesaje',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _detailRow('Residuo', _sale.wasteTitle),
            _detailRow(
              'Peso final',
              '${finalWeight.toStringAsFixed(1)} ${_sale.unit}',
            ),
            _detailRow(
              'Precio por ${_sale.unit}',
              '\$${_sale.pricePerUnit.toStringAsFixed(2)}',
            ),
            Divider(
              height: 24,
              color: colors.outline.withValues(alpha: 0.3),
            ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monto total',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${finalAmount.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      AmountComparisonWidget(
        estimatedAmount: _sale.estimatedAmount,
        finalAmount: finalAmount,
      ),
      const SizedBox(height: 16),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.check_circle_outline_rounded,
                size: 16, color: colors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'El establecimiento ha confirmado el peso real del material.',
                style: textTheme.bodySmall?.copyWith(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonGreenWidget(
        text: 'Aceptar monto',
        onPressed: _onAcceptAmount,
      ),
      const SizedBox(height: 10),
      OutlinedButton(
        onPressed: _onReportIssue,
        child: const Text('Reportar inconveniente'),
      ),
    ];
  }

  // ── Paso 4: Pago ────────────────────────────────────────────────────
  List<Widget> _buildPaymentStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final finalAmount = _sale.finalAmount ?? _sale.estimatedAmount;

    return [
      AppCardContainer(
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Monto a recibir',
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '\$${finalAmount.toStringAsFixed(2)}',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Text(
        '¿Cómo quieres recibir tu pago?',
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      PaymentMethodSelectorWidget(
        selected: _paymentMethod,
        onChanged: (m) => setState(() => _paymentMethod = m),
      ),
      const SizedBox(height: 24),
      PrimaryButtonGreenWidget(
        text: 'Recibí el pago',
        onPressed: _paymentMethod == null
            ? () => AppToast.show(
                  context,
                  'Selecciona un método de pago',
                  type: ToastType.warning,
                )
            : _onConfirmPayment,
      ),
    ];
  }

  // ── Venta completada ────────────────────────────────────────────────
  List<Widget> _buildCompletedStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final finalAmount = _sale.finalAmount ?? _sale.estimatedAmount;
    final finalWeight = _sale.finalWeight ?? _sale.estimatedQuantity;
    final methodLabel = switch (_paymentMethod) {
      PaymentMethod.paypal => 'PayPal',
      PaymentMethod.transfer => 'Transferencia',
      _ => 'Efectivo',
    };

    return [
      const SizedBox(height: 24),
      Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.primary.withValues(alpha: 0.12),
        ),
        child: Icon(Icons.check_rounded, size: 48, color: colors.primary),
      ),
      const SizedBox(height: 20),
      Text(
        '¡Venta completada!',
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'Gracias por darle una segunda vida a tu material.',
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(height: 24),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen de la venta',
              style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _detailRow('Residuo', _sale.wasteTitle),
            _detailRow('Establecimiento', _sale.establishmentName),
            _detailRow(
              'Peso final',
              '${finalWeight.toStringAsFixed(1)} ${_sale.unit}',
            ),
            _detailRow('Método de pago', methodLabel),
            Divider(height: 24, color: colors.outline.withValues(alpha: 0.3)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monto recibido',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${finalAmount.toStringAsFixed(2)}',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonBlueWidget(
        text: 'Volver a mis ventas',
        onPressed: () => context.go('/mySales'),
      ),
    ];
  }

  // ── Helpers ─────────────────────────────────────────────────────────
  Widget _sectionTitle(IconData icon, String title) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _miniChip(String label) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(color: colors.primary.withValues(alpha: 0.25)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 11,
          color: colors.primary,
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
