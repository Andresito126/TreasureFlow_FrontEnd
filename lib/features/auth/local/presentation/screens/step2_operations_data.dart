import 'package:flutter/material.dart';
import 'package:treasureflow/features/auth/local/presentation/widgets/operating_hours_selector.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/category_card_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class _MaterialItem {
  final String title;
  final String? svgPath;
  final IconData? icon;
  const _MaterialItem({required this.title, this.svgPath, this.icon});
}

class Step2OperationsData extends StatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const Step2OperationsData({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<Step2OperationsData> createState() => _Step2OperationsDataState();
}

class _Step2OperationsDataState extends State<Step2OperationsData> {
  static const List<_MaterialItem> _materials = [
    _MaterialItem(title: 'Aluminio', svgPath: 'assets/icons/aluminum.svg'),
    _MaterialItem(title: 'Aceite', svgPath: 'assets/icons/oil.svg'),
    _MaterialItem(title: 'Papel/Cartón', svgPath: 'assets/icons/cardboard.svg'),
    _MaterialItem(title: 'Plástico', svgPath: 'assets/icons/plastic.svg'),
    _MaterialItem(title: 'Metal', svgPath: 'assets/icons/metal.svg'),
    _MaterialItem(title: 'Pila/Batería', svgPath: 'assets/icons/battery.svg'),
    _MaterialItem(title: 'Otros', icon: Icons.more_horiz),
  ];

  final Set<String> _selectedMaterials = {};
  bool _offersPickup = true;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppCardContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionHeader(
                  context,
                  icon: Icons.access_time,
                  title: 'Horarios de atención',
                ),
                const SizedBox(height: 16),
                const OperatingHoursSelector(),

                _divider(colors),

                _sectionHeader(
                  context,
                  icon: Icons.recycling,
                  title: 'Materiales que aceptas',
                ),
                const SizedBox(height: 16),
                _buildMaterialsGrid(),

                _divider(colors),

                _buildVehicleSection(context),

                const SizedBox(height: 28),

                Row(
                  children: [
                    Expanded(
                      child: PrimaryButtonBlueWidget(
                        text: 'Regresar',
                        onPressed: widget.onBack,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: PrimaryButtonGreenWidget(
                        text: 'Siguiente',
                        onPressed: widget.onNext,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(icon, size: 18, color: colors.onSurface),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _divider(ColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Divider(height: 1, color: colors.outline.withOpacity(0.7)),
    );
  }

  Widget _buildMaterialsGrid() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = MediaQuery.sizeOf(context).width;
        final isTabletOrLandscape = screenWidth > 600;

        final int columns = isTabletOrLandscape ? 4 : 3;
        const double spacing = 10.0;
        final double totalSpacing = spacing * (columns - 1);
        final double cardWidth =
            (constraints.maxWidth - totalSpacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: _materials.map((material) {
            final isSelected = _selectedMaterials.contains(material.title);
            return SizedBox(
              width: cardWidth,
              height: 110,
              child: CategoryCardWidget(
                title: material.title,
                svgPath: material.svgPath,
                icon: material.icon,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedMaterials.remove(material.title);
                    } else {
                      _selectedMaterials.add(material.title);
                    }
                  });
                },
              ),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildVehicleSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.local_shipping_outlined,
              size: 18,
              color: colors.onSurface,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información sobre el vehículo',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '¿Cuentas con vehículo para recolección a domicilio?',
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.outline),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ofrece recolección a domicilio',
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Esto nos ayuda a conectarte con más personas',
                      style: textTheme.bodySmall?.copyWith(
                        color: colors.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Switch(
                value: _offersPickup,
                onChanged: (val) => setState(() => _offersPickup = val),
                activeColor: colors.onPrimary,
                activeTrackColor: colors.primary,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
