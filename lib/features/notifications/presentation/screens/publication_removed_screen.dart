import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class PublicationRemovedScreen extends StatelessWidget {
  const PublicationRemovedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: colors.errorContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.shield_outlined,
                  size: 48,
                  color: colors.error,
                ),
              ),

              const SizedBox(height: 28),

              Text(
                'Publicación eliminada',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                'Tu publicación fue eliminada porque no cumple con las políticas de contenido de TreasureFlow.',
                style: textTheme.bodyMedium?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.6),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 28),

              _PolicyItem(
                icon: Icons.image_not_supported_outlined,
                label: 'Imágenes inapropiadas o con contenido adulto',
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: 10),
              _PolicyItem(
                icon: Icons.warning_amber_outlined,
                label: 'Contenido violento o que promueve el daño',
                colors: colors,
                textTheme: textTheme,
              ),
              const SizedBox(height: 10),
              _PolicyItem(
                icon: Icons.block_outlined,
                label: 'Material que no corresponde a residuos reciclables',
                colors: colors,
                textTheme: textTheme,
              ),

              const SizedBox(height: 36),

              Text(
                'Si crees que esto fue un error, puedes volver a publicar con imágenes diferentes.',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface.withValues(alpha: 0.45),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              PrimaryButtonGreenWidget(
                text: 'Entendido',
                onPressed: () => context.go('/homeCitizen'),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _PolicyItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colors;
  final TextTheme textTheme;

  const _PolicyItem({
    required this.icon,
    required this.label,
    required this.colors,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: colors.errorContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: colors.error),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }
}
