import 'package:flutter/material.dart';

class SettingsTileWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool showDivider;

  const SettingsTileWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 18, color: colors.onPrimary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: textTheme.bodySmall?.copyWith(
                          color: colors.onSurface.withValues(alpha: 0.5),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: colors.onSurface.withValues(alpha: 0.4)),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, indent: 14, endIndent: 14, color: colors.outline.withValues(alpha: 0.15)),
      ],
    );
  }
}
