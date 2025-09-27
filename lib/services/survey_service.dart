import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/survey_entry.dart';
import '../config/api_config.dart';

class SurveyService {
  final String? _token;

  SurveyService(this._token);

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<List<SurveyEntry>> getMyEntries(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/surveys/user/$userId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SurveyEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load entries: ${response.body}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockEntries().where((entry) => entry.userId == userId).toList();
    }
  }

  Future<List<SurveyEntry>> getAllEntries() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/surveys'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => SurveyEntry.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load entries: ${response.body}');
      }
    } catch (e) {
      // Return mock data for demo purposes
      return _getMockEntries();
    }
  }

  Future<SurveyEntry> createEntry(SurveyEntry entry) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/surveys'),
        headers: _headers,
        body: jsonEncode(entry.toJson()),
      );

      if (response.statusCode == 201) {
        return SurveyEntry.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to create entry: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, return the entry with a mock ID
      return entry.copyWith(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
  }

  Future<SurveyEntry> updateEntry(SurveyEntry entry) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}/surveys/${entry.id}'),
        headers: _headers,
        body: jsonEncode(entry.toJson()),
      );

      if (response.statusCode == 200) {
        return SurveyEntry.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to update entry: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, return the entry with updated timestamp
      return entry.copyWith(updatedAt: DateTime.now());
    }
  }

  Future<void> deleteEntry(String entryId) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}/surveys/$entryId'),
        headers: _headers,
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to delete entry: ${response.body}');
      }
    } catch (e) {
      // For demo purposes, just ignore the error
    }
  }

  List<SurveyEntry> _getMockEntries() {
    final now = DateTime.now();
    return [
      SurveyEntry(
        id: '1',
        uid: 'UID001',
        areaCode: 'AREA001',
        qrPlateHouseNumber: 'QR001',
        ownerNameHindi: 'राम शर्मा',
        ownerNameEnglish: 'Ram Sharma',
        mobileNumber: '9876543210',
        whatsappNumber: '9876543210',
        latitude: 28.6139,
        longitude: 77.2090,
        notes: 'Sample property in Delhi',
        propertyStatus: PropertyStatus.newProperty,
        images: [],
        userId: '2',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      SurveyEntry(
        id: '2',
        uid: 'UID002',
        areaCode: 'AREA002',
        qrPlateHouseNumber: 'QR002',
        ownerNameHindi: 'सीता देवी',
        ownerNameEnglish: 'Sita Devi',
        mobileNumber: '9876543211',
        whatsappNumber: '9876543211',
        latitude: 28.7041,
        longitude: 77.1025,
        notes: 'Extended property',
        propertyStatus: PropertyStatus.extended,
        images: [],
        userId: '1',
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }
}