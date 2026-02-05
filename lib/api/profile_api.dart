import 'package:http/http.dart' as http;

class ProfileApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/users';

  static Future<http.Response> fetchProfile(String token) {
    return http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}
