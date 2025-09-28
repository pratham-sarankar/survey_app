import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/api_exception.dart';
import '../screens/login_screen.dart';
import 'auth_service.dart';

abstract class APIService {
  final AuthService _authService;

  APIService(this._authService);

  Future<String?> get _token => _authService.getToken();

  Future<void> handleUnauthorized(BuildContext context) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Please login again to continue.'),
        actions: [
          TextButton(
            onPressed: () async {
              await _authService.logout();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<String> getToken() async {
    final token = await _token;
    if (token == null) {
      throw APIException('No auth token found');
    }
    return token;
  }

  Future<T> get<T>({
    required BuildContext context,
    required String endpoint,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    try {
      final token = await _token;
      if (token == null) {
        throw APIException('No auth token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw APIException('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return parser(responseData['data']);
      } else {
        throw APIException(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      throw APIException(e.toString());
    }
  }

  Future<T> post<T>({
    required BuildContext context,
    required String endpoint,
    required Map<String, dynamic> body,
    required T Function(Map<String, dynamic> json) parser,
  }) async {
    try {
      final token = await _token;
      if (token == null) {
        throw APIException('No auth token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw APIException('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return parser(responseData['data']);
      } else {
        throw APIException(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      throw APIException(e.toString());
    }
  }

  Future<bool> delete({
    required BuildContext context,
    required String endpoint,
  }) async {
    try {
      final token = await _token;
      if (token == null) {
        throw APIException('No auth token found');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw APIException('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return true;
      } else {
        throw APIException(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      throw APIException(e.toString());
    }
  }

  Future<List<T>> getList<T>({
    required BuildContext context,
    required String endpoint,
    required T Function(Map<String, dynamic> json) parser,
    required String listKey,
  }) async {
    try {
      final token = await _token;
      if (token == null) {
        throw APIException('No auth token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw APIException('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final List items = responseData['data'][listKey];
        return items.map((json) => parser(json)).toList();
      } else {
        throw APIException(responseData['message'] ?? 'Request failed');
      }
    } catch (e) {
      throw APIException(e.toString());
    }
  }
}
