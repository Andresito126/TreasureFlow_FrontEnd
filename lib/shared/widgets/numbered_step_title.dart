import 'package:flutter/material.dart';

class NumberedStepTitle extends StatelessWidget {
  final String stepNumber;
  final String title;
  final double fontSize;

  const NumberedStepTitle({
    super.key,
    required this.stepNumber,
    required this.title,
    required this.fontSize
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 25,
          height: 25,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            stepNumber,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 10),
        
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}