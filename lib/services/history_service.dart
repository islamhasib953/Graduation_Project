import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segma/models/history_model.dart';
import 'package:segma/services/auth_service.dart';

class HistoryService {
  static const String baseUrl = 'https://graduation-projectgmabackend.vercel.app/api';

  static Future<Map<String, dynamic>> addHistory(History history, String childId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        print('Error: No token found. User must log in.');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('$baseUrl/history/$childId');
      final headers = await AuthService.getHeaders(token);
      print('Sending POST request to $url with headers: $headers');
      print('Request body: ${jsonEncode(history.toJson())}');

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(history.toJson()),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = {
          'status': 'success',
          'message': 'تم إضافة السجل بنجاح',
          'data': History.fromJson(data['data']),
        };
        print('Success: $result');
        return result;
      }

      final errorResult = {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
      print('Error: $errorResult');
      return errorResult;
    } catch (e) {
      final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
      print('Exception caught: $errorResult');
      return errorResult;
    }
  }

  static Future<Map<String, dynamic>> getHistories(String childId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        print('Error: No token found. User must log in.');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('$baseUrl/history/$childId');
      final headers = await AuthService.getHeaders(token);
      print('Sending GET request to $url with headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> histories = data['data'] ?? [];
        final result = {
          'status': 'success',
          'data': histories.map((h) => History.fromJson(h)).toList(),
        };
        print('Success: $result');
        return result;
      } else if (response.statusCode == 404) {
        final result = {'status': 'success', 'data': []};
        print('Success (Empty Data): $result');
        return result;
      }

      final errorResult = {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
      print('Error: $errorResult');
      return errorResult;
    } catch (e) {
      final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
      print('Exception caught: $errorResult');
      return errorResult;
    }
  }

  static Future<Map<String, dynamic>> getHistory(String childId, String historyId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        print('Error: No token found. User must log in.');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('$baseUrl/history/$childId/$historyId');
      final headers = await AuthService.getHeaders(token);
      print('Sending GET request to $url with headers: $headers');

      final response = await http.get(url, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final result = {
          'status': 'success',
          'data': History.fromJson(data['data']),
        };
        print('Success: $result');
        return result;
      }

      final errorResult = {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
      print('Error: $errorResult');
      return errorResult;
    } catch (e) {
      final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
      print('Exception caught: $errorResult');
      return errorResult;
    }
  }

  static Future<Map<String, dynamic>> updateHistory({
    required String childId,
    required String historyId,
    required History history,
  }) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        print('Error: No token found. User must log in.');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('$baseUrl/history/$childId/$historyId');
      final headers = await AuthService.getHeaders(token);
      print('Sending PATCH request to $url with headers: $headers');
      print('Request body: ${jsonEncode(history.toJson())}');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(history.toJson()),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final result = {
          'status': 'success',
          'message': 'تم تحديث السجل بنجاح',
          'data': History.fromJson(data['data']),
        };
        print('Success: $result');
        return result;
      }

      final errorResult = {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
      print('Error: $errorResult');
      return errorResult;
    } catch (e) {
      final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
      print('Exception caught: $errorResult');
      return errorResult;
    }
  }

  static Future<Map<String, dynamic>> deleteHistory(String childId, String historyId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        print('Error: No token found. User must log in.');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('$baseUrl/history/$childId/$historyId');
      final headers = await AuthService.getHeaders(token);
      print('Sending DELETE request to $url with headers: $headers');

      final response = await http.delete(url, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        final result = {
          'status': 'success',
          'message': 'تم حذف السجل بنجاح',
        };
        print('Success: $result');
        return result;
      }

      final errorResult = {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
      print('Error: $errorResult');
      return errorResult;
    } catch (e) {
      final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
      print('Exception caught: $errorResult');
      return errorResult;
    }
  }

  static Future<Map<String, dynamic>> filterHistories({
    required String childId,
    String? diagnosis,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
  }) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        print('Error: No token found. User must log in.');
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final Map<String, String> queryParams = {};
      if (diagnosis != null && diagnosis.isNotEmpty) {
        queryParams['diagnosis'] = diagnosis;
      }
      if (fromDate != null) {
        queryParams['fromDate'] = fromDate.toIso8601String();
      }
      if (toDate != null) {
        queryParams['toDate'] = toDate.toIso8601String();
      }
      if (sortBy != null && (sortBy == 'oldest' || sortBy == 'latest')) {
        queryParams['sortBy'] = sortBy;
      }

      final uri = Uri.parse('$baseUrl/history/filter/$childId').replace(queryParameters: queryParams);
      final headers = await AuthService.getHeaders(token);
      print('Sending GET request to $uri with headers: $headers');

      final response = await http.get(uri, headers: headers);

      print('Response Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> histories = data['data'] ?? [];
        final result = {
          'status': 'success',
          'data': histories.map((h) => History.fromJson(h)).toList(),
        };
        print('Success: $result');
        return result;
      }

      final errorResult = {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
      print('Error: $errorResult');
      return errorResult;
    } catch (e) {
      final errorResult = {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
      print('Exception caught: $errorResult');
      return errorResult;
    }
  }

  static String _handleHistoryError(int statusCode, Map<String, dynamic> data) {
    final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
    switch (statusCode) {
      case 400:
        return 'بيانات السجل غير صالحة: $serverMessage';
      case 401:
        return 'انتهت الجلسة، من فضلك سجل الدخول مرة أخرى';
      case 404:
        return 'السجل غير موجود';
      case 500:
        return 'خطأ في الخادم: $serverMessage';
      default:
        return 'فشل العملية (الكود: $statusCode): $serverMessage';
    }
  }
}