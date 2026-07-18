import 'dart:convert';

import 'package:http/http.dart' as http;

class ConektaTokenException implements Exception {
  final String message;
  final String? code;

  const ConektaTokenException(this.message, {this.code});

  @override
  String toString() => 'ConektaTokenException($code): $message';
}

/// Tokeniza tarjetas DIRECTO contra la API pública de Conekta.
/// Los datos de la tarjeta nunca pasan por nuestro backend — solo el token.
class ConektaTokensRemoteDatasource {
  static const _tokensUrl = 'https://api.conekta.io/tokens';

  final http.Client _client;
  final String _publicKey;

  ConektaTokensRemoteDatasource({
    required String publicKey,
    http.Client? client,
  })  : _publicKey = publicKey,
        _client = client ?? http.Client();

  Future<String> createCardToken({
    required String cardNumber,
    required String holderName,
    required String expMonth,
    required String expYear,
    required String cvc,
  }) async {
    final credentials = base64Encode(utf8.encode('$_publicKey:'));

    late http.Response response;
    try {
      response = await _client.post(
        Uri.parse(_tokensUrl),
        headers: {
          'Authorization': 'Basic $credentials',
          'Content-Type': 'application/json',
          'Accept': 'application/vnd.conekta-v2.1.0+json',
        },
        body: jsonEncode({
          'card': {
            'number': cardNumber,
            'name': holderName,
            'exp_month': expMonth,
            'exp_year': expYear,
            'cvc': cvc,
          },
        }),
      );
    } catch (_) {
      throw const ConektaTokenException(
        'No se pudo conectar con la pasarela de pago. Revisa tu conexión.',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body['id'] as String;
    }

    final details =
        (body['details'] as List?)?.whereType<Map<String, dynamic>>().toList() ??
            const [];
    final message = details.isNotEmpty
        ? (details.first['message']?.toString() ??
            'Error al procesar la tarjeta')
        : 'Error al procesar la tarjeta';
    throw ConektaTokenException(
      message,
      code: details.isNotEmpty ? details.first['code']?.toString() : null,
    );
  }
}
