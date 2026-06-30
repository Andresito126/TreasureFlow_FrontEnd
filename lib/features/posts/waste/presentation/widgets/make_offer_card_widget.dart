import 'package:flutter/material.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class MakeOfferCardWidget extends StatelessWidget {
  final TextEditingController priceController;
  final VoidCallback onSubmit;
  final bool isLoading;

  const MakeOfferCardWidget({
    super.key,
    required this.priceController,
    required this.onSubmit,
    this.isLoading = false,
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
            'Ingresa el precio que estás dispuesto a pagar por kilogramo',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              prefixText: '\$ ',
              hintText: 'Ej. 8.50',
              suffixText: '/kg',
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
          const SizedBox(height: 16),
          PrimaryButtonGreenWidget(
            text: 'Enviar oferta',
            isLoading: isLoading,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
