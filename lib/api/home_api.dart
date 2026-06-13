import 'package:http/http.dart' as http;

class HomeApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api';

  static Future<http.Response> getHomeFeed(String token) {
    return http.get(
      Uri.parse('$_baseUrl/feed'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}