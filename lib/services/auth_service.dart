import 'dart:convert';
import '../api/auth_api.dart';

class AuthService {
  static Future<String?> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final response = await AuthApi.register({
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return null; // success
    }

    return data['message'] ?? 'Registration failed';
  }
}
