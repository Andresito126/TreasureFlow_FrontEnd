import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:treasureflow/shared/theme/app_theme_extension.dart';

class InputFieldWidget extends StatelessWidget {
  final String? textInput;
  final String hTPlaceHolder;
  final bool isPassword;
  final IconData? iconInput;
  final TextInputType? keyboardType;
  final TextEditingController? controller;
  final String? prefixText;
  final String? Function(String?)? validator;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;

  const InputFieldWidget({
    super.key,
    this.textInput,
    required this.hTPlaceHolder,
    this.isPassword = false,
    this.iconInput,
    this.keyboardType,
    this.controller,
    this.prefixText,
    this.validator,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final extTheme = theme.extension<AppThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (textInput != null && textInput!.isNotEmpty) ...[
          Text(textInput!, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
        ],

        TextFormField(
          controller: controller,
          obscureText: isPassword,
          keyboardType: keyboardType,
          validator: validator,
          maxLength: maxLength,
          buildCounter: maxLength != null
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => null
              : null,
          inputFormatters: inputFormatters,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: (iconInput != null || prefixText != null)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (iconInput != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Icon(
                            iconInput,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      if (prefixText != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 4),
                          child: Text(
                            prefixText!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  )
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
