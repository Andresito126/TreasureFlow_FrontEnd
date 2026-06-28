import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/image_gallery_widget.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/info_detail_card_widget.dart';
import 'package:treasureflow/features/posts/object/presentation/widgets/seller_card_widget.dart';
import 'package:treasureflow/features/posts/waste/presentation/widgets/location_preview_widget.dart';
import 'package:treasureflow/shared/widgets/condition_chip_widget.dart';
import 'package:treasureflow/shared/widgets/floating_nav_bar_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class ObjectDetailScreen extends StatefulWidget {
  const ObjectDetailScreen({super.key});

  @override
  State<ObjectDetailScreen> createState() => _ObjectDetailScreenState();
}

class _ObjectDetailScreenState extends State<ObjectDetailScreen> {
  int _currentNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ImageGalleryWidget(
                  imageUrls: ['1', '2', '3'],
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sillón de dos plazas',
                        style: textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$350',
                        style: textTheme.headlineLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colors.primary,
                          fontSize: 26,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined, size: 16, color: colors.onSurface.withValues(alpha: 0.6)),
                          const SizedBox(width: 4),
                          Text(
                            'Tuxtla Gutiérrez, a 2.3 km',
                            style: textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _infoChip(Icons.chair_outlined, 'Muebles', colors, textTheme),
                          _infoChip(Icons.auto_awesome, 'Buen estado', colors, textTheme),
                          _infoChip(Icons.access_time, 'Hace 2 días', colors, textTheme),
                        ],
                      ),
                      const SizedBox(height: 20),

                      PrimaryButtonGreenWidget(
                        text: 'Apartar objeto',
                        onPressed: () {},
                      ),
                      const SizedBox(height: 20),

                      InfoDetailCardWidget(
                        assetPath: 'assets/object/about_object_icon.png',
                        title: 'Sobre este objeto',
                        content: Text(
                          'Sillón en buen estado, le falta un cojín pero está completo y funcional. Ideal para la sala pequeña, sin manchas ni roturas en la tela.',
                          style: textTheme.bodySmall?.copyWith(
                            color: colors.onSurface.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
// los iconos de info detail card widget estan hasta rriba quiero que esten emedio de la card vaya y ma grande
                      InfoDetailCardWidget(
                        assetPath: 'assets/object/mod_entrega_icon.png',
                        title: 'Modalidad de entrega disponible',
                        content: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ConditionChipWidget(
                              label: 'Solo en mi domicilio',
                              isSelected: true,
                            ),
                            ConditionChipWidget(
                              label: 'Puedo llevarlo cerca',
                              isSelected: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      InfoDetailCardWidget(
                        assetPath: 'assets/object/zone_icon.png',
                        title: 'Zona de entrega',
                        content: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const LocationPreviewWidget(
                              location: LatLng(16.7625, -93.375),
                              address: 'Calle Siempre Viva 742, Col. Jardínes, Guadalajara, Jalisco',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      const SellerCardWidget(
                        name: 'Andre Julian Gutiérrez Alcazar',
                        phone: '+52 961 249 3893',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingNavBarWidget(
              currentIndex: _currentNavIndex,
              onTap: (index) => setState(() => _currentNavIndex = index),
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
