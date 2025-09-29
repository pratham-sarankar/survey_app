import 'dart:convert';

class Property {
  final String uid;
  final String fatherName;
  final String ownerName;
  final String mobileNo;

  Property({
    required this.uid,
    required this.fatherName,
    required this.ownerName,
    required this.mobileNo,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      uid: json['uid'] ?? '',
      fatherName: json['father_name'] ?? '',
      ownerName: json['owner_name'] ?? '',
      mobileNo: json['mobile_no'] ?? '',
    );
  }

  static List<Property> parsePropertiesJson(String jsonString) {
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Property.fromJson(json)).toList();
  }
}
