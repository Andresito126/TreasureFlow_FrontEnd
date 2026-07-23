import 'package:flutter/material.dart';


class RouteStopsHeaderWidget extends StatelessWidget {
  final int stopCount;
  final int totalDistanceMeters;

  const RouteStopsHeaderWidget({
    super.key,
    required this.stopCount,
    required this.totalDistanceMeters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Row(
      children: [
        Icon(Icons.route_rounded, size: 18, color: colors.primary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            'Paradas de la ruta ($stopCount)',
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          '${(totalDistanceMeters / 1000).toStringAsFixed(1)} km',
          style: textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colors.primary,
          ),
        ),
      ],
    );
  }
}
