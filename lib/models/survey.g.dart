// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'survey.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Survey _$SurveyFromJson(Map<String, dynamic> json) => Survey(
      id: (json['id'] as num).toInt(),
      propertyUid: json['property_uid'] as String,
      qrId: json['qr_id'] as String,
      ownerName: json['owner_name'] as String,
      fatherOrSpouseName: json['father_or_spouse_name'] as String,
      wardNumber: json['ward_number'] as String,
      contactNumber: json['contact_number'] as String,
      whatsappNumber: json['whatsapp_number'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      surveyorProfileId: (json['surveyor_profile_id'] as num?)?.toInt(),
      createdAt: Survey._dateTimeFromString(json['created_at'] as String?),
      updatedAt: Survey._dateTimeFromString(json['updated_at'] as String?),
    );

Map<String, dynamic> _$SurveyToJson(Survey instance) => <String, dynamic>{
      'id': instance.id,
      'property_uid': instance.propertyUid,
      'qr_id': instance.qrId,
      'owner_name': instance.ownerName,
      'father_or_spouse_name': instance.fatherOrSpouseName,
      'ward_number': instance.wardNumber,
      'contact_number': instance.contactNumber,
      'whatsapp_number': instance.whatsappNumber,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'surveyor_profile_id': instance.surveyorProfileId,
      'created_at': Survey._dateTimeToString(instance.createdAt),
      'updated_at': Survey._dateTimeToString(instance.updatedAt),
    };
