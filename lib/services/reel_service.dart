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
}