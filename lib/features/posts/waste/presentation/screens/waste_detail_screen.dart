import 'package:flutter/material.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/image_gallery_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/info_banner_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/offer_item_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';

class WasteDetailScreen extends StatefulWidget {
  const WasteDetailScreen({super.key});

  @override
  State<WasteDetailScreen> createState() => _WasteDetailScreenState();
}

class _WasteDetailScreenState extends State<WasteDetailScreen> {
  int _currentNavIndex = 1;
  bool _descriptionExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const ImageGalleryWidget(
                        imageUrls: ['1', '2', '3'],
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Aluminio (latas)',
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Publicado por Carlos M.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.scale_outlined, size: 16, color: colors.onSurface.withValues(alpha: 0.6)),
                                const SizedBox(width: 6),
                                Text(
                                  '5 - 15 kg estimados',
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _infoChip(Icons.recycling, 'Aluminio', colors, textTheme),
                                _infoChip(Icons.location_on_outlined, '2.1 km', colors, textTheme),
                                _infoChip(Icons.access_time, 'Hace 4h', colors, textTheme),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: colors.primary.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.local_shipping_outlined, size: 16, color: colors.primary),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Disponible para recolección a domicilio',
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colors.primary,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Descripción',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Latas de aluminio limpias, aplastadas para ahorrar espacio. Aproximadamente 8kg de latas de bebidas (coca, refrescos, cerveza). Sin residuos líquidos ni comida.',
                              style: textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withValues(alpha: 0.7),
                              ),
                              maxLines: _descriptionExpanded ? null : 3,
                              overflow: _descriptionExpanded ? null : TextOverflow.ellipsis,
                            ),
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
                              icon: Icons.payments_outlined,
                              title: 'Las ofertas se calculan por kilogramo.',
                              subtitle: 'El monto final se confirma al pesar el material en la recolección.',
                            ),
                            const SizedBox(height: 20),

                            Text(
                              'Ofertas recibidas',
                              style: textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Divider(),
                            const OfferItemWidget(
                              name: 'EcoRecicla',
                              type: 'Centro de reciclaje',
                              pricePerKg: '\$8.50/kg',
                            ),
                            Divider(color: colors.outline.withValues(alpha: 0.2)),
                            const OfferItemWidget(
                              name: 'Verde Sustentable',
                              type: 'Planta de reciclaje',
                              pricePerKg: '\$8.00/kg',
                            ),
                            Divider(color: colors.outline.withValues(alpha: 0.2)),
                            const OfferItemWidget(
                              name: 'Recicla+',
                              type: 'Centro de acopio',
                              pricePerKg: '\$7.50/kg',
                            ),
                            const SizedBox(height: 12),

                            Center(
                              child: GestureDetector(
                                onTap: () {},
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Ver todas las ofertas (3)',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(Icons.arrow_forward, size: 14, color: colors.primary),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
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

          Positioned(
            left: 0,
            right: 0,
            bottom: 70,
            child: FloatingNavBarWidget(
              currentIndex: _currentNavIndex,
              onTap: (index) => setState(() => _currentNavIndex = index),
            ),
          ),
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
                        'Recolección en casa',
                        style: textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Tuxtla Gutiérrez, Chiapas',
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
                onTap: () {},
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
                        'Ver todas las ofertas',
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
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
