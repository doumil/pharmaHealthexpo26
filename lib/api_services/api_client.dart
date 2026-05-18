import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  // 1. Updated to your actual domain
  static const String _baseUrl = 'https://buzzevents.co/api';

  static String? _accessToken;

  // Ensure this matches your production API Key if one is required
  static const String _apiKey = '1a2b3c4d5e6f7g8h9i0j1k2l3m4n5o6p7';

  static void setAccessToken(String? token) {
    _accessToken = token;
  }

  static Map<String, String> getHeaders({bool requireAuth = false, String? authToken}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Api-Key': _apiKey,
      // 🛡️ CRITICAL: This bypasses Nginx 403 blocks by mimicking a real browser
      'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
    };

    String? tokenToUse = authToken ?? _accessToken;

    if (requireAuth && tokenToUse != null && tokenToUse.isNotEmpty) {
      // Clean the token (remove "Bearer " if it's already there to avoid "Bearer Bearer ...")
      String cleanToken = tokenToUse.replaceFirst('Bearer ', '').trim();
      headers['Authorization'] = 'Bearer $cleanToken';

      print('--- API DEBUG ---');
      print('URL: $_baseUrl');
      print('Auth: Sending Bearer Token (Starts with: ${cleanToken.substring(0, 10)}...)');
    }

    return headers;
  }

  static Future<http.Response> get(String endpoint, {Map<String, String>? queryParameters, bool requireAuth = false, String? authToken}) async {
    // Ensure the endpoint starts with /
    final String path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    Uri uri = Uri.parse('$_baseUrl$path');

    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }

    try {
      print('GET Request to: $uri');
      final response = await http.get(
        uri,
        headers: getHeaders(requireAuth: requireAuth, authToken: authToken),
      );

      // We handle errors but RETURN the response so the Service can see the body
      _logResponse(response);
      handleResponseError(response);
      return response;
    } catch (e) {
      print('ApiClient GET Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<http.Response> post(String endpoint, dynamic body, {bool requireAuth = false, String? authToken}) async {
    final String path = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('$_baseUrl$path');

    try {
      print('POST Request to: $uri');
      final response = await http.post(
        uri,
        headers: getHeaders(requireAuth: requireAuth, authToken: authToken),
        body: jsonEncode(body),
      );
      _logResponse(response);
      handleResponseError(response);
      return response;
    } catch (e) {
      print('ApiClient POST Error: $e');
      throw Exception('Network error: $e');
    }
  }

  static void _logResponse(http.Response response) {
    print('Response Status: ${response.statusCode}');
    if (response.statusCode != 200) {
      print('Response Body Snippet: ${response.body.length > 200 ? response.body.substring(0, 200) : response.body}');
    }
  }

  static void handleResponseError(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    // If we hit 403, we know it's a header/permission issue
    if (response.statusCode == 403) {
      throw Exception('Client error (403): Access Forbidden. Please check User-Agent or Token permissions.');
    }

    if (response.statusCode == 401) {
      throw Exception('Unauthorized (401): Please log in again.');
    }

    throw Exception('Request Failed with Status: ${response.statusCode}');
  }
}