import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:treasureflow/shared/layouts/app_card_container.dart';
import 'package:treasureflow/shared/widgets/primary_button_green_widget.dart';

class ConektaTokenException implements Exception {
  final String message;
  const ConektaTokenException(this.message);

  @override
  String toString() => 'ConektaTokenException: $message';
}

class CardPaymentFormWidget extends StatefulWidget {
  final double amount;
  final bool isLoading;

  final ValueChanged<String> onSubmit;

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
  String? _tokenizeError;
  bool _tokenizing = false;

  late final WebViewController _webViewController;
  Completer<String>? _pendingTokenization;
  final _pageLoaded = Completer<void>();
  bool _webViewReady = false;

  @override
  void initState() {
    super.initState();

    _pageLoaded.future.then((_) {
      if (mounted) setState(() => _webViewReady = true);
    });
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel('TokenResult', onMessageReceived: _onTokenResult)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (!_pageLoaded.isCompleted) _pageLoaded.complete();
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && !_pageLoaded.isCompleted) {
              _pageLoaded.completeError(
                ConektaTokenException(
                  'No se pudo abrir la pasarela de pago (${error.description}).',
                ),
              );
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/conekta/tokenizer.html');
  }

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    super.dispose();
  }

  void _onTokenResult(JavaScriptMessage message) {
    final completer = _pendingTokenization;
    if (completer == null || completer.isCompleted) return;

    final data = jsonDecode(message.message) as Map<String, dynamic>;
    if (data['id'] != null) {
      completer.complete(data['id'] as String);
    } else {
      completer.completeError(
        ConektaTokenException(
          data['error'] as String? ?? 'No se pudo procesar la tarjeta',
        ),
      );
    }
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

  Future<void> _submit() async {
    final number = _numberController.text.replaceAll(' ', '');
    final name = _nameController.text.trim();
    final expiry = _expiryController.text.trim();
    final cvc = _cvcController.text.trim();

    setState(() {
      _numberError = null;
      _nameError = null;
      _expiryError = null;
      _cvcError = null;
      _tokenizeError = null;
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
      final notExpired =
          year >= 0 && DateTime(2000 + year, month + 1).isAfter(DateTime.now());
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

    setState(() => _tokenizing = true);

    try {
      await _pageLoaded.future.timeout(
        const Duration(seconds: 45),
        onTimeout: () => throw const ConektaTokenException(
          'No se pudo cargar la pasarela de pago. Revisa tu conexión e intenta de nuevo.',
        ),
      );

      final publicKey = dotenv.env['CONEKTA_PUBLIC_KEY'] ?? '';
      final completer = Completer<String>();
      _pendingTokenization = completer;

      await _webViewController.runJavaScript(
        'tokenize('
        '${jsonEncode(publicKey)},'
        '${jsonEncode(number)},'
        '${jsonEncode(name)},'
        '${jsonEncode(expMonth.padLeft(2, '0'))},'
        '${jsonEncode(expYear)},'
        '${jsonEncode(cvc)}'
        ')',
      );

      final tokenId = await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw const ConektaTokenException(
          'La pasarela de pago tardó demasiado en responder. Intenta de nuevo.',
        ),
      );

      if (!mounted) return;
      widget.onSubmit(tokenId);
    } on ConektaTokenException catch (e) {
      if (!mounted) return;
      setState(() {
        _tokenizeError = e.message;
        _cvcController.clear();
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _tokenizeError = 'No se pudo procesar la tarjeta';
        _cvcController.clear();
      });
    } finally {
      _pendingTokenization = null;
      if (mounted) setState(() => _tokenizing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final textTheme = theme.textTheme;
    final isBusy = widget.isLoading || _tokenizing;

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
          if (!_webViewReady) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.primary.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Preparando pasarela de pago…',
                    style: textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: colors.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
          if (_tokenizeError != null) ...[
            const SizedBox(height: 10),
            Text(
              _tokenizeError!,
              style: textTheme.bodySmall?.copyWith(color: colors.error),
            ),
          ],
          const SizedBox(height: 20),
          PrimaryButtonGreenWidget(
            text: 'Pagar \$${widget.amount.toStringAsFixed(2)}',
            isLoading: isBusy,
            onPressed: _submit,
          ),

          SizedBox(
            width: 1,
            height: 1,
            child: WebViewWidget(controller: _webViewController),
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
          ? Icon(
              prefixIcon,
              size: 20,
              color: colors.onSurface.withValues(alpha: 0.4),
            )
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
