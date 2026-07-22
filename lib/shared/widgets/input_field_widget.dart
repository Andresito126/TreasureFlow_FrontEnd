import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:treasureflow/shared/theme/app_theme_extension.dart';

class InputFieldWidget extends StatefulWidget {
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
  State<InputFieldWidget> createState() => _InputFieldWidgetState();
}

class _InputFieldWidgetState extends State<InputFieldWidget> {
  late bool _obscured;

  @override
  void initState() {
    super.initState();
    _obscured = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final extTheme = theme.extension<AppThemeExtension>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.textInput != null && widget.textInput!.isNotEmpty) ...[
          Text(widget.textInput!, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
        ],

        TextFormField(
          controller: widget.controller,
          obscureText: _obscured,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          maxLength: widget.maxLength,
          buildCounter: widget.maxLength != null
              ? (
                  context, {
                  required currentLength,
                  required isFocused,
                  required maxLength,
                }) => null
              : null,
          inputFormatters: widget.inputFormatters,
          style: theme.textTheme.bodyMedium,
          decoration: InputDecoration(
            prefixIcon: (widget.iconInput != null || widget.prefixText != null)
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.iconInput != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Icon(
                            widget.iconInput,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      if (widget.prefixText != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 8, right: 4),
                          child: Text(
                            widget.prefixText!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  )
                : null,

            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscured
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                    onPressed: () => setState(() => _obscured = !_obscured),
                    tooltip: _obscured
                        ? 'Mostrar contraseña'
                        : 'Ocultar contraseña',
                  )
                : null,

            hintText: widget.hTPlaceHolder,
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
