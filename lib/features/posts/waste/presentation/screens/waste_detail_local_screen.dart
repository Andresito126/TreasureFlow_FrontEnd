import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/core/di/app_container.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/image_gallery_widget.dart';
import 'package:treasureflow/features/posts/waste/di/waste_post_module.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/my_offer.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/waste_post_detail.dart';
import 'package:treasureflow/features/posts/waste/presentation/providers/waste_detail_local_provider.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/info_banner_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/make_offer_card_widget.dart';
import 'package:treasureflow/shared/utils/material_type_translator.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';
import 'package:treasureflow/shared/widgets/image_viewer_screen.dart';

class WasteDetailLocalScreen extends StatefulWidget {
  final String postId;

  const WasteDetailLocalScreen({super.key, required this.postId});

  @override
  State<WasteDetailLocalScreen> createState() => _WasteDetailLocalScreenState();
}

class _WasteDetailLocalScreenState extends State<WasteDetailLocalScreen> {
  late final WasteDetailLocalProvider _provider;
  bool _descriptionExpanded = false;
  final _priceController = TextEditingController();
  String _selectedUnit = 'kg';
  bool _offerPrefilled = false;

  @override
  void initState() {
    super.initState();
    _provider = WastePostModule(context.read<AppContainer>()).provideDetailLocalProvider();
    _provider.addListener(_prefillOfferOnce);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.load(widget.postId);
    });
  }

  void _prefillOfferOnce() {
    if (_offerPrefilled) return;
    final offer = _provider.post?.myOffer;
    if (offer == null) return;
    _offerPrefilled = true;
    _priceController.text = offer.pricePerUnit.toString();
    setState(() => _selectedUnit = offer.unit);
  }

  @override
  void dispose() {
    _provider.removeListener(_prefillOfferOnce);
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _onSendOffer() async {
    final priceText = _priceController.text.trim();
    if (priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el precio que ofreces')),
      );
      return;
    }

    final price = double.tryParse(priceText);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un precio válido')),
      );
      return;
    }

    final confirmed = await _showConfirmDialog(priceText);
    if (confirmed != true || !mounted) return;

    final success = await _provider.createOffer(
      postId: widget.postId,
      pricePerUnit: price,
      unit: _selectedUnit,
    );

    if (!mounted) return;

    if (success) {
      _priceController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Oferta enviada correctamente')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_provider.offerError ?? 'Error al enviar la oferta'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
      _provider.resetOfferStatus();
    }
  }

  Future<bool?> _showConfirmDialog(String price) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Confirmar oferta',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        content: Text(
          '¿Seguro que quieres ofertar \$$price/$_selectedUnit para este residuo?',
          style: textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: colors.primary),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _provider,
      child: Consumer<WasteDetailLocalProvider>(
        builder: (context, provider, _) {
          if (provider.status == WasteDetailLocalStatus.loading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          if (provider.status == WasteDetailLocalStatus.error) {
            return Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(provider.errorMessage ?? 'Error al cargar'),
              ),
            );
          }

          final post = provider.post;
          if (post == null) return const Scaffold(body: SizedBox.shrink());

          return _buildContent(context, post, provider);
        },
      ),
    );
  }

  Widget _buildContent(
      BuildContext context, WastePostDetail post, WasteDetailLocalProvider provider) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _provider.load(widget.postId),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageGalleryWidget(
                    imageUrls: post.photoUrls,
                    onImageTap: (index) => Navigator.of(context).push(
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
                                MaterialTypeTranslator.translate(post.materialTypeName),
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusBadge(post.status, textTheme),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _infoChip(Icons.recycling,
                                MaterialTypeTranslator.translate(post.materialTypeName),
                                colors, textTheme),
                            if (post.distance != null)
                              _infoChip(Icons.location_on_outlined,
                                  post.distance!, colors, textTheme),
                            _infoChip(Icons.access_time,
                                post.publishedAt, colors, textTheme),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _deliveryModeBanner(post.deliveryMode, textTheme, colors),

                        const SizedBox(height: 20),

                        Text(
                          'Descripción',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          post.description,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: _descriptionExpanded ? null : 3,
                          overflow:
                              _descriptionExpanded ? null : TextOverflow.ellipsis,
                        ),
                        GestureDetector(
                          onTap: () => setState(
                            () => _descriptionExpanded = !_descriptionExpanded,
                          ),
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
                          subtitle:
                              'El monto final se confirma al pesar el material en la recolección.',
                        ),
                        const SizedBox(height: 20),

                        if (post.myOffer != null)
                          _existingOfferBanner(post.myOffer!, colors, textTheme),

                        if (post.myOffer != null) const SizedBox(height: 16),

                        MakeOfferCardWidget(
                          priceController: _priceController,
                          isLoading: provider.isSubmitting,
                          onSubmit: _onSendOffer,
                          selectedUnit: _selectedUnit,
                          onUnitChanged: (unit) =>
                              setState(() => _selectedUnit = unit),
                          buttonLabel: post.myOffer != null ? 'Actualizar oferta' : 'Enviar oferta',
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
          _buildBottomBar(post, colors, textTheme, provider),
        ],
      ),
    );
  }

  Widget _buildBottomBar(WastePostDetail post, ColorScheme colors,
      TextTheme textTheme, WasteDetailLocalProvider provider) {
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
            if (post.distance != null)
              Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: colors.primary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Distancia: ${post.distance}',
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
                onTap: provider.isSubmitting ? null : _onSendOffer,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: provider.isSubmitting
                        ? colors.primary.withValues(alpha: 0.5)
                        : colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (provider.isSubmitting)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      else ...[
                        Text(
                          post.myOffer != null ? 'Actualizar oferta' : 'Confirmar oferta',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16, color: Colors.white),
                      ],
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

  Widget _existingOfferBanner(MyOffer offer, ColorScheme colors, TextTheme textTheme) {
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
          Icon(isAccepted ? Icons.check_circle_outline : Icons.local_offer_outlined,
              size: 20, color: color),
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
              ],
            ),
          ),
        ],
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

  Widget _deliveryModeBanner(
      String deliveryMode, TextTheme textTheme, ColorScheme colors) {
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

  Widget _infoChip(
      IconData icon, String label, ColorScheme colors, TextTheme textTheme) {
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
          Text(label, style: textTheme.bodySmall?.copyWith(fontSize: 11)),
        ],
      ),
    );
  }
}
