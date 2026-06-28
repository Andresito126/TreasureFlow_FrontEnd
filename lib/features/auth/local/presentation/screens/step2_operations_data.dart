import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:treasureflow/features/auth/local/domain/entities/operating_schedule.dart';
import 'package:treasureflow/features/auth/local/presentation/providers/register_local_provider.dart';
import 'package:treasureflow/features/auth/local/presentation/widgets/operating_hours_selector.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/category_card_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class _MaterialItem {
  final String id;
  final String title;
  final String? svgPath;
  final IconData? icon;
  const _MaterialItem({
    required this.id,
    required this.title,
    this.svgPath,
    this.icon,
  });
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

class _Step2OperationsDataState extends State<Step2OperationsData>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  static const List<_MaterialItem> _materials = [
    _MaterialItem(
      id: 'e78a20e5-a69d-4edb-bf50-33831f9aae6e',
      title: 'Aluminio',
      svgPath: 'assets/icons/aluminum.svg',
    ),
    _MaterialItem(
      id: '2e532ca8-c6de-465d-af27-c2465b74f14c',
      title: 'Aceite',
      svgPath: 'assets/icons/oil.svg',
    ),
    _MaterialItem(
      id: '1be3bf83-8b1a-421c-8474-a72785bf80b5',
      title: 'Papel/Cartón',
      svgPath: 'assets/icons/cardboard.svg',
    ),
    _MaterialItem(
      id: 'caa8cf7a-d5f6-4ae6-a9aa-ea92bdf4b334',
      title: 'Plástico',
      svgPath: 'assets/icons/plastic.svg',
    ),
    _MaterialItem(
      id: '918a523e-655b-4f53-bd86-2d43c2618be5',
      title: 'Metal',
      svgPath: 'assets/icons/metal.svg',
    ),
    _MaterialItem(
      id: '37962e6b-8f0a-4dd7-9e5d-0db74d021313',
      title: 'Pila/Batería',
      svgPath: 'assets/icons/battery.svg',
    ),
  ];

  List<DaySchedule> _daySchedules = [];

  void _onScheduleChanged(List<DaySchedule> days) {
    _daySchedules = days;
  }

  void _onNext() {
    final provider = context.read<RegisterLocalProvider>();

    if (provider.selectedMaterialIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un material')),
      );
      return;
    }

    final schedules = <OperatingSchedule>[];
    for (int i = 0; i < _daySchedules.length; i++) {
      final day = _daySchedules[i];
      if (!day.isOpen) continue;
      for (final range in day.ranges) {
        final startStr =
            '${range.start.hour.toString().padLeft(2, '0')}:${range.start.minute.toString().padLeft(2, '0')}';
        final endStr =
            '${range.end.hour.toString().padLeft(2, '0')}:${range.end.minute.toString().padLeft(2, '0')}';
        schedules.add(
          OperatingSchedule(
            dayOfWeek: i + 1,
            startTime: startStr,
            endTime: endStr,
          ),
        );
      }
    }

    provider.setSchedules(schedules);
    widget.onNext();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
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
                OperatingHoursSelector(onChanged: _onScheduleChanged),

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
                        onPressed: _onNext,
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
    return Consumer<RegisterLocalProvider>(
      builder: (context, provider, _) {
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
                final isSelected = provider.selectedMaterialIds.contains(
                  material.id,
                );
                return SizedBox(
                  width: cardWidth,
                  height: 110,
                  child: CategoryCardWidget(
                    title: material.title,
                    svgPath: material.svgPath,
                    icon: material.icon,
                    isSelected: isSelected,
                    onTap: () => provider.toggleMaterial(material.id),
                  ),
                );
              }).toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildVehicleSection(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Consumer<RegisterLocalProvider>(
      builder: (context, provider, _) {
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
                    value: provider.hasVehicle,
                    onChanged: (val) => provider.setHasVehicle(val),
                    activeColor: colors.onPrimary,
                    activeTrackColor: colors.primary,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
