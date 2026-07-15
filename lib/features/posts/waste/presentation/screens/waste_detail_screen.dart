import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/image_gallery_widget.dart';
import 'package:treasureflow/features/posts/waste/di/waste_post_module.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/offer_summary.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/waste_detail_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/info_banner_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/offer_item_widget.dart';
import 'package:treasureflow/shared/utils/material_type_translator.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';
import 'package:treasureflow/shared/widgets/app_toast.dart';
import 'package:treasureflow/shared/widgets/image_viewer_screen.dart';

class WasteDetailScreen extends StatefulWidget {
  final String postId;

  const WasteDetailScreen({super.key, required this.postId});

  @override
  State<WasteDetailScreen> createState() => _WasteDetailScreenState();
}

class _WasteDetailScreenState extends State<WasteDetailScreen> {
  bool _descriptionExpanded = false;
  late final WasteDetailProvider _provider;

  @override
  void initState() {
    super.initState();
    final container = context.read<AppContainer>();
    _provider = WastePostModule(container).provideDetailProvider();
    _provider.addListener(_onProviderChanged);
    _provider.load(widget.postId);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChanged);
    super.dispose();
  }

  void _onProviderChanged() => setState(() {});

  Future<void> _confirmAccept({
    required String postId,
    required OfferSummary offer,
  }) async {
    final price =
        '\$${offer.pricePerUnit.toStringAsFixed(2)}/${offer.unit}';
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final colors = Theme.of(ctx).colorScheme;
        final textTheme = Theme.of(ctx).textTheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('¿Aceptar oferta?', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Estás a punto de aceptar la oferta de:', style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.6))),
              const SizedBox(height: 8),
              Text(offer.establishmentName, style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
              Text(price, style: textTheme.bodySmall?.copyWith(color: colors.primary, fontWeight: FontWeight.bold)),
              if (offer.pickupLabel.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: colors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_outlined, size: 14, color: colors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pasarían por él: ${offer.pickupLabel}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Text('El resto de las ofertas serán rechazadas automáticamente.', style: textTheme.bodySmall?.copyWith(color: colors.onSurface.withValues(alpha: 0.5))),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sí, aceptar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _provider.acceptOffer(postId: postId, offerId: offer.offerId);
    }
  }

  Future<void> _confirmReject({
    required String postId,
    required OfferSummary offer,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final textTheme = Theme.of(ctx).textTheme;
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('¿Rechazar oferta?', style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
          content: Text(
            'Se notificará a ${offer.establishmentName} que su oferta fue rechazada. Podrás seguir recibiendo otras ofertas.',
            style: textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.error),
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Rechazar'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      final ok = await _provider.rejectOffer(
          postId: postId, offerId: offer.offerId);
      if (!mounted) return;
      if (!ok) {
        AppToast.show(context, 'Error al rechazar la oferta',
            type: ToastType.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_provider.status == WasteDetailStatus.loading || _provider.status == WasteDetailStatus.idle) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_provider.status == WasteDetailStatus.error) {
      final colors = Theme.of(context).colorScheme;
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              _provider.errorMessage ?? 'Error al cargar la publicación',
              style: TextStyle(color: colors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final post = _provider.post!;
    return _buildContent(post);
  }

  Widget _buildContent(WastePostDetail post) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final translatedMaterial = MaterialTypeTranslator.translate(post.materialTypeName);

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageGalleryWidget(
                    imageUrls: post.photoUrls.isEmpty ? ['placeholder'] : post.photoUrls,
                    onImageTap: post.photoUrls.isEmpty
                        ? null
                        : (index) => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ImageViewerScreen(
                                  imageUrls: post.photoUrls,
                                  initialIndex: index,
                                ),
                              ),
                            ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                MaterialTypeTranslator.translate(post.title),
                                style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusBadge(post.status, textTheme),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Publicado ${post.publishedAt}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _infoChip(Icons.recycling, translatedMaterial, colors, textTheme),
                            if (post.distance != null)
                              _infoChip(Icons.location_on_outlined, post.distance!, colors, textTheme),
                            _infoChip(Icons.visibility_outlined, '${post.viewsCount} vistas', colors, textTheme),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _deliveryModeBanner(post.deliveryMode, textTheme),
                        const SizedBox(height: 20),

                        Text(
                          'Descripción',
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.description,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: _descriptionExpanded ? null : 3,
                          overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
                        ),
                        if (post.description.length > 120)
                          GestureDetector(
                            onTap: () => setState(() => _descriptionExpanded = !_descriptionExpanded),
                            child: Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                _descriptionExpanded ? 'Leer menos' : 'Leer más',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 20),

                        const InfoBannerWidget(
                          svgPath: 'assets/posts/money_icon.svg',
                          title: 'Las ofertas se calculan por unidad.',
                          subtitle: 'El monto final se confirma al pesar el material en la recolección.',
                        ),
                        const SizedBox(height: 20),

                        Text(
                          'Ofertas recibidas',
                          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const Divider(),
                        if (post.offers.isEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Text(
                              'Aún no has recibido ofertas',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          )
                        else
                          ...post.offers.map((offer) {
                            final isAccepting =
                                _provider.acceptingOfferId == offer.offerId &&
                                _provider.acceptStatus == AcceptOfferStatus.accepting;
                            final isRejecting =
                                _provider.rejectingOfferId == offer.offerId &&
                                _provider.rejectStatus == RejectOfferStatus.rejecting;
                            final canAct = post.status == 'active' && offer.status == 'pending';
                            return Column(
                              children: [
                                OfferItemWidget(
                                  name: offer.establishmentName,
                                  pricePerUnit: '\$${offer.pricePerUnit.toStringAsFixed(2)}/${offer.unit}',
                                  pickupLabel: offer.pickupLabel,
                                  status: offer.status,
                                  isAccepting: isAccepting,
                                  isRejecting: isRejecting,
                                  onAccept: canAct
                                      ? () => _confirmAccept(
                                            postId: post.id,
                                            offer: offer,
                                          )
                                      : null,
                                  onReject: canAct
                                      ? () => _confirmReject(
                                            postId: post.id,
                                            offer: offer,
                                          )
                                      : null,
                                ),
                                Divider(color: colors.outline.withValues(alpha: 0.2)),
                              ],
                            );
                          }),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(post, colors, textTheme),
        ],
      ),
    );
  }

  Widget _buildBottomBar(WastePostDetail post, ColorScheme colors, TextTheme textTheme) {
    final deliveryLabel = post.deliveryMode == 'home_delivery'
        ? 'Recolección en casa'
        : post.deliveryMode == 'drop_off'
            ? 'Entrega en punto de acopio'
            : 'Recolección o entrega';

    final isReserved = post.status == 'reserved';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colors.surface,
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: colors.primary),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      deliveryLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: isReserved
                    ? () => context.push('/saleDetail/${post.id}')
                    : () {},
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          isReserved
                              ? 'Continuar con la venta'
                              : 'Ver todas las ofertas',
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(String status, TextTheme textTheme) {
    final info = PostStatusTranslator.translate(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: info.color,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        info.label,
        style: textTheme.bodySmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _deliveryModeBanner(String deliveryMode, TextTheme textTheme) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

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

  Widget _infoChip(IconData icon, String label, ColorScheme colors, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outline.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.06),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 6),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
