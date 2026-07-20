import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/local/di/local_collections_module.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/local/domain/entities/collection_offer_info.dart';
import 'package:treasureflow/features/collections/local/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/local/presentation/widgets/card_payment_form_widget.dart';
import 'package:treasureflow/features/collections/local/presentation/widgets/payment_voucher_widget.dart';
import 'package:treasureflow/features/collections/local/presentation/providers/local_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/shared/utils/collection_receipt_pdf.dart';
import 'package:treasureflow/features/collections/shared/widgets/collection_stepper_widget.dart';
import 'package:treasureflow/features/collections/local/presentation/widgets/conekta_method_selector_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class CollectionDetailLocalScreen extends StatefulWidget {
  final String collectionId;

  const CollectionDetailLocalScreen({super.key, required this.collectionId});

  @override
  State<CollectionDetailLocalScreen> createState() =>
      _CollectionDetailLocalScreenState();
}

class _CollectionDetailLocalScreenState
    extends State<CollectionDetailLocalScreen>
    with WidgetsBindingObserver {
  late final LocalCollectionDetailProvider _provider;
  final _weightController = TextEditingController();
  PaymentMethodType? _selectedMethod;
  bool _showCardForm = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final container = context.read<AppContainer>();
    _provider = LocalCollectionsModule(container).provideDetailProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load(widget.collectionId);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _weightController.dispose();
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _provider.resumePolling();
      _provider.silentReload();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _provider.pausePolling();
    }
  }

  void _onProviderChanged() {
    if (!mounted) return;

    final status = _provider.detail?.collection.status;
    if (status == CollectionStatus.pendingConfirmation) {
      _provider.startPassiveRefresh();
    } else {
      _provider.stopPassiveRefresh();
    }

    setState(() {});
  }

  Future<void> _onSendWeighing() async {
    final weight = double.tryParse(_weightController.text.trim());
    if (weight == null || weight <= 0) {
      AppToast.show(context, 'Ingresa un peso válido', type: ToastType.warning);
      return;
    }

    final ok = await _provider.registerWeighing(weight);
    if (!mounted) return;
    if (ok) {
      AppToast.show(
        context,
        'Pesaje registrado, el ciudadano confirmará el monto',
        type: ToastType.success,
      );
    } else {
      AppToast.show(
        context,
        _provider.actionError ?? 'No se pudo registrar el pesaje',
        type: ToastType.error,
      );
    }
  }

  Future<void> _onPayWithCard(String tokenId) async {
    final ok = await _provider.payWithCard(tokenId: tokenId);
    if (!mounted) return;
    if (ok) {
      AppToast.show(context, '¡Pago realizado!', type: ToastType.success);
    } else {
      AppToast.show(
        context,
        _provider.actionError ?? 'No se pudo procesar el pago',
        type: ToastType.error,
      );
    }
  }

  Future<void> _onGenerateVoucher() async {
    final method = _selectedMethod;
    if (method == null) return;

    final ok = await _provider.payWithVoucher(method);
    if (!mounted) return;
    if (!ok) {
      AppToast.show(
        context,
        _provider.actionError ?? 'No se pudo generar el pago',
        type: ToastType.error,
      );
    }
  }

  Future<void> _onCancel() async {
    final theme = Theme.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Cancelar recolección',
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          '¿Seguro que quieres cancelar? El ciudadano será notificado.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Volver'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final ok = await _provider.cancelCollection();
    if (!mounted) return;
    if (ok) {
      AppToast.show(context, 'Recolección cancelada', type: ToastType.info);
    } else {
      AppToast.show(
        context,
        _provider.actionError ?? 'No se pudo cancelar',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    if (_provider.status == LocalDetailStatus.loading ||
        _provider.status == LocalDetailStatus.idle) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_provider.status == LocalDetailStatus.error) {
      return _buildErrorScaffold();
    }

    final collection = _provider.detail!.collection;
    final isCompleted = collection.status == CollectionStatus.completed;
    final isCancelled = collection.status.isCancelled;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          isCompleted
              ? 'Compra completada'
              : isCancelled
              ? 'Recolección cancelada'
              : 'Detalle de compra',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!isCompleted && !isCancelled) ...[
                CollectionStepperWidget(
                  currentStep: collection.status.stepNumber,
                ),
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

  Widget _buildErrorScaffold() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(backgroundColor: colors.surface, elevation: 0),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
              const SizedBox(height: 16),
              Text(
                _provider.errorMessage ?? 'No se pudo cargar la recolección',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              PrimaryButtonBlueWidget(
                text: 'Reintentar',
                onPressed: () => _provider.load(widget.collectionId),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStepContent() {
    final collection = _provider.detail!.collection;
    return switch (collection.status) {
      CollectionStatus.pendingDelivery ||
      CollectionStatus.pendingWeighing => _buildWeighingStep(),
      CollectionStatus.pendingConfirmation => _buildAwaitingStep(),
      CollectionStatus.pendingPayment => _buildPaymentStep(),
      CollectionStatus.completed => _buildCompletedStep(),
      _ => _buildCancelledStep(),
    };
  }

  Widget _buildInfoCard() {
    final offer = _provider.detail!.offer;

    return AppCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.recycling_rounded, 'Material a recibir'),
          const SizedBox(height: 12),
          _detailRow('Material', offer.wastePublicationTitle ?? 'Residuo'),
          _detailRow('Ciudadano', offer.citizenName ?? 'Ciudadano'),
          _detailRow(
            'Tu oferta',
            '\$${offer.pricePerUnit.toStringAsFixed(2)} por ${offer.unit}',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildWeighingStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final offer = _provider.detail!.offer;
    final weight = double.tryParse(_weightController.text.trim());
    final estimated = weight == null ? null : weight * offer.pricePerUnit;

    return [
      _buildInfoCard(),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle(Icons.scale_rounded, 'Registro de pesaje'),
            const SizedBox(height: 8),
            Text(
              'Al registrar el peso confirmas que recibiste el material. El monto final se calcula automáticamente.',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Peso real recibido',
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
              ],
              onChanged: (_) => setState(() {}),
              style: textTheme.titleMedium,
              decoration: InputDecoration(
                hintText: '0.0',
                suffixText: offer.unit,
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: colors.onSurface.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 15,
                    color: colors.onSurface.withValues(alpha: 0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      estimated == null
                          ? 'El monto se calculará: peso × \$${offer.pricePerUnit.toStringAsFixed(2)}/${offer.unit}'
                          : 'Monto a pagar: ${weight!.toStringAsFixed(2)} ${offer.unit} × \$${offer.pricePerUnit.toStringAsFixed(2)} = \$${estimated.toStringAsFixed(2)}',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonGreenWidget(
        text: 'Registrar pesaje',
        isLoading: _provider.actionStatus == LocalActionStatus.working,
        onPressed: _onSendWeighing,
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: _provider.actionStatus == LocalActionStatus.working
            ? null
            : _onCancel,
        icon: const Icon(Icons.cancel_outlined, size: 18),
        label: const Text('Cancelar recolección'),
      ),
    ];
  }

  List<Widget> _buildAwaitingStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final collection = _provider.detail!.collection;
    final finalAmount = collection.finalAmount ?? 0;

    return [
      _buildInfoCard(),
      const SizedBox(height: 14),
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
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Monto calculado: \$${finalAmount.toStringAsFixed(2)}. En cuanto lo acepte podrás realizar el pago.',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    ];
  }

  List<Widget> _buildPaymentStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final collection = _provider.detail!.collection;
    final finalAmount = collection.finalAmount ?? 0;
    final isWorking = _provider.actionStatus == LocalActionStatus.working;

    final voucher = _provider.paymentResult;
    final hasActiveVoucher =
        voucher != null &&
        voucher.method != PaymentMethodType.card &&
        _provider.pollingStatus != PaymentPollingStatus.idle;

    if (hasActiveVoucher) {
      return [
        _buildInfoCard(),
        const SizedBox(height: 14),
        PaymentVoucherWidget(
          result: voucher,
          pollingStatus: _provider.pollingStatus,
          onRetry: () {
            _provider.resetPaymentFlow();
            setState(() {
              _selectedMethod = null;
              _showCardForm = false;
            });
          },
          onCheckNow: _provider.checkPaymentNow,
        ),
      ];
    }

    return [
      AppCardContainer(
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Monto a pagar',
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
        '¿Cómo vas a pagarle al ciudadano?',
        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      ConektaMethodSelectorWidget(
        selected: _selectedMethod,
        onChanged: isWorking
            ? (_) {}
            : (method) => setState(() {
                _selectedMethod = method;
                _showCardForm = method == PaymentMethodType.card;
              }),
      ),
      const SizedBox(height: 20),
      if (_showCardForm)
        CardPaymentFormWidget(
          amount: finalAmount,
          isLoading: isWorking,
          onSubmit: _onPayWithCard,
        )
      else if (_selectedMethod != null)
        PrimaryButtonGreenWidget(
          text: _selectedMethod == PaymentMethodType.cash
              ? 'Generar referencia OXXO'
              : 'Generar CLABE SPEI',
          isLoading: isWorking,
          onPressed: _onGenerateVoucher,
        )
      else
        PrimaryButtonGreenWidget(
          text: 'Continuar',
          onPressed: () => AppToast.show(
            context,
            'Selecciona un método de pago',
            type: ToastType.warning,
          ),
        ),
    ];
  }

  List<Widget> _buildCompletedStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final detail = _provider.detail!;
    final collection = detail.collection;
    final offer = detail.offer;
    final payment = detail.payment;

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
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _detailRow('Material', offer.wastePublicationTitle ?? 'Residuo'),
            _detailRow('Ciudadano', offer.citizenName ?? 'Ciudadano'),
            _detailRow(
              'Peso final',
              '${(collection.actualQuantity ?? 0).toStringAsFixed(2)} ${offer.unit}',
            ),
            if (payment != null)
              _detailRow('Método de pago', payment.method.label),
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
                  '\$${(payment?.grossAmount ?? collection.finalAmount ?? 0).toStringAsFixed(2)}',
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
      const SizedBox(height: 14),
      OutlinedButton.icon(
        onPressed: () => _onShareReceipt(collection, offer, payment),
        icon: const Icon(Icons.share_outlined, size: 18),
        label: const Text('Compartir comprobante'),
      ),
      const SizedBox(height: 10),
      PrimaryButtonBlueWidget(
        text: 'Volver a mis compras',
        onPressed: () => context.go('/myPurchases'),
      ),
    ];
  }

  Future<void> _onShareReceipt(
    Collection collection,
    CollectionOfferInfo offer,
    Payment? payment,
  ) async {
    await shareCollectionReceipt(
      CollectionReceiptData(
        collectionId: collection.collectionId,
        materialTitle: offer.wastePublicationTitle ?? 'Residuo',
        counterpartLabel: 'Ciudadano',
        counterpartName: offer.citizenName ?? 'Ciudadano',
        actualQuantity: collection.actualQuantity ?? 0,
        unit: offer.unit,
        pricePerUnit: offer.pricePerUnit,
        finalAmount: payment?.grossAmount ?? collection.finalAmount ?? 0,
        netAmount: payment?.grossAmount ?? collection.finalAmount ?? 0,
        paymentMethodLabel: payment?.method.label,
        date: payment?.paymentDate ?? DateTime.now(),
      ),
    );
  }

  List<Widget> _buildCancelledStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final status = _provider.detail!.collection.status;
    final byMe = status == CollectionStatus.cancelledByEstablishment;

    return [
      const SizedBox(height: 24),
      Container(
        width: 88,
        height: 88,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: colors.error.withValues(alpha: 0.1),
        ),
        child: Icon(Icons.close_rounded, size: 48, color: colors.error),
      ),
      const SizedBox(height: 20),
      Text(
        'Recolección cancelada',
        textAlign: TextAlign.center,
        style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 8),
      Text(
        byMe
            ? 'Cancelaste esta recolección.'
            : 'El ciudadano canceló esta recolección.',
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonBlueWidget(
        text: 'Volver a mis compras',
        onPressed: () => context.go('/myPurchases'),
      ),
    ];
  }

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
