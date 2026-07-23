import 'package:flutter/material.dart';
import 'package:treasureflow/shared/widgets/primary_button_blue_widget.dart';

class RouteErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback onRetry;

  const RouteErrorView({super.key, this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, size: 48, color: colors.error),
            const SizedBox(height: 16),
            Text(
              message ?? 'No se pudo cargar la ruta',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            PrimaryButtonBlueWidget(text: 'Reintentar', onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
