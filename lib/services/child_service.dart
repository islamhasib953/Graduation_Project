import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:segma/models/child_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/services/auth_service.dart';

class ChildService {
  static Future<Map<String, dynamic>> getChildren() async {
    try {
      final String? token = await AuthService.getToken();
      final String? userId = await AuthService.getUserId();

      if (token == null || userId == null) {
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('${AuthService.baseUrl}/children?userId=$userId');

      final headers = await AuthService.getHeaders(token); // تعديل: استخدام await
      print('\n📤 Get Children Request:');
      print('├─ URL: $url');
      print('└─ Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      );

      print('\n📥 Get Children Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> children = data['data'] ?? [];
        return {
          'status': 'success',
          'data': children.map<Child>((c) => Child.fromJson(c)).toList(),
        };
      }
      return {
        'status': 'error',
        'message': 'فشل في جلب الأطفال',
      };
    } catch (e) {
      print('\n🔥 Get Children Error: $e');
      return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> addChild(Child child, BuildContext context) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? token = await AuthService.getToken();

      if (userId == null || token == null) {
        print('❌ Missing Auth Data:');
        print('├─ User ID: $userId');
        print('└─ Token: $token');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('${AuthService.baseUrl}/children');
      final body = {
        'userId': userId,
        'name': child.name,
        'gender': child.gender,
        'birthDate': DateFormat('yyyy-MM-dd').format(child.birthDate),
        'heightAtBirth': child.heightAtBirth,
        'weightAtBirth': child.weightAtBirth,
        'bloodType': child.bloodType,
        'photo': null,
      };

      final headers = await AuthService.getHeaders(token); // تعديل: استخدام await
      print('\n📤 Add Child Request:');
      print('├─ URL: $url');
      print('├─ Headers: $headers');
      print('└─ Body: ${jsonEncode(body)}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      print('\n📥 Add Child Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String? childId = data['data']?['child']?['_id'];
        if (childId != null) {
          // Set the newly added child as the default selected child
          context.read<SelectedChildCubit>().selectChild(childId);
          print('🔑 Set childId in Cubit: $childId');
          print('🎉 Successfully added child with ID: $childId');
        } else {
          print('⚠️ Child ID not found in response');
        }
        return {
          'status': 'success',
          'message': 'تم إضافة الطفل بنجاح',
          'data': data['data'],
        };
      }
      return {
        'status': 'error',
        'message': _handleError(response.statusCode, data),
      };
    } catch (e) {
      print('\n🔥 Add Child Error: $e');
      return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
    }
  }

  static String _handleError(int statusCode, Map<String, dynamic> data) {
    final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
    switch (statusCode) {
      case 400:
        return 'بيانات غير صالحة: $serverMessage';
      case 401:
        return 'انتهت الجلسة، من فضلك سجل الدخول مرة أخرى';
      case 404:
        return 'المورد غير موجود';
      case 500:
        return 'خطأ في الخادم: $serverMessage';
      default:
        return 'فشل العملية (الكود: $statusCode): $serverMessage';
    }
  }
}


