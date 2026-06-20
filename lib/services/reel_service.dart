import 'dart:convert';
import '../api/reel_api.dart';
import 'auth_service.dart';

class ReelService {
  static Future<List<dynamic>> getReels() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.fetchReels(token);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['reels'];
      }

      throw Exception(data['message'] ?? 'Failed to fetch reels');
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> toggleReelLike(String reelId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.toggleReelLike(token, reelId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['message']; // "Reel liked" or "Reel unliked"
      }

      throw Exception(data['message'] ?? 'Failed to toggle like');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getReelLikeStatus(String reelId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.getReelLikeStatus(token, reelId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'is_liked': data['is_liked'],
          'like_count': data['like_count'],
        };
      }

      throw Exception(data['message'] ?? 'Failed to fetch like status');
    } catch (e) {
      rethrow;
    }
  }

  static Future<List<Map<String, dynamic>>> getReelComments(String reelId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.getReelComments(token, reelId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(data['comments']);
      }

      throw Exception(data['message'] ?? 'Failed to fetch comments');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> postReelComment(
      String reelId,
      String comment,
      ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.postReelComment(token, reelId, comment);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data;
      }

      throw Exception(data['message'] ?? 'Failed to post comment');
    } catch (e) {
      rethrow;
    }
  }
}