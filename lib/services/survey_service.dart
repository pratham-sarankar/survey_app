import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survey_app/config/api_exception.dart';

import '../config/api_config.dart';
import '../models/survey.dart';
import '../models/survey_form.dart';
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
        throw APIException(responseData['message'] ?? 'Failed to load surveys');
      }
    } catch (e) {
      throw APIException(e.toString());
    }
  }

  Future<Survey> createSurvey(BuildContext context, SurveyForm form) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/surveys'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(form.toJson()),
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await _handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      final responseData = jsonDecode(response.body);
      print('API Response: $responseData'); // For debugging

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Add missing fields to match Survey model structure
        final data = responseData['data'];
        data['latitude'] = form.latitude;
        data['longitude'] = form.longitude;
        data['qr_id'] = form.qrId;
        data['father_or_spouse_name'] = form.fatherOrSpouseName;
        data['contact_number'] = form.contactNumber;
        data['whatsapp_number'] = form.whatsappNumber;

        return Survey.fromJson(data);
      } else {
        throw APIException(
            responseData['message'] ?? 'Failed to create survey');
      }
    } catch (e) {
      print('Error creating survey: $e'); // For debugging
      throw APIException(e.toString());
    }
  }

  Future<bool> deleteSurvey(BuildContext context, int surveyId) async {
    try {
      final token = await _authService.getToken();
      if (token == null) {
        throw Exception('No auth token found');
      }

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/surveys/$surveyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await _handleUnauthorized(context);
        }
        throw APIException('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return true;
      } else {
        throw APIException(
            responseData['message'] ?? 'Failed to delete survey');
      }
    } catch (e) {
      throw APIException(e.toString());
    }
  }
}
