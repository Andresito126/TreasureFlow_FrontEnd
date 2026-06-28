import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:treasureflow/core/storage/token_storage.dart';

class ApiClient {
  static String get baseUrl => dotenv.env['API_URL']!;

  final http.Client _client;
  final TokenStorage _tokenStorage;
  bool _isRefreshing = false;

  ApiClient({required TokenStorage tokenStorage})
      : _client = http.Client(),
        _tokenStorage = tokenStorage;

  Future<Map<String, String>> _buildHeaders() async {
    final token = await _tokenStorage.getAccessToken();
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
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
    );
  }

  Future<bool> _tryRefreshToken() async {
    _isRefreshing = true;
    try {
      final refreshToken = await _tokenStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _client.post(
        Uri.parse('$baseUrl/auth/refresh'),
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

  const ApiException({required this.statusCode, required this.message});

  @override
  String toString() => 'ApiException($statusCode): $message';
}
