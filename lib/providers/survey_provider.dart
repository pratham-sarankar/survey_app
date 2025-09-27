import 'package:flutter/material.dart';
import '../models/survey_entry.dart';
import '../services/survey_service.dart';
import '../config/service_locator.dart';

class SurveyProvider with ChangeNotifier {
  List<SurveyEntry> _entries = [];
  bool _isLoading = false;
  String? _error;

  List<SurveyEntry> get entries => _entries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  SurveyService? _surveyService;

  void initialize(String? token) {
    _surveyService = SurveyService(token);
  }

  Future<void> loadMyEntries(String userId) async {
    if (_surveyService == null) return;

    _setLoading(true);
    _clearError();

    try {
      _entries = await _surveyService!.getMyEntries(userId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadAllEntries() async {
    if (_surveyService == null) return;

    _setLoading(true);
    _clearError();

    try {
      _entries = await _surveyService!.getAllEntries();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> createEntry(SurveyEntry entry) async {
    if (_surveyService == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final newEntry = await _surveyService!.createEntry(entry);
      _entries.add(newEntry);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateEntry(SurveyEntry entry) async {
    if (_surveyService == null) return false;

    _setLoading(true);
    _clearError();

    try {
      final updatedEntry = await _surveyService!.updateEntry(entry);
      final index = _entries.indexWhere((e) => e.id == entry.id);
      if (index != -1) {
        _entries[index] = updatedEntry;
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteEntry(String entryId) async {
    if (_surveyService == null) return false;

    _setLoading(true);
    _clearError();

    try {
      await _surveyService!.deleteEntry(entryId);
      _entries.removeWhere((entry) => entry.id == entryId);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void clear() {
    _entries.clear();
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}