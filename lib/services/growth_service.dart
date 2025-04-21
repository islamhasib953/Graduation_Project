import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segma/models/growth_model.dart';
import 'package:segma/services/auth_service.dart';

class GrowthService {
  Future<List<GrowthRecord>> getAllGrowthRecords(String childId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('${AuthService.baseUrl}/growth/$childId');
      final headers = await AuthService.getHeaders(token);

      print('Fetching growth records for childId: $childId');
      print('Request URL: $url');
      print('Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final List<dynamic> records = data['data'] ?? [];
          return records.map((json) => GrowthRecord.fromJson(json)).toList();
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch growth records');
        }
      } else if (response.statusCode == 404) {
        return []; // Return empty list if no records found
      } else {
        throw Exception('Failed to fetch growth records: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getAllGrowthRecords: $e');
      throw Exception('Error fetching growth records: $e');
    }
  }

  Future<GrowthRecord?> getLastGrowthRecord(String childId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('${AuthService.baseUrl}/growth/$childId/last');
      final headers = await AuthService.getHeaders(token);

      print('Fetching last growth record for childId: $childId');
      print('Request URL: $url');
      print('Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final record = data['data'];
          return record != null ? GrowthRecord.fromJson(record) : null;
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch last growth record');
        }
      } else if (response.statusCode == 404) {
        return null; // No record found
      } else {
        throw Exception('Failed to fetch last growth record: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getLastGrowthRecord: $e');
      throw Exception('Error fetching last growth record: $e');
    }
  }

  Future<GrowthChanges> getGrowthChanges(String childId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('${AuthService.baseUrl}/growth/$childId/last-change');
      final headers = await AuthService.getHeaders(token);

      print('Fetching growth changes for childId: $childId');
      print('Request URL: $url');
      print('Headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          final changeData = data['data'];
          return GrowthChanges(
            previousRecord: changeData['previousRecord'] != null
                ? GrowthRecord.fromJson(changeData['previousRecord'])
                : null,
            changes: GrowthChange(
              heightChange: (changeData['changes']['heightChange'] as num?)?.toDouble() ?? 0.0,
              weightChange: (changeData['changes']['weightChange'] as num?)?.toDouble() ?? 0.0,
              headCircumferenceChange: (changeData['changes']['headCircumferenceChange'] as num?)?.toDouble() ?? 0.0,
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch growth changes');
        }
      } else if (response.statusCode == 404) {
        return GrowthChanges(
          previousRecord: null,
          changes: const GrowthChange(heightChange: 0, weightChange: 0, headCircumferenceChange: 0),
        );
      } else {
        throw Exception('Failed to fetch growth changes: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in getGrowthChanges: $e');
      throw Exception('Error calculating growth changes: $e');
    }
  }

  Future<GrowthRecord> addGrowthRecord(String childId, Map<String, dynamic> data) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('${AuthService.baseUrl}/growth/$childId');
      final headers = await AuthService.getHeaders(token);

      print('Adding growth record for childId: $childId');
      print('Request URL: $url');
      print('Headers: $headers');
      print('Request Body: ${jsonEncode(data)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'success') {
          return GrowthRecord.fromJson(responseData['data']['growth']);
        } else {
          throw Exception(responseData['message'] ?? 'Failed to add growth record');
        }
      } else {
        throw Exception('Failed to add growth record: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in addGrowthRecord: $e');
      throw Exception('Error adding growth record: $e');
    }
  }

  Future<void> updateGrowthRecord(String childId, String growthId, Map<String, dynamic> data) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('${AuthService.baseUrl}/growth/$childId/$growthId');
      final headers = await AuthService.getHeaders(token);

      print('Updating growth record for childId: $childId, growthId: $growthId');
      print('Request URL: $url');
      print('Headers: $headers');
      print('Request Body: ${jsonEncode(data)}');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(data),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to update growth record: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in updateGrowthRecord: $e');
      throw Exception('Error updating growth record: $e');
    }
  }

  Future<void> deleteGrowthRecord(String childId, String growthId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final url = Uri.parse('${AuthService.baseUrl}/growth/$childId/$growthId');
      final headers = await AuthService.getHeaders(token);

      print('Deleting growth record for childId: $childId, growthId: $growthId');
      print('Request URL: $url');
      print('Headers: $headers');

      final response = await http.delete(url, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete growth record: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in deleteGrowthRecord: $e');
      throw Exception('Error deleting growth record: $e');
    }
  }
}