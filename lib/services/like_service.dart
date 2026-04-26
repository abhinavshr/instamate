import 'dart:convert';
import '../api/like_api.dart';
import 'auth_service.dart';

class LikeService {

  static Future<Map<String, dynamic>> toggleLike(int postId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await LikeApi.toggleLike(token, postId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      throw Exception(data['message'] ?? 'Failed to toggle like');
    } catch (e) {
      rethrow;
    }
  }

  static Future<bool> isPostLiked(int postId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await LikeApi.isPostLiked(token, postId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['is_liked'] as bool;
      }

      throw Exception(data['message'] ?? 'Failed to check like status');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getPostLikes(int postId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await LikeApi.getPostLikes(token, postId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'totalLikes': data['totalLikes'] as int,
          'isLiked': data['isLiked'] as bool,
        };
      }

      throw Exception(data['message'] ?? 'Failed to fetch post likes');
    } catch (e) {
      rethrow;
    }
  }
}