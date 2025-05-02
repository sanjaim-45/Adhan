import 'dart:convert';
import 'package:http/http.dart' as http;

import '../tokens/token_service.dart';


class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  Future<http.Response> sendRequest(
      String url,
      String method, {
        Map<String, String>? headers,
        dynamic body,
        bool retry = true, // Add retry flag
      }) async {
    final accessToken = await TokenService.getAccessToken();
    final defaultHeaders = {
      'Content-Type': 'application/json',
      if (accessToken != null) 'Authorization': 'Bearer $accessToken', // Changed to standard Authorization header
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    final uri = Uri.parse(url);
    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: defaultHeaders);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: defaultHeaders,
            body: body != null ? json.encode(body) : null,
          );
          break;
      // Add other methods as needed
        default:
          throw Exception('Unsupported HTTP method');
      }

      // If token expired and we should retry
      if (response.statusCode == 401 && retry) {
        final refreshed = await _refreshToken();
        if (refreshed) {
          // Retry the request once with new token
          return sendRequest(url, method, headers: headers, body: body, retry: false);
        }
      }

      return response;
    } catch (e) {
      throw Exception('Request failed: $e');
    }
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await TokenService.getRefreshToken();
      if (refreshToken == null) return false;

      final refreshUrl = Uri.parse('$baseUrl/api/RefreshToken/refresh-token');
      final refreshResponse = await http.post(
        refreshUrl,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'token': refreshToken}),
      );

      if (refreshResponse.statusCode == 200) {
        final data = json.decode(refreshResponse.body);
        await TokenService.saveTokens(data['accessToken'], data['refreshToken']);
        return true;
      } else {
        await TokenService.clearTokens();
        return false;
      }
    } catch (e) {
      await TokenService.clearTokens();
      return false;
    }
  }
}