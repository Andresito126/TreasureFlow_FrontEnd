import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/features/sales/local/presentation/models/purchase_ui_model.dart';
import 'package:treasureflow/features/sales/local/presentation/screens/qr_scan_screen.dart';
import 'package:treasureflow/features/sales/local/presentation/ui_states/purchase_status.dart';
import 'package:treasureflow/features/sales/shared/widgets/payment_method_selector_widget.dart';
import 'package:treasureflow/features/sales/shared/widgets/sale_stepper_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

// detalle de una compra del establecimiento
// cambia según el estado (stepper ofert, entrega  pesaje pago

class PurchaseDetailScreen extends StatefulWidget {
  final String purchaseId;

  const PurchaseDetailScreen({super.key, required this.purchaseId});

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  late PurchaseUiModel _purchase;
  final _weightController = TextEditingController();
  final _finalPriceController = TextEditingController();
  PaymentMethod? _paymentMethod;

  @override
  void initState() {
    super.initState();
    _purchase = mockPurchases.firstWhere(
      (p) => p.id == widget.purchaseId,
      orElse: () => mockPurchases.first,
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _finalPriceController.dispose();
    super.dispose();
  }

  void _advanceTo(
    PurchaseStatus status, {
    double? finalWeight,
    double? manualFinalAmount,
  }) {
    setState(() {
      _purchase = _purchase.copyWith(
        status: status,
        finalWeight: finalWeight,
        manualFinalAmount: manualFinalAmount,
      );
    });
  }

  Future<void> _onScanQr() async {
    final scanned = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => const QrScanScreen(),
        fullscreenDialog: true,
      ),
    );
    if (scanned == true && mounted) {
      AppToast.show(context, 'Entrega vinculada', type: ToastType.success);
      _advanceTo(PurchaseStatus.weighing);
    }
  }

  void _onSendFinalPrice() {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      AppToast.show(context, 'Ingresa un peso válido', type: ToastType.warning);
      return;
    }

    final finalPrice = double.tryParse(_finalPriceController.text.trim());
    if (finalPrice == null || finalPrice <= 0) {
      AppToast.show(context, 'Ingresa el precio final que ofreces',
          type: ToastType.warning);
      return;
    }

    _advanceTo(
      PurchaseStatus.awaitingAcceptance,
      finalWeight: weight,
      manualFinalAmount: finalPrice,
    );
    AppToast.show(context, 'Precio final enviado al ciudadano',
        type: ToastType.info);
  }

  Future<void> _onReportIssue() async {
    final controller = TextEditingController();
    final theme = Theme.of(context);

    final sent = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Reportar imprevisto',
          style:
              theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '¿No podrás asistir a la recolección? Cuéntale al ciudadano qué pasó.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Ej. Se descompuso el vehículo, no podré llegar…',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
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
        'Avisamos al ciudadano del imprevisto',
        type: ToastType.warning,
      );
    }
  }

  void _onSimulateAcceptance() => _advanceTo(PurchaseStatus.paymentPending);

  void _onMarkPaid() {
    _advanceTo(PurchaseStatus.completed);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isCompleted = _purchase.status == PurchaseStatus.completed;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(isCompleted ? 'Compra completada' : 'Detalle de compra'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isCompleted) ...[
                SaleStepperWidget(currentStep: _purchase.status.stepNumber),
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
    return switch (_purchase.status) {
      PurchaseStatus.accepted => _buildAcceptedStep(),
      PurchaseStatus.weighing => _buildWeighingStep(),
      PurchaseStatus.awaitingAcceptance => _buildAwaitingStep(),
      PurchaseStatus.paymentPending => _buildPaymentStep(),
      PurchaseStatus.completed => _buildCompletedStep(),
    };
  }

  // paso 1 y 2: por recolectarrrrrrrr────────────────────────────────────────
  List<Widget> _buildAcceptedStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return [
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.recycling_rounded, 'Material a recolectar'),
            const SizedBox(height: 12),
            _detailRow('Residuo', _purchase.wasteTitle),
            _detailRow('Material', _purchase.materialTypeName),
            _detailRow(
              'Cantidad estimada',
              '${_purchase.estimatedQuantity.toStringAsFixed(0)} ${_purchase.unit}',
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.person_outline_rounded, 'Ciudadano'),
            const SizedBox(height: 12),
            _detailRow('Nombre', _purchase.citizenName),
            _detailRow('Dirección', _purchase.addressText),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.sell_outlined, 'Tu oferta'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monto estimado',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ),
                Text(
                  '\$${_purchase.estimatedAmount.toStringAsFixed(2)}',
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              '\$${_purchase.pricePerUnit.toStringAsFixed(2)} por ${_purchase.unit}',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      Text(
        'Cuando estés con el ciudadano, escanea su código de entrega para vincular la venta.',
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(height: 12),
      PrimaryButtonGreenWidget(
        text: 'Escanear QR de entrega',
        onPressed: _onScanQr,
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: _onReportIssue,
        icon: const Icon(Icons.report_problem_outlined, size: 18),
        label: const Text('Reportar imprevisto'),
      ),
    ];
  }

  // paso 3:pesaje ────────────────────────────────────────
  List<Widget> _buildWeighingStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final weight = double.tryParse(_weightController.text.trim());
    final suggested =
        weight == null ? null : weight * _purchase.pricePerUnit;

    return [
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.recycling_rounded, 'Material recibido'),
            const SizedBox(height: 12),
            _detailRow('Residuo', _purchase.wasteTitle),
            _detailRow('Ciudadano', _purchase.citizenName),
            _detailRow(
              'Oferta inicial',
              '\$${_purchase.estimatedAmount.toStringAsFixed(2)}',
            ),
          ],
        ),
      ),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.scale_rounded, 'Registro de pesaje'),
            const SizedBox(height: 12),
            Text(
              'Peso real recibido',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _weightController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              onChanged: (_) => setState(() {}),
              style: textTheme.titleMedium,
              decoration: InputDecoration(
                hintText: '0.0',
                suffixText: _purchase.unit,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 12),
            // Referencia informativa — el precio final lo decide el local
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 15,
                      color: colors.onSurface.withValues(alpha: 0.5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      suggested == null
                          ? 'Referencia: tu oferta fue de \$${_purchase.pricePerUnit.toStringAsFixed(2)} por ${_purchase.unit}'
                          : 'Referencia: ${weight!.toStringAsFixed(1)} ${_purchase.unit} × \$${_purchase.pricePerUnit.toStringAsFixed(2)}/${_purchase.unit} ≈ \$${suggested.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Precio final que ofreces',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _finalPriceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
              decoration: InputDecoration(
                hintText: '0.00',
                prefixText: '\$ ',
                prefixStyle: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colors.primary,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: colors.primary, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tú decides el monto final. El ciudadano deberá aceptarlo.',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonGreenWidget(
        text: 'Enviar precio final',
        onPressed: _onSendFinalPrice,
      ),
    ];
  }

  //  paso 3: esperando al ciudadano ─────────────────────────────────
  List<Widget> _buildAwaitingStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final finalAmount = _purchase.finalAmount ?? _purchase.estimatedAmount;

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
              'El ciudadano está revisando el monto…',
              textAlign: TextAlign.center,
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Enviaste \$${finalAmount.toStringAsFixed(2)}. En cuanto acepte podrás realizar el pago.',
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
        onPressed: _onSimulateAcceptance,
        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
        label: const Text('Simular confirmación (demo)'),
      ),
    ];
  }

  // paso 4: pago ────────────────────────────────────────────────────
  List<Widget> _buildPaymentStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final finalAmount = _purchase.finalAmount ?? _purchase.estimatedAmount;

    return [
      AppCardContainer(
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Monto a pagar',
                style:
                    textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
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
        '¿Cómo vas a pagarle al ciudadano?',
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      PaymentMethodSelectorWidget(
        selected: _paymentMethod,
        isPayer: true,
        onChanged: (m) => setState(() => _paymentMethod = m),
      ),
      const SizedBox(height: 24),
      PrimaryButtonGreenWidget(
        text: 'Marcar como pagado',
        onPressed: _paymentMethod == null
            ? () => AppToast.show(
                  context,
                  'Selecciona un método de pago',
                  type: ToastType.warning,
                )
            : _onMarkPaid,
      ),
    ];
  }

  // completadooooooooooooo ───────────────────────────────────────────────
  List<Widget> _buildCompletedStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final finalAmount = _purchase.finalAmount ?? _purchase.estimatedAmount;
    final finalWeight = _purchase.finalWeight ?? _purchase.estimatedQuantity;
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
        '¡Compra completada!',
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        'El material ya es tuyo. Gracias por reciclar.',
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
              'Resumen de la compra',
              style:
                  textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _detailRow('Residuo', _purchase.wasteTitle),
            _detailRow('Ciudadano', _purchase.citizenName),
            _detailRow(
              'Peso final',
              '${finalWeight.toStringAsFixed(1)} ${_purchase.unit}',
            ),
            _detailRow('Método de pago', methodLabel),
            Divider(height: 24, color: colors.outline.withValues(alpha: 0.3)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Monto pagado',
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
        text: 'Volver a mis compras',
        onPressed: () => context.go('/myPurchases'),
      ),
    ];
  }

  // ── helpers ─────────────────────────────────────────────────────────
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
