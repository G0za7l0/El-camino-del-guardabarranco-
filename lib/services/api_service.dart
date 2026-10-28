import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  // En el emulador Android, localhost del PC se accede mediante 10.0.2.2.
  static const String baseUrl = 'http://10.0.2.2:5128';

  // ==================================================
  // GET
  // ==================================================

  Future<dynamic> get(
    String endpoint, {
    String? token,
    Map<String, String>? queryParameters,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint').replace(
      queryParameters: queryParameters,
    );

    final response = await http.get(
      uri,
      headers: _headers(token),
    );

    return _handleResponse(response);
  }

  // ==================================================
  // POST
  // ==================================================

  Future<dynamic> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');

    final response = await http.post(
      uri,
      headers: _headers(token),
      body: body != null ? jsonEncode(body) : null,
    );

    return _handleResponse(response);
  }

  // ==================================================
  // HEADERS
  // ==================================================

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // ==================================================
  // RESPONSE
  // ==================================================

  dynamic _handleResponse(http.Response response) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (_) {
      data = response.body;
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }

    String message = 'Error en la comunicación con el servidor.';

    if (data is Map<String, dynamic> && data['message'] != null) {
      message = data['message'].toString();
    }

    throw Exception(message);
  }
}