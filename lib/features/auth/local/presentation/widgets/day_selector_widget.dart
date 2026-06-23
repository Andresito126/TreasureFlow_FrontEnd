import 'package:flutter/material.dart';

class DaySelectorWidget extends StatelessWidget {
  const DaySelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final days = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(days.length, (index) {
        final isSelected = index < 5; 
        return Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? colors.primary : Colors.transparent,
            shape: BoxShape.circle,
            border: isSelected ? null : Border.all(color: colors.outline),
          ),
          child: Center(
            child: Text(
              days[index],
              style: theme.textTheme.bodyMedium,
            ),
          ),
        );
      }),
    );
  }
}