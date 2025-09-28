import 'package:flutter/material.dart';

import '../models/survey.dart';
import '../models/survey_form.dart';
import '../services/survey_service.dart';

class SurveyProvider with ChangeNotifier {
  final SurveyService _surveyService;
  List<Survey> _surveys = [];
  bool _isLoading = false;
  String? _error;

  SurveyProvider(this._surveyService);

  List<Survey> get surveys => _surveys;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSurveys(BuildContext context) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _surveys = await _surveyService.getSurveys(context);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> createSurvey(BuildContext context, SurveyForm form) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final survey = await _surveyService.createSurvey(context, form);
      _error = null;
      await loadSurveys(context); // Refresh the surveys list
      return survey.id.toString(); // Return the created survey's ID
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteSurvey(BuildContext context, int surveyId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _surveyService.deleteSurvey(context, surveyId);
      if (success) {
        // Remove the survey from the local list
        _surveys.removeWhere((survey) => survey.id == surveyId);
      }
      _error = null;
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
