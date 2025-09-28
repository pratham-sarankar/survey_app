import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../models/survey.dart';
import '../screens/login_screen.dart';
import '../services/auth_service.dart';

class SurveyService {
  final AuthService _authService;

  SurveyService(this._authService);

  Future<void> _handleUnauthorized(BuildContext context) async {
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

  Future<List<Survey>> getSurveys(BuildContext context) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/surveys'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await _handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final surveysJson = responseData['data']['surveys'] as List;
        return surveysJson.map((json) => Survey.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load surveys');
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
