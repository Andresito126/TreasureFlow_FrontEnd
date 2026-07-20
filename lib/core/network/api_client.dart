import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:treasureflow/core/storage/token_storage.dart';

class ApiClient {
  static String get _defaultBaseUrl => dotenv.env['API_URL']!;
  final String? _baseUrlOverride;
  String get baseUrl => _baseUrlOverride ?? _defaultBaseUrl;

  final http.Client _client;
  final TokenStorage _tokenStorage;

  /// Headers adicionales por request (ej. `x-user-id`/`x-user-type` para
  /// backends detrás de un gateway que no validan JWT directamente).
  final Future<Map<String, String>> Function()? _extraHeadersBuilder;
  bool _isRefreshing = false;

  ApiClient({
    required TokenStorage tokenStorage,
    String? baseUrl,
    Future<Map<String, String>> Function()? extraHeadersBuilder,
  })  : _client = http.Client(),
        _tokenStorage = tokenStorage,
        _baseUrlOverride = baseUrl,
        _extraHeadersBuilder = extraHeadersBuilder;

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    final extra = await _extraHeadersBuilder?.call();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      if (extra != null) ...extra,
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final headers = await _buildHeaders();
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response, 'GET', path);
  }

  /// GET para endpoints cuya respuesta puede ser `null` (200 con body
  /// literal `null`) en vez de siempre un objeto.
  Future<Map<String, dynamic>?> getNullable(String path) async {
    final headers = await _buildHeaders();
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      final decoded = jsonDecode(response.body);
      return decoded is Map<String, dynamic> ? decoded : null;
    }

    if (response.statusCode == 401 && !_isRefreshing) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return getNullable(path);
      }
      await _tokenStorage.deleteTokens();
    }

    final errorBody =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;
    throw ApiException(
      statusCode: response.statusCode,
      message: errorBody is Map<String, dynamic>
          ? (errorBody['message']?.toString() ?? 'Error desconocido')
          : 'Error desconocido',
      error: errorBody is Map<String, dynamic>
          ? errorBody['error']?.toString()
          : null,
    );
  }

  /// GET para endpoints cuya respuesta es un array JSON (`[...]`)
  /// en lugar de un objeto.
  Future<List<dynamic>> getList(String path) async {
    final headers = await _buildHeaders();
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty
          ? jsonDecode(response.body) as List<dynamic>
          : <dynamic>[];
    }

    if (response.statusCode == 401 && !_isRefreshing) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return getList(path);
      }
      await _tokenStorage.deleteTokens();
    }

    final errorBody =
        response.body.isNotEmpty ? jsonDecode(response.body) : null;
    throw ApiException(
      statusCode: response.statusCode,
      message: errorBody is Map<String, dynamic>
          ? (errorBody['message']?.toString() ?? 'Error desconocido')
          : 'Error desconocido',
      error: errorBody is Map<String, dynamic>
          ? errorBody['error']?.toString()
          : null,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _buildHeaders();
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, 'POST', path, body: body);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _buildHeaders();
    final response = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, 'PUT', path, body: body);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _buildHeaders();
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    return _handleResponse(response, 'PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final headers = await _buildHeaders();
    final response = await _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: headers,
    );
    return _handleResponse(response, 'DELETE', path);
  }

  Future<Map<String, dynamic>> _handleResponse(
    http.Response response,
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final responseBody = response.body.isNotEmpty
        ? jsonDecode(response.body) as Map<String, dynamic>
        : <String, dynamic>{};

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseBody;
    }

    if (response.statusCode == 401 && !_isRefreshing) {
      final refreshed = await _tryRefreshToken();
      if (refreshed) {
        return _retryRequest(method, path, body: body);
      }
      await _tokenStorage.deleteTokens();
    }

    throw ApiException(
      statusCode: response.statusCode,
      message: responseBody['message']?.toString() ?? 'Error desconocido',
      error: responseBody['error']?.toString(),
    );
  }

  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      // El refresh SIEMPRE va contra el backend principal (tf_backend_main),
      // aunque esta instancia apunte a otro servicio.
      final response = await _client.post(
        Uri.parse('$_defaultBaseUrl/auth/refresh'),
        headers: {HttpHeaders.contentTypeHeader: 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        await _tokenStorage.saveTokens(
          data['accessToken'] as String,
          data['refreshToken'] as String,
        );
        return true;
      }

      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Map<String, dynamic>> _retryRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) {
    switch (method) {
      case 'GET':
        return get(path);
      case 'POST':
        return post(path, body: body);
      case 'PUT':
        return put(path, body: body);
      case 'PATCH':
        return patch(path, body: body);
      case 'DELETE':
        return delete(path);
      default:
        throw ApiException(statusCode: 0, message: 'Método no soportado');
    }
  }
}

class ApiException implements Exception {
  final int statusCode;
  final String message;

  /// Nombre de la excepción del backend (ej. 'PaymentCaptureFailedException'),
  /// útil para distinguir tipos de error en la UI.
  final String? error;

  const ApiException({
    required this.statusCode,
    required this.message,
    this.error,
  });

  @override
  String toString() => 'ApiException($statusCode): $message';
}
