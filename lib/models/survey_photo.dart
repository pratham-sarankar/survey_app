import 'dart:io';

import '../config/api_config.dart';

class SurveyPhoto {
  final int id;
  final String imageName;
  final String imagePath;
  final DateTime createdAt;

  // Local-only properties
  final File? localFile;
  final bool isSynced;

  String get url => '${ApiConfig.baseUrl}/${imagePath.replaceAll('\\\\', '/')}';

  SurveyPhoto({
    required this.id,
    required this.imageName,
    required this.imagePath,
    required this.createdAt,
    this.localFile,
    this.isSynced = false,
  });

  factory SurveyPhoto.fromJson(Map<String, dynamic> json) {
    return SurveyPhoto(
      id: json['id'],
      imageName: json['image_name'],
      imagePath: json['image_path'],
      createdAt: DateTime.parse(json['created_at']),
      isSynced: true,
    );
  }

  factory SurveyPhoto.local({
    required String surveyId,
    required File file,
    required String fileName,
  }) {
    return SurveyPhoto(
      id: DateTime.now().millisecondsSinceEpoch,
      imageName: fileName,
      imagePath: '', // Will be set by server
      createdAt: DateTime.now(),
      localFile: file,
      isSynced: false,
    );
  }

  SurveyPhoto copyWith({
    int? id,
    String? imageName,
    String? imagePath,
    DateTime? createdAt,
    File? localFile,
    bool? isSynced,
  }) {
    return SurveyPhoto(
      id: id ?? this.id,
      imageName: imageName ?? this.imageName,
      imagePath: imagePath ?? this.imagePath,
      createdAt: createdAt ?? this.createdAt,
      localFile: localFile ?? this.localFile,
      isSynced: isSynced ?? this.isSynced,
    );
  }
}
