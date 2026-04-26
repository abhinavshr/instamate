import 'dart:convert';
import '../api/post_api.dart';
import 'auth_service.dart';

class PostService {

  static Future<void> deletePost(int postId, List<int> deleteMediaIds) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await PostApi.deletePost(token, postId, deleteMediaIds);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete post');
    } catch (e) {
      rethrow;
    }
  }
}