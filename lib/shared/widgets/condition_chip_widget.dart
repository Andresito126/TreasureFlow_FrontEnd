import 'package:flutter/material.dart';

class ConditionChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const ConditionChipWidget({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.primary.withValues(alpha: 0.08)
              : colors.surface,
          borderRadius: BorderRadius.circular(7),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: colors.onSurface,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
