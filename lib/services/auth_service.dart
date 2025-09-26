import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  Future<User?> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['user']);
        final token = data['token'];

        // Save token and user data locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, jsonEncode(user.toJson()));

        return user.copyWith(token: token);
      } else {
        throw Exception('Login failed: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, return a mock user for testing
      if (username == 'admin' && password == 'admin') {
        final user = User(
          id: '1',
          username: 'admin',
          role: UserRole.admin,
          token: 'mock_admin_token',
        );
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'mock_admin_token');
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        
        return user;
      } else if (username == 'user' && password == 'user') {
        final user = User(
          id: '2',
          username: 'user',
          role: UserRole.user,
          token: 'mock_user_token',
        );
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, 'mock_user_token');
        await prefs.setString(_userKey, jsonEncode(user.toJson()));
        
        return user;
      }
      
      rethrow;
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
      final token = prefs.getString(_tokenKey);
      final userData = prefs.getString(_userKey);

      if (token != null && userData != null) {
        final user = User.fromJson(jsonDecode(userData));
        return user.copyWith(token: token);
      }
    } catch (e) {
      // Ignore errors and return null
    }
    
    return null;
  }

  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (e) {
      // Ignore errors during cleanup
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }
}