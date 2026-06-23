import 'package:flutter/material.dart';
// import 'package:treasureflow/shared/theme/app_theme_extension.dart';

class InputFieldWidget extends StatelessWidget {
  final String? textInput;
  final String hTPlaceHolder;
  final bool isPassword;
  final IconData? iconInput;
  final TextInputType? keyboardType;
  final TextEditingController? controller;

  const InputFieldWidget({
    super.key,
    this.textInput,
    required this.hTPlaceHolder,
    this.isPassword = false,
    this.iconInput,
    this.keyboardType,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final extTheme = theme.extension<AppThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (textInput != null && textInput!.isNotEmpty) ...[
          Text(
            textInput!,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
        ],

        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: iconInput != null
                ? Icon(iconInput, color: theme.colorScheme.primary)
                : null,

            hintText: hTPlaceHolder,
            hintStyle: theme.textTheme.bodySmall,
            filled: true,
            fillColor: theme.colorScheme.surface,
            contentPadding: const EdgeInsets.symmetric(
              vertical: 16.0,
              horizontal: 16.0,
            ),

            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: theme.colorScheme.outline,
                width: 1,
              ),
            ),

            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16.0),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
