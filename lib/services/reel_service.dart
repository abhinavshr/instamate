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

  static Future<void> postReelComment(String reelId, String comment) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.postReelComment(token, reelId, comment);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception(data['message'] ?? 'Failed to post comment');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> postReelCommentReply(
      String reelId,
      String commentId,
      String comment,
      ) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.postReelCommentReply(
        token,
        reelId,
        commentId,
        comment,
      );
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      }

      throw Exception(data['message'] ?? 'Failed to post reply');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> deleteReelComment(String reelId, String commentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.deleteReelComment(token, reelId, commentId);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return;
      }

      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to delete comment');
    } catch (e) {
      rethrow;
    }
  }

  static Future<String> toggleReelCommentLike(String commentId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await ReelApi.toggleReelCommentLike(token, commentId);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return data['message']; // "Comment liked" or "Comment unliked"
      }

      throw Exception(data['message'] ?? 'Failed to toggle comment like');
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> addReelView(String reelId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) return;

      final response = await ReelApi.addReelView(token, reelId);

      if (response.statusCode != 200) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Failed to record view');
      }
    } catch (e) {
      print('❌ addReelView error: $e');
    }
  }
}