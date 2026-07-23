import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class SelectionCardWidget extends StatelessWidget {
  final String title;
  final String svgPath;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectionCardWidget({
    super.key,
    required this.title,
    required this.svgPath,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor = isSelected
        ? theme.colorScheme.primary.withValues(alpha: 0.08)
        : theme.colorScheme.surface;          

    final borderColor = isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.outline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isSelected ? 1.5 : 1.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 10,
        children: [
          SvgPicture.asset(
            svgPath,
            width: 30,
            height: 30,
          ),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}