import 'package:flutter/material.dart';
import 'package:treasureflow/core/maps/domain/entities/place.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class AddressCard extends StatelessWidget {
  final Place? place;
  final bool isEditing;
  final bool loadingAddress;
  final VoidCallback onEdit;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const AddressCard({
    super.key,
    required this.place,
    required this.isEditing,
    required this.loadingAddress,
    required this.onEdit,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface, // backgroundBoxLight / backgroundBoxDark
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: colors.shadow, // respeta el modo
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ── Icono izquierdo ──────────────────────────────────────
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: colors.outline.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.map_outlined,
                  color: colors.onSurface.withOpacity(0.7),
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: loadingAddress
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Obteniendo dirección...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.onSurface.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(height: 6),
                          LinearProgressIndicator(
                            backgroundColor: colors.outline.withOpacity(0.2),
                            color: colors.primary, // verde 0xFF418839
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dirección detectada',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place == null || place!.isEmpty
                                ? 'Sin datos de dirección'
                                : place!.line1,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: colors.onSurface,
                            ),
                          ),
                          if (place != null && place!.line2.isNotEmpty)
                            Text(
                              place!.line2,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colors.onSurface.withOpacity(0.6),
                              ),
                            ),
                        ],
                      ),
              ),

              // ── Botón editar (solo en modo vista) ────────────────────
              if (!isEditing)
                IconButton(
                  onPressed: onEdit,
                  icon: Icon(Icons.edit_outlined, color: colors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.primary.withOpacity(0.12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          Divider(height: 1, color: colors.outline.withOpacity(0.3)),

          const SizedBox(height: 12),

          Text(
            isEditing
                ? 'Mueve el mapa o busca una dirección para ajustar el pin'
                : 'Ajusta el pin en el mapa para mayor precisión',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withOpacity(0.5),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: PrimaryButtonBlueWidget(
                  text: 'Regresar',
                  onPressed: onBack,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: PrimaryButtonGreenWidget(
                  text: 'Siguiente',
                  onPressed: onNext,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
