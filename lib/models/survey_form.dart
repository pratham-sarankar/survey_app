class SurveyForm {
  String propertyUid;
  String qrId;
  String ownerName;
  String fatherOrSpouseName;
  String wardNumber;
  String contactNumber;
  String whatsappNumber;
  double latitude;
  double longitude;

  SurveyForm({
    this.propertyUid = '',
    this.qrId = '',
    this.ownerName = '',
    this.fatherOrSpouseName = '',
    this.wardNumber = '',
    this.contactNumber = '',
    this.whatsappNumber = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
  });

  Map<String, dynamic> toJson() {
    return {
      'property_uid': propertyUid,
      'qr_id': qrId,
      'owner_name': ownerName,
      'father_or_spouse_name': fatherOrSpouseName,
      'ward_number': wardNumber,
      'contact_number': contactNumber,
      'whatsapp_number': whatsappNumber,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
