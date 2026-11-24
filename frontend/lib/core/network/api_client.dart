
import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiClient {
  final http.Client _client = http.Client();

  Future<http.Response> get(String url) async {
    final uri = Uri.parse(url);
    return await _client.get(uri);
  }

  Future<http.Response> post(
    String url, {
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);

    return await _client.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  void dispose() {
    _client.close();
  }
}
