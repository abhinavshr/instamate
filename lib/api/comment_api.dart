import 'dart:convert';
import 'package:http/http.dart' as http;

class CommentApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/posts';
  static const String _commentsBaseUrl = 'http://10.0.2.2:5000/api/comments';

  static Future<http.Response> getPostComments(String token, int postId) {
    return http.get(
      Uri.parse('$_baseUrl/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> addComment(String token, int postId, String comment, {int? parentId}) {
    return http.post(
      Uri.parse('$_baseUrl/$postId/comments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'comment': comment,
        if (parentId != null) 'parent_id': parentId,
      }),
    );
  }

  static Future<http.Response> toggleCommentLike(String token, int commentId) {
    return http.post(
      Uri.parse('$_commentsBaseUrl/$commentId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> getCommentLikes(String token, int commentId) {
    return http.get(
      Uri.parse('$_commentsBaseUrl/$commentId/likes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}