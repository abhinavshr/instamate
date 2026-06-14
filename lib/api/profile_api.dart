import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ProfileApi {
  static const String _baseUrl = 'http://10.0.2.2:5000/api/users';

  static Future<http.Response> fetchProfile(String token) {
    return http.get(
      Uri.parse('$_baseUrl/profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> fetchProfileStats(String token) {
    return http.get(
      Uri.parse('$_baseUrl/profile/stats'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> updateProfile({
    required String token,
    String? username,
    String? fullName,
    String? profilePic,
    String? bio,
  }) {
    // Build the request body only with non-null fields
    final body = <String, dynamic>{};
    if (username != null) body['username'] = username;
    if (fullName != null) body['full_name'] = fullName;
    if (profilePic != null) body['profile_pic'] = profilePic;
    if (bio != null) body['bio'] = bio;

    return http.put(
      Uri.parse('$_baseUrl/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.StreamedResponse> updateProfileMultipart({
    required String token,
    String? username,
    String? fullName,
    File? profilePicFile,
    String? bio,
  }) async {
    final uri = Uri.parse('$_baseUrl/update-profile');
    var request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';

    if (username != null) request.fields['username'] = username;
    if (fullName != null) request.fields['full_name'] = fullName;
    if (bio != null) request.fields['bio'] = bio;

    if (profilePicFile != null) {
      request.files.add(await http.MultipartFile.fromPath('profile_pic', profilePicFile.path));
    }

    return await request.send();
  }

  static Future<http.Response> fetchMyPosts(String token) {
    return http.get(
      Uri.parse('http://10.0.2.2:5000/api/posts/me'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> fetchMyPostById(String token, int postId) {
    return http.get(
      Uri.parse('http://10.0.2.2:5000/api/posts/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> updatePrivacy(String token, bool isPrivate) {
    return http.put(
      Uri.parse('$_baseUrl/privacy'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'is_private': isPrivate ? 1 : 0}),
    );
  }

  static Future<http.Response> checkPrivacy(String token) {
    return http.get(
      Uri.parse('$_baseUrl/check-privacy'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }
}

