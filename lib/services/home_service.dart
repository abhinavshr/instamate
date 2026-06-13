import 'dart:convert';
import '../api/home_api.dart';
import 'auth_service.dart';

class HomeService {

  static Future<List<dynamic>> getHomeFeed() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('User not authenticated');

      final response = await HomeApi.getHomeFeed(token);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['feed'] as List<dynamic>;
      }

      final data = jsonDecode(response.body);
      throw Exception(data['message'] ?? 'Failed to fetch feed');
    } catch (e) {
      rethrow;
    }
  }
}