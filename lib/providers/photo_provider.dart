import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/survey_photo.dart';
import '../services/photo_service.dart';

class PhotoProvider with ChangeNotifier {
  final PhotoService _photoService;
  List<SurveyPhoto> _syncedPhotos = [];
  List<SurveyPhoto> _localPhotos = [];
  bool _isLoading = false;
  String? _error;

  PhotoProvider(this._photoService);

  List<SurveyPhoto> get syncedPhotos => _syncedPhotos;
  List<SurveyPhoto> get localPhotos => _localPhotos;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasUnsyncedPhotos => _localPhotos.isNotEmpty;

  Future<void> loadPhotos(BuildContext context, String surveyId) async {
    _setLoading(true);
    _error = null;

    try {
      // Load both synced and local photos in parallel
      final results = await Future.wait([
        _photoService.getSyncedPhotos(context, surveyId),
        _photoService.getLocalPhotos(surveyId),
      ]);

      _syncedPhotos = results[0];
      _localPhotos = results[1];
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> addPhoto(String surveyId, ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image == null) return false;

      final photo = await _photoService.savePhotoLocally(
        surveyId,
        File(image.path),
      );

      if (photo != null) {
        _localPhotos = [..._localPhotos, photo];
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadPhotos(BuildContext context, String surveyId) async {
    if (_localPhotos.isEmpty) return true;

    _setLoading(true);
    _error = null;

    try {
      final files = _localPhotos
          .where((photo) => photo.localFile != null)
          .map((photo) => photo.localFile!)
          .toList();

      final success =
          await _photoService.uploadPhotos(context, surveyId, files);

      if (success) {
        // Clear local photos and reload synced photos
        _localPhotos = [];
        await loadPhotos(context, surveyId);
        return true;
      }

      _error = 'Failed to upload photos';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteLocalPhoto(SurveyPhoto photo) async {
    try {
      final success = await _photoService.deleteLocalPhoto(photo);
      if (success) {
        _localPhotos = _localPhotos.where((p) => p.id != photo.id).toList();
        notifyListeners();
      }
      return success;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}
