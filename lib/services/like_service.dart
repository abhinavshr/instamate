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

      if (response.statusCode == 200) {
        return data;
      }

      throw Exception(data['message'] ?? 'Failed to toggle like');
    } catch (e) {
      rethrow;
    }
  }
}