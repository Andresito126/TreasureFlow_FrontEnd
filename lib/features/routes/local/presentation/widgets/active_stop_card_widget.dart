import 'package:flutter/material.dart';

class ActiveStopCardWidget extends StatelessWidget {
  final int order;
  final String citizenName;
  final String addressLabel;
  final String? etaLabel;
  final bool hasPhone;
  final bool busy;
  final VoidCallback? onCall;
  final VoidCallback onOpenMaps;
  final VoidCallback onComplete;
  final VoidCallback onPostpone;

  const ActiveStopCardWidget({
    super.key,
    required this.order,
    required this.citizenName,
    required this.addressLabel,
    required this.hasPhone,
    required this.busy,
    required this.onOpenMaps,
    required this.onComplete,
    required this.onPostpone,
    this.etaLabel,
    this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.primary.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.primary,
                ),
                child: Text(
                  '$order',
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      citizenName,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      addressLabel,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.bodySmall?.copyWith(
                        fontSize: 11.5,
                        color: colors.onSurface.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              if (etaLabel != null) ...[
                const SizedBox(width: 8),
                Text(
                  etaLabel!,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colors.primary,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: (busy || !hasPhone) ? null : onCall,
                  icon: const Icon(Icons.phone_outlined, size: 16),
                  label: const Text('Llamar'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onOpenMaps,
                  icon: const Icon(Icons.navigation_outlined, size: 16),
                  label: const Text('Maps'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: busy ? null : onPostpone,
                  icon: const Icon(Icons.schedule_rounded, size: 16),
                  label: const Text('Posponer'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton.icon(
                  onPressed: busy ? null : onComplete,
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Completar'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
