import 'package:flutter/material.dart';
import 'package:survey_app/models/survey.dart';

import '../models/survey_form.dart';
import 'api_service.dart';

class SurveyService extends APIService {
  SurveyService(super.authService);

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
}
