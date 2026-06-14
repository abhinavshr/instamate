import 'package:http/http.dart' as http;

class ReelApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/reels';

  static Future<http.Response> fetchReels(String token) {
    return http.get(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> toggleReelLike(String token, String reelId) {
    return http.post(
      Uri.parse('$_baseUrl/$reelId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}