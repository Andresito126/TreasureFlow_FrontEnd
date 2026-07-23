import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class CategoryCardWidget extends StatelessWidget {
  final String title;
  final String? svgPath;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryCardWidget({
    super.key,
    required this.title,
    this.svgPath,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colors.primary.withOpacity(0.08) : colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? colors.primary : colors.outline,
            width: isSelected ? 1.6 : 1.2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (svgPath != null)
              SvgPicture.asset(svgPath!, width: 30, height: 30)
            else
              Icon(
                icon,
                size: 30,
                color: isSelected ? colors.primary : colors.onSurface,
              ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
