import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

/// Datos de tarjeta validados, listos para tokenizar.
class CardFormData {
  final String cardNumber;
  final String holderName;
  final String expMonth;
  final String expYear;
  final String cvc;

  const CardFormData({
    required this.cardNumber,
    required this.holderName,
    required this.expMonth,
    required this.expYear,
    required this.cvc,
  });
}

/// Formulario de tarjeta. Los datos se tokenizan directo contra Conekta —
/// nunca pasan por el backend de TreasureFlow.
class CardPaymentFormWidget extends StatefulWidget {
  final double amount;
  final bool isLoading;
  final ValueChanged<CardFormData> onSubmit;

  const CardPaymentFormWidget({
    super.key,
    required this.amount,
    required this.isLoading,
    required this.onSubmit,
  });

  @override
  State<CardPaymentFormWidget> createState() => _CardPaymentFormWidgetState();
}

class _CardPaymentFormWidgetState extends State<CardPaymentFormWidget> {
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();

  String? _numberError;
  String? _nameError;
  String? _expiryError;
  String? _cvcError;

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  /// Limpia campos sensibles (llamado por el padre tras un intento fallido).
  void clearSensitiveFields() {
    _cvcController.clear();
  }

  bool _luhnValid(String digits) {
    var sum = 0;
    var alternate = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      var d = int.parse(digits[i]);
      if (alternate) {
        d *= 2;
        if (d > 9) d -= 9;
      }
      sum += d;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  void _submit() {
    final number = _numberController.text.replaceAll(' ', '');
    final name = _nameController.text.trim();
    final expiry = _expiryController.text.trim();
    final cvc = _cvcController.text.trim();

    setState(() {
      _numberError = null;
      _nameError = null;
      _expiryError = null;
      _cvcError = null;
    });

    var valid = true;

    if (number.length < 13 || number.length > 19 || !_luhnValid(number)) {
      setState(() => _numberError = 'Número de tarjeta inválido');
      valid = false;
    }

    if (name.isEmpty) {
      setState(() => _nameError = 'Ingresa el nombre del titular');
      valid = false;
    }

    final expiryParts = expiry.split('/');
    String expMonth = '', expYear = '';
    if (expiryParts.length == 2) {
      expMonth = expiryParts[0];
      expYear = expiryParts[1];
      final month = int.tryParse(expMonth) ?? 0;
      final year = int.tryParse(expYear) ?? -1;
      final notExpired = year >= 0 &&
          DateTime(2000 + year, month + 1).isAfter(DateTime.now());
      if (month < 1 || month > 12 || !notExpired) {
        setState(() => _expiryError = 'Fecha inválida o vencida');
        valid = false;
      }
    } else {
      setState(() => _expiryError = 'Usa el formato MM/AA');
      valid = false;
    }

    if (cvc.length < 3 || cvc.length > 4) {
      setState(() => _cvcError = 'CVC inválido');
      valid = false;
    }

    if (!valid) return;

    widget.onSubmit(CardFormData(
      cardNumber: number,
      holderName: name,
      expMonth: expMonth.padLeft(2, '0'),
      expYear: expYear,
      cvc: cvc,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.credit_card_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Datos de la tarjeta',
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.lock_outline_rounded,
                size: 15,
                color: colors.onSurface.withValues(alpha: 0.4),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Procesado de forma segura por Conekta.',
            style: textTheme.bodySmall?.copyWith(
              color: colors.onSurface.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Número de tarjeta'),
          TextFormField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(19),
              _CardNumberInputFormatter(),
            ],
            decoration: _inputDecoration(
              context,
              hint: '4242 4242 4242 4242',
              errorText: _numberError,
              prefixIcon: Icons.credit_card_rounded,
            ),
          ),
          const SizedBox(height: 14),
          _fieldLabel('Nombre del titular'),
          TextFormField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: _inputDecoration(
              context,
              hint: 'Como aparece en la tarjeta',
              errorText: _nameError,
              prefixIcon: Icons.person_outline_rounded,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('Vencimiento'),
                    TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateInputFormatter(),
                      ],
                      decoration: _inputDecoration(
                        context,
                        hint: 'MM/AA',
                        errorText: _expiryError,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _fieldLabel('CVC'),
                    TextFormField(
                      controller: _cvcController,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      decoration: _inputDecoration(
                        context,
                        hint: '123',
                        errorText: _cvcError,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          PrimaryButtonGreenWidget(
            text: 'Pagar \$${widget.amount.toStringAsFixed(2)}',
            isLoading: widget.isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(
    BuildContext context, {
    required String hint,
    String? errorText,
    IconData? prefixIcon,
  }) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      isDense: true,
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 20, color: colors.onSurface.withValues(alpha: 0.4))
          : null,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outline.withValues(alpha: 0.4)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.error, width: 1.5),
      ),
    );
  }
}

/// Agrupa el número en bloques de 4: `4242 4242 4242 4242`
class _CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Fuerza el formato `MM/AA` mientras se escribe.
class _ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
