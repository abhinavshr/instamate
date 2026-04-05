import 'dart:convert';
import 'dart:io';
import '../api/profile_api.dart';
import 'auth_service.dart';

class ProfileService {
  static Future<Map<String, dynamic>?> getProfile() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await ProfileApi.fetchProfile(token);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['user'];
      }

      throw Exception(data['message'] ?? 'Failed to fetch profile');
    } catch (e) {
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> getProfileStats() async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      final response = await ProfileApi.fetchProfileStats(token);
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return data['user'];
      }

      throw Exception(data['message'] ?? 'Failed to fetch profile');
    } catch (e) {
      rethrow;
    }
  }

  // static Future<Map<String, dynamic>?> updateProfile({
  //   String? username,
  //   String? fullName,
  //   String? profilePic,
  //   String? bio,
  // }) async {
  //   try {
  //     final token = await AuthService.getToken();
  //     if (token == null) {
  //       throw Exception('User not authenticated');
  //     }
  //
  //     final response = await ProfileApi.updateProfile(
  //       token: token,
  //       username: username,
  //       fullName: fullName,
  //       profilePic: profilePic,
  //       bio: bio,
  //     );
  //
  //     final data = jsonDecode(response.body);
  //
  //     if (response.statusCode == 200) {
  //       return data['user'];
  //     }
  //
  //     throw Exception(data['message'] ?? 'Failed to update profile');
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  static Future<Map<String, dynamic>?> updateProfile({
    String? username,
    String? fullName,
    File? profilePicFile,
    String? bio,
  }) async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final streamedResponse = await ProfileApi.updateProfileMultipart(
      token: token,
      username: username,
      fullName: fullName,
      profilePicFile: profilePicFile,
      bio: bio,
    );

    final responseBody = await streamedResponse.stream.bytesToString();

    if (streamedResponse.statusCode == 200) {
      final data = jsonDecode(responseBody);
      return data['user'];
    } else {
      final data = jsonDecode(responseBody);
      throw Exception(data['message'] ?? 'Failed to update profile');
    }
  }

  static Future<List<dynamic>> getMyPosts() async {
    final token = await AuthService.getToken();
    if (token == null) throw Exception('User not authenticated');

    final response = await ProfileApi.fetchMyPosts(token);
    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data['posts'];
    }

    throw Exception(data['message'] ?? 'Failed to fetch posts');
  }
}
