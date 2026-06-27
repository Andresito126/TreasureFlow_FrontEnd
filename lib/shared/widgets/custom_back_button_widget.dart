import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBackButtonWidget extends StatelessWidget {
  final VoidCallback? onTap;

  const CustomBackButtonWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Align(
      alignment: Alignment.centerLeft,
      child: InkWell(
        onTap:
            onTap ??
            () {
              if (context.canPop()) {
                context.pop();
              }
            },
        borderRadius: BorderRadius.circular(50),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: colors.primary,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}
