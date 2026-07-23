import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class InfoBannerWidget extends StatelessWidget {
  final IconData? icon;
  final String? svgPath;
  final String title;
  final String subtitle;

  const InfoBannerWidget({
    super.key,
    this.icon,
    this.svgPath,
    required this.title,
    required this.subtitle,
  }) : assert(icon != null || svgPath != null);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          svgPath != null
              ? SvgPicture.asset(svgPath!, width: 32, height: 32)
              : Icon(icon, size: 30, color: colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: colors.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
