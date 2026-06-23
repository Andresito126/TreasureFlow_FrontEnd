import 'package:flutter/material.dart';

class AuthFeatureItemWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AuthFeatureItemWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Column(
      children: [
        Icon(icon, color: colors.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          title, 
          style: textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          textAlign: TextAlign.center,
          style: textTheme.labelSmall,
        ),
      ],
    );
  }
}