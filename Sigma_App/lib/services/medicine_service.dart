import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segma/models/medication_model.dart';
import 'package:segma/services/auth_service.dart';

class MedicineService {
  static Future<Map<String, dynamic>> addMedication(Medication medication,
      {required String childId}) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? token = await AuthService.getToken();

      if (userId == null || token == null) {
        print('❌ Missing Auth Data:');
        print('├─ User ID: $userId');
        print('└─ Token: $token');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      if (medication.name.isEmpty) {
        return {'status': 'error', 'message': 'اسم الدواء مطلوب'};
      }
      if (medication.days.isEmpty) {
        return {'status': 'error', 'message': 'يجب اختيار يوم واحد على الأقل'};
      }
      if (medication.times.isEmpty) {
        return {'status': 'error', 'message': 'يجب اختيار وقت واحد على الأقل'};
      }
      print(childId);
      final url = Uri.parse(
          '${AuthService.baseUrl}/medicines/$childId'); // تعديل الـ URL لإضافة childId في المسار
      final requestBody = {
        'name': medication.name,
        'days': medication.days,
        'times': medication.times,
        'userId': userId,
      };

      final headers = await AuthService.getHeaders(token); // تعديل: استخدام await
      print('\n📤 Add Medication Request:');
      print('├─ URL: $url');
      print('├─ Headers: $headers');
      print('└─ Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(requestBody),
      );

      print('\n📥 Medication Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final medicationData = data['data']?['medicine'];
        if (medicationData != null) {
          final addedMedication = Medication.fromJson(medicationData);
          print('\n✅ Medication Added:');
          print('├─ ID: ${addedMedication.id}');
          print('├─ Name: ${addedMedication.name}');
          print('├─ Days: ${addedMedication.days.join(', ')}');
          print('└─ Times: ${addedMedication.times.join(', ')}');
          return {
            'status': 'success',
            'message': 'تم إضافة الدواء بنجاح',
            'data': addedMedication,
          };
        }
        return {
          'status': 'error',
          'message': 'فشل في استرجاع بيانات الدواء المضاف',
        };
      } else {
        final errorMessage = _handleMedicationError(response.statusCode, data);
        print('\n❌ Medication Error: $errorMessage');
        return {'status': 'error', 'message': errorMessage, 'data': data};
      }
    } catch (e) {
      print('\n🔥 Add Medication Error: $e');
      return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> getMedications(
      {required String childId}) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? token = await AuthService.getToken();

      if (userId == null || token == null) {
        print('❌ Missing Auth Data:');
        print('├─ User ID: $userId');
        print('└─ Token: $token');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('${AuthService.baseUrl}/medicines/$childId');

      final headers = await AuthService.getHeaders(token); // تعديل: استخدام await
      print('\n📤 Get Medications Request:');
      print('├─ URL: $url');
      print('└─ Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      print('\n📥 Medications Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> medicines = data['data'] ?? [];
        final medications =
            medicines.map((m) => Medication.fromJson(m)).toList();
        return {
          'status': 'success',
          'data': medications,
        };
      }
      return {
        'status': 'error',
        'message': _handleMedicationError(response.statusCode, data),
      };
    } catch (e) {
      print('\n🔥 Get Medications Error: $e');
      return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateMedication(Medication medication,
      {required String childId}) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? token = await AuthService.getToken();

      if (userId == null || token == null) {
        print('❌ Missing Auth Data:');
        print('├─ User ID: $userId');
        print('└─ Token: $token');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      if (medication.id.isEmpty) {
        return {'status': 'error', 'message': 'معرف الدواء مطلوب'};
      }

      final url = Uri.parse(
          '${AuthService.baseUrl}/medicines/${medication.id}/$childId');
      final body = {
        'name': medication.name,
        'days': medication.days,
        'times': medication.times,
        'userId': userId,
      };

      final headers = await AuthService.getHeaders(token); // تعديل: استخدام await
      print('\n📤 Update Medication Request:');
      print('├─ URL: $url');
      print('├─ Headers: $headers');
      print('└─ Body: ${jsonEncode(body)}');

      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('\n📥 Update Medication Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedMedication = Medication.fromJson(data['data']);
        return {
          'status': 'success',
          'message': 'تم تحديث الدواء بنجاح',
          'data': updatedMedication,
        };
      }
      return {
        'status': 'error',
        'message': _handleMedicationError(response.statusCode, data),
      };
    } catch (e) {
      print('\n🔥 Update Medication Error: $e');
      return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> deleteMedication(String medicationId,
      {required String childId}) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? token = await AuthService.getToken();

      if (userId == null || token == null) {
        print('❌ Missing Auth Data:');
        print('├─ User ID: $userId');
        print('└─ Token: $token');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      if (medicationId.isEmpty) {
        return {'status': 'error', 'message': 'معرف الدواء مطلوب'};
      }

      final url =
          Uri.parse('${AuthService.baseUrl}/medicines/$medicationId/$childId');

      final headers = await AuthService.getHeaders(token); // تعديل: استخدام await
      print('\n📤 Delete Medication Request:');
      print('├─ URL: $url');
      print('└─ Headers: $headers');

      final response = await http.delete(
        url,
        headers: headers,
      );

      print('\n📥 Delete Medication Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': 'success',
          'message': 'تم حذف الدواء بنجاح',
        };
      }
      return {
        'status': 'error',
        'message': _handleMedicationError(response.statusCode, data),
      };
    } catch (e) {
      print('\n🔥 Delete Medication Error: $e');
      return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
    }
  }

  static String _handleMedicationError(
      int statusCode, Map<String, dynamic> data) {
    final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
    switch (statusCode) {
      case 400:
        return 'بيانات الدواء غير صالحة: $serverMessage';
      case 401:
        return 'انتهت الجلسة، من فضلك سجل الدخول مرة أخرى';
      case 404:
        return 'الدواء أو المستخدم غير موجود';
      default:
        return 'فشل العملية (الكود: $statusCode): $serverMessage';
    }
  }
}