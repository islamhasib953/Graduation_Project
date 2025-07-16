import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:segma/models/history_model.dart';
import 'package:segma/services/auth_service.dart';
import 'package:flutter/foundation.dart';

class HistoryService {
  static const String baseUrl = 'http://35.173.178.21:8000/api';

  static Future<Map<String, dynamic>> addHistory(History history, String childId, dynamic image) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'You must log in'};
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/history/$childId'));
      request.headers.addAll(await AuthService.getHeaders(token));
      request.fields.addAll({
        'diagnosis': history.diagnosis,
        'disease': history.disease,
        'treatment': history.treatment,
        'notes': history.notes,
        'date': history.date.toIso8601String(),
        'time': history.time,
      });

      if (image != null) {
        if (kIsWeb && image is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes('notesImage', image, filename: 'notes_image.png'));
        } else if (image is File) {
          request.files.add(await http.MultipartFile.fromPath('notesImage', image.path));
        }
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final Map<String, dynamic> data = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': 'success',
          'message': 'Record added successfully',
          'data': data['data'],
        };
      }
      return {
        'status': 'error',
        'message': data['message'] ?? 'Failed to add history',
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Technical error: Failed to add history - $e'};
    }
  }

  static Future<Map<String, dynamic>> getHistories(String childId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'You must log in'};
      }

      final url = Uri.parse('$baseUrl/history/$childId');
      final headers = await AuthService.getHeaders(token);
      final response = await http.get(url, headers: headers);

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['status'] == 'success') {
        return {
          'status': 'success',
          'data': data['data'],
        };
      } else if (response.statusCode == 404 && data['data'] == null) {
        return {
          'status': 'success',
          'data': [],
        };
      }
      return {
        'status': 'error',
        'message': data['message'] ?? 'Failed to fetch history',
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Technical error: Failed to fetch history'};
    }
  }

  static Future<Map<String, dynamic>> getHistory(String childId, String historyId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'You must log in'};
      }

      final url = Uri.parse('$baseUrl/history/$childId/$historyId');
      final headers = await AuthService.getHeaders(token);
      final response = await http.get(url, headers: headers);

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final resultData = data['data'];
        if (resultData is Map<String, dynamic>) {
          try {
            return {
              'status': 'success',
              'data': History.fromJson(resultData),
            };
          } catch (e) {
            return {
              'status': 'error',
              'message': 'Invalid data format from server',
            };
          }
        }
        return {
          'status': 'error',
          'message': 'Invalid data format from server',
        };
      }

      return {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateHistory({
    required String childId,
    required String historyId,
    required History history,
    dynamic image,
  }) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'You must log in'};
      }

      var request = http.MultipartRequest('PATCH', Uri.parse('$baseUrl/history/$childId/$historyId'));
      request.headers.addAll(await AuthService.getHeaders(token));
      request.fields['diagnosis'] = history.diagnosis;
      request.fields['disease'] = history.disease;
      request.fields['treatment'] = history.treatment;
      request.fields['notes'] = history.notes;
      request.fields['date'] = history.date.toIso8601String();
      request.fields['time'] = history.time;

      if (image != null) {
        if (kIsWeb && image is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes('notesImage', image, filename: 'notes_image.png'));
        } else if (image is File) {
          request.files.add(await http.MultipartFile.fromPath('notesImage', image.path));
        }
      } else if (history.notesImage.isNotEmpty) {
        request.fields['notesImage'] = history.notesImage;
      }

      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      final Map<String, dynamic> data = jsonDecode(respStr);

      if (response.statusCode == 200) {
        final resultData = data['data'];
        if (resultData is Map<String, dynamic>) {
          try {
            return {
              'status': 'success',
              'message': 'Record updated successfully',
              'data': History.fromJson(resultData),
            };
          } catch (e) {
            return {
              'status': 'success',
              'message': 'Record updated successfully',
              'data': null,
            };
          }
        }
        return {
          'status': 'success',
          'message': 'Record updated successfully',
          'data': null,
        };
      }

      return {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> deleteHistory(String childId, String historyId) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'You must log in'};
      }

      final url = Uri.parse('$baseUrl/history/$childId/$historyId');
      final headers = await AuthService.getHeaders(token);
      final response = await http.delete(url, headers: headers);

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 204) {
        return {
          'status': 'success',
          'message': 'Record deleted successfully',
        };
      }

      return {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
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
        return {'status': 'error', 'message': 'You must log in'};
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
      final response = await http.get(uri, headers: headers);

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> histories = data['data'] ?? [];
        final parsedHistories = histories.map((h) {
          if (h is Map<String, dynamic>) {
            try {
              return History.fromJson(h);
            } catch (e) {
              print('Error parsing history item: $e, Item: $h');
              return null;
            }
          }
          return null;
        }).whereType<History>().toList();
        return {
          'status': 'success',
          'data': parsedHistories,
        };
      }

      return {
        'status': 'error',
        'message': _handleHistoryError(response.statusCode, data),
      };
    } catch (e) {
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
    }
  }

  static String _handleHistoryError(int statusCode, Map<String, dynamic> data) {
    final serverMessage = data['message'] ?? 'No error message available';
    switch (statusCode) {
      case 400:
        return 'Invalid record data: $serverMessage';
      case 401:
        return 'Session expired, please log in again';
      case 404:
        return 'Record not found';
      case 500:
        return 'Server error: $serverMessage';
      default:
        return 'Operation failed (Code: $statusCode): $serverMessage';
    }
  }
}