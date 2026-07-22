import 'package:flutter/material.dart';
import 'package:treasureflow/core/notifications/domain/entities/notification_payload.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class PickupDetailScreen extends StatelessWidget {
  final NotificationPayload? payload;

  const PickupDetailScreen({super.key, this.payload});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    final title = (payload?.title.isNotEmpty ?? false)
        ? payload!.title
        : 'Actualización de tu recolección';
    final body = (payload?.body.isNotEmpty ?? false)
        ? payload!.body
        : 'Tienes una novedad relacionada con tu recolección.';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        title: const Text('Tu recolección'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCardContainer(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_shipping_outlined,
                          size: 20,
                          color: colors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            title,
                            style: textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: textTheme.bodyMedium?.copyWith(
                        color: colors.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              PrimaryButtonGreenWidget(
                text: 'Entendido',
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
