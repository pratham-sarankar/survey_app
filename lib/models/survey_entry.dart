import 'package:json_annotation/json_annotation.dart';

part 'survey_entry.g.dart';

enum PropertyStatus {
  @JsonValue('owner_changed')
  ownerChanged,
  @JsonValue('new_property')
  newProperty,
  @JsonValue('extended')
  extended,
  @JsonValue('demolished')
  demolished,
}

@JsonSerializable()
class SurveyEntry {
  final String? id;
  final String uid;
  final String areaCode;
  final String qrPlateHouseNumber;
  final String ownerNameHindi;
  final String ownerNameEnglish;
  final String mobileNumber;
  final String whatsappNumber;
  final double latitude;
  final double longitude;
  final String? notes;
  final PropertyStatus? propertyStatus;
  final List<String> images;
  final String userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SurveyEntry({
    this.id,
    required this.uid,
    required this.areaCode,
    required this.qrPlateHouseNumber,
    required this.ownerNameHindi,
    required this.ownerNameEnglish,
    required this.mobileNumber,
    required this.whatsappNumber,
    required this.latitude,
    required this.longitude,
    this.notes,
    this.propertyStatus,
    this.images = const [],
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SurveyEntry.fromJson(Map<String, dynamic> json) =>
      _$SurveyEntryFromJson(json);
  Map<String, dynamic> toJson() => _$SurveyEntryToJson(this);

  SurveyEntry copyWith({
    String? id,
    String? uid,
    String? areaCode,
    String? qrPlateHouseNumber,
    String? ownerNameHindi,
    String? ownerNameEnglish,
    String? mobileNumber,
    String? whatsappNumber,
    double? latitude,
    double? longitude,
    String? notes,
    PropertyStatus? propertyStatus,
    List<String>? images,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SurveyEntry(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      areaCode: areaCode ?? this.areaCode,
      qrPlateHouseNumber: qrPlateHouseNumber ?? this.qrPlateHouseNumber,
      ownerNameHindi: ownerNameHindi ?? this.ownerNameHindi,
      ownerNameEnglish: ownerNameEnglish ?? this.ownerNameEnglish,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      propertyStatus: propertyStatus ?? this.propertyStatus,
      images: images ?? this.images,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SurveyEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'SurveyEntry(id: $id, uid: $uid, areaCode: $areaCode, qrPlateHouseNumber: $qrPlateHouseNumber)';
  }
}