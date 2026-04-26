import 'dart:convert';
import '../api/comment_api.dart';
import 'auth_service.dart';

class CommentService {

  static Future<List<Map<String, dynamic>>> getPostComments(int postId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await CommentApi.getPostComments(token, postId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final comments = data['comments'] as List<dynamic>;
        return comments.map((c) => c as Map<String, dynamic>).toList();
      }

      throw Exception(data['message'] ?? 'Failed to fetch comments');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> addComment(int postId, String comment, {int? parentId}) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await CommentApi.addComment(token, postId, comment, parentId: parentId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      throw Exception(data['message'] ?? 'Failed to add comment');
    } catch (e) {
      rethrow;
    }
  }
}