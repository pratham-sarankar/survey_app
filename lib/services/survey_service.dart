import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../config/api_config.dart';
import '../config/api_exception.dart';
import '../models/survey.dart';
import '../models/survey_form.dart';
import 'api_service.dart';
import 'auth_service.dart';

class SurveyService extends APIService {
  SurveyService(AuthService authService) : super(authService);

  Future<List<Survey>> getSurveys(BuildContext context) async {
    return getList<Survey>(
      context: context,
      endpoint: '/surveys',
      parser: (json) => Survey.fromJson(json),
      listKey: 'surveys',
    );
  }

  Future<Survey> createSurvey(BuildContext context, SurveyForm form) async {
    return post<Survey>(
      context: context,
      endpoint: '/surveys',
      body: form.toJson(),
      parser: (data) {
        // Add missing fields to match Survey model structure
        data['latitude'] = form.latitude;
        data['longitude'] = form.longitude;
        data['qr_id'] = form.qrId;
        data['father_or_spouse_name'] = form.fatherOrSpouseName;
        data['contact_number'] = form.contactNumber;
        data['whatsapp_number'] = form.whatsappNumber;
        return Survey.fromJson(data);
      },
    );
  }

  Future<bool> deleteSurvey(BuildContext context, int surveyId) async {
    return delete(
      context: context,
      endpoint: '/surveys/$surveyId',
    );
  }

  Future<bool> updateSurvey(
      BuildContext context, int surveyId, SurveyForm form) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/surveys/$surveyId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(form.toJson()),
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return true; // Just return success status, don't depend on response data
      } else {
        throw APIException(
            responseData['message'] ?? 'Failed to update survey');
      }
    } catch (e) {
      throw APIException(e.toString());
    }
  }
}
