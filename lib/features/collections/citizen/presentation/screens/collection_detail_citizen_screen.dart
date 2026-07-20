import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/collections/citizen/di/citizen_collections_module.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/collection_offer_info.dart';
import 'package:treasureflow/features/collections/citizen/domain/entities/payment.dart';
import 'package:treasureflow/features/collections/citizen/presentation/providers/citizen_collection_detail_provider.dart';
import 'package:treasureflow/features/collections/shared/utils/collection_receipt_pdf.dart';
import 'package:treasureflow/features/collections/shared/widgets/collection_stepper_widget.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

/// Detalle de una recolección — vista del CIUDADANO.
/// Pasos: espera de pesaje → confirmar monto → espera de pago → completada.
class CollectionDetailCitizenScreen extends StatefulWidget {
  final String collectionId;

  const CollectionDetailCitizenScreen({super.key, required this.collectionId});

  @override
  State<CollectionDetailCitizenScreen> createState() =>
      _CollectionDetailCitizenScreenState();
}

class _CollectionDetailCitizenScreenState
    extends State<CollectionDetailCitizenScreen> {
  late final CitizenCollectionDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = CitizenCollectionsModule(container).provideDetailProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load(widget.collectionId);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    _provider.dispose();
    super.dispose();
  }

  void _onProviderChanged() {
    if (!mounted) return;

    // Refresco pasivo mientras se espera a la contraparte
    final status = _provider.detail?.collection.status;
    if (status == CollectionStatus.pendingDelivery ||
        status == CollectionStatus.pendingPayment) {
      _provider.startPassiveRefresh();
    } else {
      _provider.stopPassiveRefresh();
    }

    setState(() {});
  }

  Future<void> _onConfirmAmount() async {
    final ok = await _provider.confirmAmount();
    if (!mounted) return;
    if (ok) {
      AppToast.show(context, 'Monto confirmado', type: ToastType.success);
    } else {
      AppToast.show(
        context,
        _provider.actionError ?? 'No se pudo confirmar el monto',
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
          '¿Seguro que quieres cancelar? El establecimiento será notificado.',
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

    if (_provider.status == CitizenDetailStatus.loading ||
        _provider.status == CitizenDetailStatus.idle) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_provider.status == CitizenDetailStatus.error) {
      return _buildErrorScaffold();
    }

    final detail = _provider.detail!;
    final collection = detail.collection;
    final isCompleted = collection.status == CollectionStatus.completed;
    final isCancelled = collection.status.isCancelled;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: Text(
          isCompleted
              ? 'Venta completada'
              : isCancelled
                  ? 'Recolección cancelada'
                  : 'Detalle de venta',
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
              Icon(Icons.error_outline_rounded,
                  size: 48, color: colors.error),
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
      CollectionStatus.pendingWeighing =>
        _buildWeighingWaitStep(),
      CollectionStatus.pendingConfirmation => _buildAmountReviewStep(),
      CollectionStatus.pendingPayment => _buildPaymentWaitStep(),
      CollectionStatus.completed => _buildCompletedStep(),
      _ => _buildCancelledStep(),
    };
  }

  // ── Sección informativa (residuo + establecimiento + oferta) ────────────────
  Widget _buildInfoCard() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final offer = _provider.detail!.offer;

    return AppCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionTitle(Icons.recycling_rounded, 'Recolección'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: offer.wastePublicationPhotoUrl != null
                    ? Image.network(
                        offer.wastePublicationPhotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.recycling_rounded,
                          color: colors.primary,
                          size: 28,
                        ),
                      )
                    : Icon(
                        Icons.recycling_rounded,
                        color: colors.primary,
                        size: 28,
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      offer.wastePublicationTitle ?? 'Residuo',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      offer.establishmentName ?? 'Establecimiento',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Divider(height: 24, color: colors.outline.withValues(alpha: 0.3)),
          _detailRow(
            'Precio ofertado',
            '\$${offer.pricePerUnit.toStringAsFixed(2)} por ${offer.unit}',
          ),
        ],
      ),
    );
  }

  // ── Paso 1: esperando pesaje ────────────────────────────────────────────────
  List<Widget> _buildWeighingWaitStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

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
              'Entrega tu material al establecimiento',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cuando el establecimiento reciba y pese tu material, aquí verás el monto final para que lo confirmes.',
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
      OutlinedButton.icon(
        onPressed:
            _provider.actionStatus == CitizenActionStatus.working
                ? null
                : _onCancel,
        icon: const Icon(Icons.cancel_outlined, size: 18),
        label: const Text('Cancelar recolección'),
      ),
    ];
  }

  // ── Paso 2: revisar y confirmar monto ───────────────────────────────────────
  List<Widget> _buildAmountReviewStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final detail = _provider.detail!;
    final collection = detail.collection;
    final offer = detail.offer;
    final finalAmount = collection.finalAmount ?? 0;
    final quantity = collection.actualQuantity ?? 0;

    return [
      _buildInfoCard(),
      const SizedBox(height: 14),
      AppCardContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resumen del pesaje',
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _detailRow(
              'Peso registrado',
              '${quantity.toStringAsFixed(2)} ${offer.unit}',
            ),
            _detailRow(
              'Precio por ${offer.unit}',
              '\$${offer.pricePerUnit.toStringAsFixed(2)}',
            ),
            Divider(height: 24, color: colors.outline.withValues(alpha: 0.3)),
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
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              size: 16,
              color: colors.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'El establecimiento registró el peso real de tu material. Al confirmar, podrá realizar el pago.',
                style: textTheme.bodySmall?.copyWith(color: colors.primary),
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonGreenWidget(
        text: 'Aceptar monto',
        isLoading: _provider.actionStatus == CitizenActionStatus.working,
        onPressed: _onConfirmAmount,
      ),
    ];
  }

  // ── Paso 3: esperando el pago ───────────────────────────────────────────────
  List<Widget> _buildPaymentWaitStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final finalAmount = _provider.detail!.collection.finalAmount ?? 0;

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
              'El establecimiento está procesando tu pago…',
              textAlign: TextAlign.center,
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Recibirás \$${finalAmount.toStringAsFixed(2)} (menos la comisión de TreasureFlow). Te avisaremos en cuanto se confirme.',
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

  // ── Completada ─────────────────────────────────────────────────────────────
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
              style: textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _detailRow('Material', offer.wastePublicationTitle ?? 'Residuo'),
            _detailRow(
              'Establecimiento',
              offer.establishmentName ?? 'Establecimiento',
            ),
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
                    'Monto recibido',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '\$${(payment?.receiverNetAmount ?? collection.finalAmount ?? 0).toStringAsFixed(2)}',
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
        text: 'Volver a mis ventas',
        onPressed: () => context.go('/mySales'),
      ),
    ];
  }

  Future<void> _onShareReceipt(
    Collection collection,
    CollectionOfferInfo offer,
    Payment? payment,
  ) async {
    await shareCollectionReceipt(CollectionReceiptData(
      collectionId: collection.collectionId,
      materialTitle: offer.wastePublicationTitle ?? 'Residuo',
      counterpartLabel: 'Establecimiento',
      counterpartName: offer.establishmentName ?? 'Establecimiento',
      actualQuantity: collection.actualQuantity ?? 0,
      unit: offer.unit,
      pricePerUnit: offer.pricePerUnit,
      finalAmount: payment?.grossAmount ?? collection.finalAmount ?? 0,
      treasureflowFee: payment?.treasureflowFee,
      netAmount: payment?.receiverNetAmount ?? collection.finalAmount ?? 0,
      paymentMethodLabel: payment?.method.label,
      date: payment?.paymentDate ?? DateTime.now(),
    ));
  }

  // ── Cancelada ──────────────────────────────────────────────────────────────
  List<Widget> _buildCancelledStep() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final status = _provider.detail!.collection.status;
    final byMe = status == CollectionStatus.cancelledByCitizen;

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
            : 'El establecimiento canceló esta recolección.',
        textAlign: TextAlign.center,
        style: textTheme.bodySmall?.copyWith(
          color: colors.onSurface.withValues(alpha: 0.6),
        ),
      ),
      const SizedBox(height: 24),
      PrimaryButtonBlueWidget(
        text: 'Volver a mis ventas',
        onPressed: () => context.go('/mySales'),
      ),
    ];
  }

  // ── Helpers ────────────────────────────────────────────────────────────────
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
