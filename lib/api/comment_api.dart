import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/posts';

  static Future<http.Response> getPostComments(String token, int postId) {
    return http.get(
      Uri.parse('$_baseUrl/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> addComment(String token, int postId, String comment) {
    return http.post(
      Uri.parse('$_baseUrl/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'comment': comment}),
    );
  }
}