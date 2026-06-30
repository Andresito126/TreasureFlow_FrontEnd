import 'package:flutter/material.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/image_gallery_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/info_banner_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/make_offer_card_widget.dart';
import 'package:treasureflow/shared/utils/post_status_translator.dart';
import 'package:treasureflow/shared/widgets/image_viewer_screen.dart';

class WasteDetailLocalScreen extends StatefulWidget {
  final String postId;

  const WasteDetailLocalScreen({super.key, required this.postId});

  @override
  State<WasteDetailLocalScreen> createState() => _WasteDetailLocalScreenState();
}

class _WasteDetailLocalScreenState extends State<WasteDetailLocalScreen> {
  bool _descriptionExpanded = false;
  final _priceController = TextEditingController();
  bool _isSubmitting = false;

  static const _photoUrls = <String>['1', '2', '3'];
  static const _title = 'Aluminio (latas)';
  static const _description =
      'Latas de aluminio limpias, aplastadas para ahorrar espacio. Aproximadamente 8kg de latas de bebidas (coca, refrescos, cerveza). Sin residuos líquidos ni comida.';
  static const _materialName = 'Aluminio';
  static const _distance = '2.1 km';
  static const _publishedAt = 'hace 4h';
  static const _status = 'active';
  static const _deliveryMode = 'home_delivery';
  static const _address = 'Tuxtla Gutiérrez, Chiapas';

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _onSendOffer() async {
    final price = _priceController.text.trim();
    if (price.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el precio que ofreces')),
      );
      return;
    }

    final confirmed = await _showConfirmDialog(price);
    if (confirmed != true || !mounted) return;

    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() => _isSubmitting = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Oferta de \$$price/kg enviada')));
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
          '¿Seguro que quieres ofertar \$$price por kilogramo para este residuo?',
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ImageGalleryWidget(
                    imageUrls: _photoUrls,
                    onImageTap: (index) => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ImageViewerScreen(
                          imageUrls: _photoUrls,
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
                                _title,
                                style: textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _statusBadge(textTheme),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Publicado por Carlos M.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            _infoChip(
                              Icons.recycling,
                              _materialName,
                              colors,
                              textTheme,
                            ),
                            _infoChip(
                              Icons.location_on_outlined,
                              _distance,
                              colors,
                              textTheme,
                            ),
                            _infoChip(
                              Icons.access_time,
                              _publishedAt,
                              colors,
                              textTheme,
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        _deliveryModeBanner(textTheme),

                        const SizedBox(height: 20),

                        Text(
                          'Descripción',
                          style: textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _description,
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                          maxLines: _descriptionExpanded ? null : 3,
                          overflow: _descriptionExpanded
                              ? null
                              : TextOverflow.ellipsis,
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

                        MakeOfferCardWidget(
                          priceController: _priceController,
                          isLoading: _isSubmitting,
                          onSubmit: _onSendOffer,
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomBar(colors, textTheme),
        ],
      ),
    );
  }

  Widget _buildBottomBar(ColorScheme colors, TextTheme textTheme) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: colors.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Distancia: $_distance',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _address,
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: _onSendOffer,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Confirmar oferta',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: Colors.white,
                      ),
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

  Widget _statusBadge(TextTheme textTheme) {
    final info = PostStatusTranslator.translate(_status);
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

  Widget _deliveryModeBanner(TextTheme textTheme) {
    final colors = Theme.of(context).colorScheme;

    final (icon, label, color) = switch (_deliveryMode) {
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
    IconData icon,
    String label,
    ColorScheme colors,
    TextTheme textTheme,
  ) {
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
