import 'package:http/http.dart' as http;

class LikeApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/posts';

  static Future<http.Response> toggleLike(String token, int postId) {
    return http.post(
      Uri.parse('$_baseUrl/$postId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}