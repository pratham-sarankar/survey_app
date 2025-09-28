import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_app/config/api_exception.dart';

import '../config/api_config.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<User> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'login_id': username,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final data = responseData['data'];

        final user = User(
          id: data['user_id'].toString(),
          username: data['username'],
          role: UserRole.values.firstWhere(
            (e) => e.toString().split('.').last == data['role'],
            orElse: () => UserRole.surveyor,
          ),
          token: data['access_token'],
          tokenType: data['token_type'],
          expiresIn: data['expires_in'],
        );

        // Save token and user data
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, data['access_token']);
        await prefs.setString(_userKey, jsonEncode(user.toJson()));

        return user;
      } else {
        throw APIException(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      if (e is APIException) rethrow;
      throw APIException('An error occurred during login: $e');
    }
  }

  Future<User?> register(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        final token = data['token'];

        // Save token and user data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(user.toJson()));

        return user.copyWith(token: token);
      } else {
        throw Exception('Registration failed: ${response.body}');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      final token = prefs.getString(_tokenKey);

      if (userData != null && token != null) {
        final userMap = jsonDecode(userData);
        return User.fromJson(userMap);
      }
    } catch (e) {
      print('Error getting current user: $e');
    }
    return null;
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }
}
