import 'dart:convert';
import '../api/auth_api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Secure storage instance
  static final _storage = FlutterSecureStorage();

  // Keys
  static const _tokenKey = 'jwt_token';
  static const _expiryKey = 'jwt_expiry';
  static const _userKey = 'user';

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

  // ---------------- LOGIN ----------------
  static Future<String?> login({
    required String identifier,
    required String password,
  }) async {
    // Check if the identifier looks like an email
    bool isEmail = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(identifier);

    final requestData = isEmail
        ? {'email': identifier, 'password': password}
        : {'username': identifier, 'password': password};

    final response = await AuthApi.login(requestData);

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'] as String;
      final expiry = DateTime.now().add(const Duration(days: 7)).millisecondsSinceEpoch;

      // Store token securely
      await _storage.write(key: _tokenKey, value: token);
      await _storage.write(key: _expiryKey, value: expiry.toString());
      await _storage.write(key: _userKey, value: jsonEncode(data['user']));

      return null; // success
    }

    return data['message'] ?? 'Login failed';
  }

  // ---------------- LOGOUT ----------------
  static Future<void> logout() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _expiryKey);
    await _storage.delete(key: _userKey);
  }

  // ---------------- GET TOKEN ----------------
  static Future<String?> getToken() async {
    final token = await _storage.read(key: _tokenKey);
    final expiryStr = await _storage.read(key: _expiryKey);
    if (token == null || expiryStr == null) return null;

    final expiry = int.tryParse(expiryStr);
    if (expiry == null) return null;

    if (DateTime.now().millisecondsSinceEpoch > expiry) {
      // Token expired
      await logout();
      return null;
    }
    return token;
  }

  // ---------------- GET USER ----------------
  static Future<Map<String, dynamic>?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    return jsonDecode(userJson);
  }
}
