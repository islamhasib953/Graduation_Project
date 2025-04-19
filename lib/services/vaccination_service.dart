// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:segma/models/vaccination_model.dart';
// import 'package:segma/services/auth_service.dart';

// class VaccinationService {
//   static const String baseUrl = 'https://graduation-projectgmabackend.vercel.app/api';

//   // جلب التطعيمات الخاصة بطفل معين
//   static Future<Map<String, dynamic>> getVaccinations(String childId) async {
//     try {
//       final String? token = await AuthService.getToken();
//       if (token == null) {
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$baseUrl/vaccinations/$childId');
//       final headers = await AuthService.getHeaders(token);
//       print('Sending GET request to $url with headers: $headers');

//       final response = await http.get(url, headers: headers);

//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final List<dynamic> vaccinations = data['data'] ?? [];
//         final result = {
//           'status': 'success',
//           'data': vaccinations.map((v) => Vaccination.fromJson(v)).toList(),
//         };
//         print('Success: $result');
//         return result;
//       } else if (response.statusCode == 404) {
//         final result = {'status': 'success', 'data': []};
//         print('Success (Empty Data): $result');
//         return result;
//       }

//       final errorResult = {
//         'status': 'error',
//         'message': _handleVaccinationError(response.statusCode, data),
//       };
//       print('Error: $errorResult');
//       return errorResult;
//     } catch (e) {
//       final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//       print('Exception caught: $errorResult');
//       return errorResult;
//     }
//   }

//   // تسجيل تفاصيل التطعيم (Taken/Skipped، التاريخ، الملاحظات، الصورة)
//   static Future<Map<String, dynamic>> logVaccination({
//     required String childId,
//     required String userVaccinationId,
//     required String status,
//     required DateTime actualDate,
//     String? notes,
//     String? image,
//   }) async {
//     try {
//       final String? token = await AuthService.getToken();
//       if (token == null) {
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$baseUrl/vaccinations/$childId/$userVaccinationId');
//       final headers = await AuthService.getHeaders(token);
//       final body = {
//         'status': status,
//         'actualDate': actualDate.toIso8601String(),
//         'notes': notes ?? '',
//         'image': image ?? '',
//       };

//       print('Sending PATCH request to $url with headers: $headers');
//       print('Request body: ${jsonEncode(body)}');

//       final response = await http.patch(
//         url,
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       print('Response Status Code: ${response.statusCode}');
//       print('Response Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final result = {
//           'status': 'success',
//           'message': 'تم تسجيل التطعيم بنجاح',
//           'data': VaccinationLog.fromJson(data['data']),
//         };
//         print('Success: $result');
//         return result;
//       }

//       final errorResult = {
//         'status': 'error',
//         'message': _handleVaccinationError(response.statusCode, data),
//       };
//       print('Error: $errorResult');
//       return errorResult;
//     } catch (e) {
//       final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//       print('Exception caught: $errorResult');
//       return errorResult;
//     }
//   }

//   static String _handleVaccinationError(int statusCode, Map<String, dynamic> data) {
//     final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
//     switch (statusCode) {
//       case 400:
//         return 'بيانات التطعيم غير صالحة: $serverMessage';
//       case 401:
//         return 'انتهت الجلسة، من فضلك سجل الدخول مرة أخرى';
//       case 404:
//         return 'التطعيم غير موجود';
//       case 500:
//         return 'خطأ في الخادم: $serverMessage';
//       default:
//         return 'فشل العملية (الكود: $statusCode): $serverMessage';
//     }
//   }
// }


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:segma/models/vaccination_model.dart';

class VaccinationService {
  static const String baseUrl = 'https://graduation-projectgmabackend.vercel.app/api';

  static Future<Map<String, dynamic>> getVaccinations(String childId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('✅ Retrieved Token from SharedPreferences: $token');

      if (token == null) {
        return {'status': 'error', 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vaccinations/$childId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Sending GET request to $baseUrl/vaccinations/$childId with headers: {Content-Type: application/json, Authorization: Bearer $token}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        final List<dynamic> data = result['data'];
        final List<Vaccination> vaccinations = data.map((json) => Vaccination.fromJson(json)).toList();
        return {'status': 'success', 'data': vaccinations};
      } else {
        return {'status': 'error', 'message': result['message'] ?? 'Failed to fetch vaccinations'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getVaccinationById(String childId, String userVaccinationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('✅ Retrieved Token from SharedPreferences: $token');

      if (token == null) {
        return {'status': 'error', 'message': 'No token found'};
      }

      final response = await http.get(
        Uri.parse('$baseUrl/vaccinations/$childId/$userVaccinationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Sending GET request to $baseUrl/vaccinations/$childId/$userVaccinationId with headers: {Content-Type: application/json, Authorization: Bearer $token}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        final data = result['data'];
        final Vaccination vaccination = Vaccination.fromJson(data);
        return {'status': 'success', 'data': vaccination};
      } else {
        return {'status': 'error', 'message': result['message'] ?? 'Failed to fetch vaccination'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> logVaccination({
    required String childId,
    required String userVaccinationId,
    required String status,
    required DateTime actualDate,
    required String notes,
    required String? image,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      print('✅ Retrieved Token from SharedPreferences: $token');

      if (token == null) {
        return {'status': 'error', 'message': 'No token found'};
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/vaccinations/$childId/$userVaccinationId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'status': status,
          'actualDate': actualDate.toIso8601String(),
          'notes': notes,
          'image': image,
        }),
      );

      print('Sending PATCH request to $baseUrl/vaccinations/$childId/$userVaccinationId with headers: {Content-Type: application/json, Authorization: Bearer $token}');
      print('Request body: ${jsonEncode({'status': status, 'actualDate': actualDate.toIso8601String(), 'notes': notes, 'image': image})}');
      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final result = jsonDecode(response.body);

      if (response.statusCode == 200 && result['status'] == 'success') {
        return {'status': 'success', 'data': result['data']};
      } else {
        return {'status': 'error', 'message': result['message'] ?? 'Failed to log vaccination'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }
}