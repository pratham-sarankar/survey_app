import 'package:json_annotation/json_annotation.dart';

part 'survey.g.dart';

@JsonSerializable()
class Survey {
  final int id;
  @JsonKey(name: 'property_uid')
  final String propertyUid;
  @JsonKey(name: 'qr_id')
  final String qrId;
  @JsonKey(name: 'owner_name')
  final String ownerName;
  @JsonKey(name: 'father_or_spouse_name')
  final String fatherOrSpouseName;
  @JsonKey(name: 'ward_number')
  final String wardNumber;
  @JsonKey(name: 'contact_number')
  final String contactNumber;
  @JsonKey(name: 'whatsapp_number')
  final String whatsappNumber;
  final double latitude;
  final double longitude;
  @JsonKey(name: 'surveyor_profile_id')
  final int surveyorProfileId;
  @JsonKey(
    name: 'created_at',
    fromJson: _dateTimeFromString,
    toJson: _dateTimeToString,
  )
  final DateTime createdAt;
  @JsonKey(
    name: 'updated_at',
    fromJson: _dateTimeFromString,
    toJson: _dateTimeToString,
  )
  final DateTime updatedAt;

  Survey({
    required this.id,
    required this.propertyUid,
    required this.qrId,
    required this.ownerName,
    required this.fatherOrSpouseName,
    required this.wardNumber,
    required this.contactNumber,
    required this.whatsappNumber,
    required this.latitude,
    required this.longitude,
    required this.surveyorProfileId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Survey.fromJson(Map<String, dynamic> json) => _$SurveyFromJson(json);
  Map<String, dynamic> toJson() => _$SurveyToJson(this);

  static DateTime _dateTimeFromString(String date) => DateTime.parse(date);
  static String _dateTimeToString(DateTime date) => date.toIso8601String();
}
