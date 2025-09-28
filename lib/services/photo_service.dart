import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../config/api_config.dart';
import '../models/survey_photo.dart';
import 'api_service.dart';

class PhotoService extends APIService {
  PhotoService(super.authService);

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<Directory> _getSurveyDirectory(String surveyId) async {
    final basePath = await _localPath;
    final surveyDir = Directory('$basePath/surveys/$surveyId/photos');
    if (!await surveyDir.exists()) {
      await surveyDir.create(recursive: true);
    }
    return surveyDir;
  }

  Future<List<SurveyPhoto>> getLocalPhotos(String surveyId) async {
    try {
      final surveyDir = await _getSurveyDirectory(surveyId);
      final files = await surveyDir.list().toList();

      return files.whereType<File>().map((file) {
        final fileName = path.basename(file.path);
        return SurveyPhoto.local(
          surveyId: surveyId,
          file: file,
          fileName: fileName,
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<SurveyPhoto>> getSyncedPhotos(
      BuildContext context, String surveyId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/surveys/$surveyId/images'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        final imagesJson = responseData['data']['images'] as List;
        return imagesJson.map((json) => SurveyPhoto.fromJson(json)).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load photos');
      }
    } catch (e) {
      print('Error loading photos: $e'); // For debugging
      throw Exception('Failed to load photos: $e');
    }
  }

  Future<SurveyPhoto?> savePhotoLocally(
      String surveyId, File sourceFile) async {
    try {
      final surveyDir = await _getSurveyDirectory(surveyId);

      // Use current timestamp for filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(sourceFile.path);
      final newFileName = '${surveyId}_$timestamp$extension';
      final destinationPath = path.join(surveyDir.path, newFileName);

      // Copy file to app directory
      final newFile = await sourceFile.copy(destinationPath);

      return SurveyPhoto.local(
        surveyId: surveyId,
        file: newFile,
        fileName: newFileName,
      );
    } catch (e) {
      print('Error saving photo locally: $e'); // For debugging
      return null;
    }
  }

  Future<bool> uploadPhotos(
      BuildContext context, String surveyId, List<File> files) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No auth token found');

      final uri =
          Uri.parse('${ApiConfig.baseUrl}/surveys/$surveyId/upload-images');
      final request = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..headers['accept'] = 'application/json';

      // Add all files to the request
      for (var file in files) {
        final stream = http.ByteStream(file.openRead());
        final length = await file.length();
        final filename = path.basename(file.path);

        final multipartFile = http.MultipartFile(
          'files',
          stream,
          length,
          filename: filename,
          contentType: _getContentType(filename),
        );
        request.files.add(multipartFile);
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        // Delete local files only after successful upload
        for (var file in files) {
          if (await file.exists()) {
            await file.delete();
          }
        }
        return true;
      }

      throw Exception(responseData['message'] ?? 'Failed to upload photos');
    } catch (e) {
      print('Upload error: $e'); // For debugging
      return false;
    }
  }

  Future<bool> deleteLocalPhoto(SurveyPhoto photo) async {
    try {
      if (photo.localFile != null && await photo.localFile!.exists()) {
        await photo.localFile!.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting local photo: $e'); // For debugging
      return false;
    }
  }

  Future<bool> deletePhoto(
      BuildContext context, String surveyId, int photoId) async {
    try {
      final token = await getToken();
      if (token == null) throw Exception('No auth token found');

      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/surveys/$surveyId/images/$photoId'),
        headers: {
          'Authorization': 'Bearer $token',
          'accept': 'application/json',
        },
      );

      if (response.statusCode == 401) {
        if (context.mounted) {
          await handleUnauthorized(context);
        }
        throw Exception('Unauthorized');
      }

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return true;
      }

      throw Exception(responseData['message'] ?? 'Failed to delete photo');
    } catch (e) {
      print('Delete photo error: $e'); // For debugging
      throw Exception('Failed to delete photo: $e');
    }
  }

  MediaType? _getContentType(String filename) {
    final ext = path.extension(filename).toLowerCase();
    switch (ext) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.heic':
        return MediaType('image', 'heic');
      default:
        return null;
    }
  }
}
