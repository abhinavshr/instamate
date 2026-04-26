import 'dart:convert';
import 'package:http/http.dart' as http;

class PostApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/posts';

  static Future<http.Response> deletePost(String token, int postId, List<int> deleteMediaIds) {
    return http.delete(
      Uri.parse('$_baseUrl/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'deleteMediaIds': deleteMediaIds}),
    );
  }
}