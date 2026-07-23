import 'package:flutter/material.dart';

class ScreenHeaderWidget extends StatelessWidget {
  final String titlePrefix;
  final String? titleHighlight;
  final String? subtitle;

  const ScreenHeaderWidget({
    super.key,
    required this.titlePrefix,
    this.titleHighlight,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: titlePrefix,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
            children: [
              TextSpan(
                text: titleHighlight,
                style: TextStyle(color: colors.primary),
              ),
            ],
          ),
        ),

        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(
            subtitle!,
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}
