import 'package:flutter/material.dart';
import 'package:treasureflow/features/posts/waste/domain/entities/available_slot.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/utils/pickup_label_formatter.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

const _units = ['kg', 'g', 'l', 'ml', 'unidades'];

class MakeOfferCardWidget extends StatelessWidget {
  final TextEditingController priceController;
  final VoidCallback onSubmit;
  final bool isLoading;
  final String selectedUnit;
  final ValueChanged<String> onUnitChanged;
  final String buttonLabel;

  final DateTime? selectedDate;
  final TimeOfDay? startTime;
  final TimeOfDay? endTime;
  final VoidCallback onPickDate;
  final VoidCallback onPickStartTime;
  final VoidCallback onPickEndTime;
  final AvailableSlot? matchingSlot;
  final bool slotsLoading;

  const MakeOfferCardWidget({
    super.key,
    required this.priceController,
    required this.onSubmit,
    required this.selectedUnit,
    required this.onUnitChanged,
    required this.onPickDate,
    required this.onPickStartTime,
    required this.onPickEndTime,
    this.selectedDate,
    this.startTime,
    this.endTime,
    this.matchingSlot,
    this.slotsLoading = false,
    this.isLoading = false,
    this.buttonLabel = 'Enviar oferta',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Haz tu oferta',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Precio, unidad y día de recolección',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 14),

          // Unit selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _units.map((unit) {
                final isSelected = unit == selectedUnit;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onUnitChanged(unit),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? colors.primary
                              : colors.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        unit,
                        style: textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? colors.onPrimary
                              : colors.onSurface.withValues(alpha: 0.7),
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Price field
          TextField(
            controller: priceController,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Ej. 8.50',
              suffixText: '/$selectedUnit',
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.outline),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.primary, width: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 18),
          Text(
            'Fecha y horario de recolección',
            style: textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Solo aparecen los días en que tu establecimiento trabaja',
            style: textTheme.bodySmall?.copyWith(
              fontSize: 11,
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 10),

          // Date selector chip
          GestureDetector(
            onTap: slotsLoading ? null : onPickDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: selectedDate != null
                    ? colors.primary.withValues(alpha: 0.06)
                    : colors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedDate != null
                      ? colors.primary.withValues(alpha: 0.5)
                      : colors.outline,
                ),
              ),
              child: Row(
                children: [
                  if (slotsLoading)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.onSurface.withValues(alpha: 0.4),
                      ),
                    )
                  else
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: selectedDate != null
                          ? colors.primary
                          : colors.onSurface.withValues(alpha: 0.5),
                    ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      slotsLoading
                          ? 'Cargando días disponibles...'
                          : selectedDate != null
                              ? formatPickupLabel(
                                  _dateToIso(selectedDate!), '', '')
                              : 'Seleccionar día de recolección',
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontWeight: selectedDate != null
                            ? FontWeight.w600
                            : FontWeight.normal,
                        color: slotsLoading || selectedDate == null
                            ? colors.onSurface.withValues(alpha: 0.5)
                            : colors.primary,
                      ),
                    ),
                  ),
                  if (!slotsLoading)
                    Icon(
                      Icons.expand_more,
                      size: 18,
                      color: colors.onSurface.withValues(alpha: 0.4),
                    ),
                ],
              ),
            ),
          ),

          // Time pickers — solo visibles cuando hay fecha seleccionada
          if (selectedDate != null) ...[
            const SizedBox(height: 10),

            // Referencia del horario laboral del día
            if (matchingSlot != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        size: 13,
                        color: colors.onSurface.withValues(alpha: 0.45)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Horario laboral ese día: ${matchingSlot!.start} – ${matchingSlot!.end}',
                        style: textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          color: colors.onSurface.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              children: [
                Expanded(
                  child: _pickerChip(
                    context,
                    icon: Icons.schedule,
                    label: startTime != null
                        ? 'Desde ${_formatTime(startTime!)}'
                        : 'Hora inicio',
                    isSet: startTime != null,
                    onTap: onPickStartTime,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _pickerChip(
                    context,
                    icon: Icons.schedule,
                    label: endTime != null
                        ? 'Hasta ${_formatTime(endTime!)}'
                        : 'Hora fin',
                    isSet: endTime != null,
                    onTap: onPickEndTime,
                  ),
                ),
              ],
            ),

            // Indicador de ocupación
            if (matchingSlot != null) ...[
              const SizedBox(height: 10),
              _occupancyIndicator(matchingSlot!, colors, textTheme),
            ],
          ],

          const SizedBox(height: 16),
          PrimaryButtonGreenWidget(
            text: buttonLabel,
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }

  Widget _pickerChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isSet,
    required VoidCallback onTap,
  }) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: isSet
              ? colors.primary.withValues(alpha: 0.06)
              : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSet
                ? colors.primary.withValues(alpha: 0.5)
                : colors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSet
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: textTheme.bodySmall?.copyWith(
                  fontWeight: isSet ? FontWeight.w600 : FontWeight.normal,
                  color: isSet
                      ? colors.primary
                      : colors.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _occupancyIndicator(
      AvailableSlot slot, ColorScheme colors, TextTheme textTheme) {
    final isFull = slot.isFull;
    final color = isFull ? const Color(0xFFE8930C) : const Color(0xFF2D7D46);
    final text = isFull
        ? 'Ese día ya tienes ${slot.maxSlots} recolecciones agendadas. '
            'Puedes continuar, pero considera elegir otro día.'
        : '${slot.slotsUsed} de ${slot.maxSlots} recolecciones agendadas ese día';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            isFull ? Icons.warning_amber_rounded : Icons.event_available,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: textTheme.bodySmall?.copyWith(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _dateToIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  static String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
}
