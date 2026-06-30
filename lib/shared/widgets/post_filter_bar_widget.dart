import 'package:flutter/material.dart';

class PostFilterBarWidget extends StatelessWidget {
  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const PostFilterBarWidget({
    super.key,
    required this.filters,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = index == selectedIndex;

          return Padding(
            padding: EdgeInsets.only(right: index < filters.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onSelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected ? colors.primary : colors.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: isSelected
                      ? null
                      : Border.all(color: colors.primary.withValues(alpha: 0.15)),
                ),
                child: Text(
                  filters[index],
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isSelected ? colors.onPrimary : colors.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}