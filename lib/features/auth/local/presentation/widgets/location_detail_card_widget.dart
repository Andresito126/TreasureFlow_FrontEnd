import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class LocationDetailCard extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onEditAddress;

  const LocationDetailCard({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.onEditAddress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.1),
                  child: const Icon(Icons.map_outlined, color: Colors.white70),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Dirección detectada",
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Av. Nuevo León 123\nCol. Condesa, Cuauhtémoc, 06100, CMDX",
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onEditAddress,
                  icon: Icon(Icons.edit_square, color: colors.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: colors.onSurface.withOpacity(0.05),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),

            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16.0),
              child: Divider(color: Colors.white12, height: 1),
            ),

            Text(
              "Ajusta el pin en el mapa para mayor precisión",
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface.withOpacity(0.5),
              ),
            ),

            const SizedBox(height: 16),

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
      ),
    );
  }
}
