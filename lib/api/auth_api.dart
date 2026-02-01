import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/auth';

  static Future<http.Response> register(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$_baseUrl/register'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
  }

  static Future<http.Response> login(Map<String, dynamic> data) {
    return http.post(
      Uri.parse('$_baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );
  }
}

