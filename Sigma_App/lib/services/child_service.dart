// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:segma/models/child_model.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';
// import 'package:segma/services/auth_service.dart';

// class ChildService {
//   static Future<Map<String, dynamic>> getChildren() async {
//     try {
//       final String? token = await AuthService.getToken();
//       final String? userId = await AuthService.getUserId();

//       if (token == null || userId == null) {
//         return {'status': 'error', 'message': 'You must be logged in'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/children?userId=$userId');

//       final headers = await AuthService.getHeaders(token);
//       print('\n📤 Get Children Request:');
//       print('├─ URL:-; $url');
//       print('└─ Headers: $headers');

//       final response = await http.get(
//         url,
//         headers: headers,
//       );

//       print('\n📥 Get Children Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final List<dynamic> children = data['data'] ?? [];
//         return {
//           'status': 'success',
//           'data': children.map<Child>((c) => Child.fromJson(c)).toList(),
//         };
//       }
//       return {
//         'status': 'error',
//         'message': 'Failed to fetch children',
//       };
//     } catch (e) {
//       print('\n🔥 Get Children Error: $e');
//       return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> addChild(Child child, BuildContext context) async {
//     try {
//       final String? userId = await AuthService.getUserId();
//       final String? token = await AuthService.getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'You must be logged in'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/children');
//       final body = {
//         'userId': userId,
//         'name': child.name,
//         'gender': child.gender,
//         'birthDate': DateFormat('yyyy-MM-dd').format(child.birthDate),
//         'heightAtBirth': child.heightAtBirth,
//         'weightAtBirth': child.weightAtBirth,
//         'headCircumferenceAtBirth': child.headCircumferenceAtBirth,
//         'bloodType': child.bloodType,
//         'photo': null,
//         'parentPhone': child.parentPhone,
//       };

//       final headers = await AuthService.getHeaders(token);
//       print('\n📤 Add Child Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: $headers');
//       print('└─ Body: ${jsonEncode(body)}');

//       final response = await http.post(
//         url,
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       print('\n📥 Add Child Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final String? childId = data['data']?['child']?['_id'];
//         if (childId != null) {
//           context.read<SelectedChildCubit>().selectChild(childId);
//           print('🔑 Set childId in Cubit: $childId');
//           print('🎉 Successfully added child with ID: $childId');
//         } else {
//           print('⚠️ Child ID not found in response');
//         }
//         return {
//           'status': 'success',
//           'message': 'Child added successfully',
//           'data': data['data'],
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Add Child Error: $e');
//       return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> updateChild(Child child, BuildContext context) async {
//     try {
//       final String? userId = await AuthService.getUserId();
//       final String? token = await AuthService.getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'You must be logged in'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/children/${child.id}');
//       final body = {
//         'userId': userId,
//         'name': child.name,
//         'gender': child.gender,
//         'birthDate': DateFormat('yyyy-MM-dd').format(child.birthDate),
//         'heightAtBirth': child.heightAtBirth,
//         'weightAtBirth': child.weightAtBirth,
//         'headCircumferenceAtBirth': child.headCircumferenceAtBirth,
//         'bloodType': child.bloodType,
//         'photo': child.photo,
//         'parentPhone': child.parentPhone,
//       };

//       final headers = await AuthService.getHeaders(token);
//       print('\n📤 Update Child Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: $headers');
//       print('└─ Body: ${jsonEncode(body)}');

//       final response = await http.patch(
//         url,
//         headers: headers,
//         body: jsonEncode(body),
//       );

//       print('\n📥 Update Child Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'status': 'success',
//           'message': 'Child updated successfully',
//           'data': data['data'],
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Update Child Error: $e');
//       return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> deleteChild(String childId, BuildContext context) async {
//     try {
//       final String? token = await AuthService.getToken();

//       if (token == null) {
//         return {'status': 'error', 'message': 'You must be logged in'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/children/$childId');

//       final headers = await AuthService.getHeaders(token);
//       print('\n📤 Delete Child Request:');
//       print('├─ URL: $url');
//       print('└─ Headers: $headers');

//       final response = await http.delete(
//         url,
//         headers: headers,
//       );

//       print('\n📥 Delete Child Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         // Clear the selected child if it was the one deleted
//         final currentSelectedChildId = context.read<SelectedChildCubit>().state;
//         if (currentSelectedChildId == childId) {
//           context.read<SelectedChildCubit>().selectChild('');
//         }
//         return {
//           'status': 'success',
//           'message': 'Child deleted successfully',
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Delete Child Error: $e');
//       return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
//     }
//   }

//   static String _handleError(int statusCode, Map<String, dynamic> data) {
//     final serverMessage = data['message'] ?? 'No error message available';
//     switch (statusCode) {
//       case 400:
//         return 'Invalid data: $serverMessage';
//       case 401:
//         return 'Session expired, please log in again';
//       case 404:
//         return 'Resource not found';
//       case 500:
//         return 'Server error: $serverMessage';
//       default:
//         return 'Operation failed (Code: $statusCode): $serverMessage';
//     }
//   }
// }


import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:segma/models/child_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart' as io;

class ChildService {
  static Future<Map<String, dynamic>> getChildren() async {
    try {
      final String? token = await AuthService.getToken();
      final String? userId = await AuthService.getUserId();

      if (token == null || userId == null) {
        return {'status': 'error', 'message': 'You must be logged in'};
      }

      final url = Uri.parse('${AuthService.baseUrl}/children?userId=$userId');

      final headers = await AuthService.getHeaders(token);
      print('\n📤 Get Children Request:');
      print('├─ URL: $url');
      print('└─ Headers: $headers');

      final response = await http.get(url, headers: headers);

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
        'message': 'Failed to fetch children',
      };
    } catch (e) {
      print('\n🔥 Get Children Error: $e');
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> addChild(Child child, dynamic image, BuildContext context) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? token = await AuthService.getToken();

      if (userId == null || token == null) {
        return {'status': 'error', 'message': 'You must be logged in'};
      }

      var request = http.MultipartRequest('POST', Uri.parse('${AuthService.baseUrl}/children'));
      request.headers.addAll(await AuthService.getHeaders(token));
      request.fields['userId'] = userId;
      request.fields['name'] = child.name;
      request.fields['gender'] = child.gender;
      request.fields['birthDate'] = DateFormat('yyyy-MM-dd').format(child.birthDate);
      request.fields['heightAtBirth'] = child.heightAtBirth.toString();
      request.fields['weightAtBirth'] = child.weightAtBirth.toString();
      request.fields['headCircumferenceAtBirth'] = child.headCircumferenceAtBirth.toString();
      request.fields['bloodType'] = child.bloodType;
      request.fields['parentPhone'] = child.parentPhone ?? '';

      if (image != null) {
        if (image is io.File) {
          request.files.add(await http.MultipartFile.fromPath('photo', image.path));
        } else if (image is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes('photo', image, filename: 'child_photo.png'));
        }
      }

      print('\n📤 Add Child Request:');
      print('├─ URL: ${request.url}');
      print('├─ Headers: ${request.headers}');
      print('└─ Fields: ${request.fields}');

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print('\n📥 Add Child Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: $respStr');

      final Map<String, dynamic> data = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String? childId = data['data']['child']['_id'];
        if (childId != null) {
          context.read<SelectedChildCubit>().selectChild(childId);
          print('🔑 Set childId in Cubit: $childId');
        }
        return {
          'status': 'success',
          'message': 'Child added successfully',
          'data': data['data'],
        };
      }
      return {
        'status': 'error',
        'message': _handleError(response.statusCode, data),
      };
    } catch (e) {
      print('\n🔥 Add Child Error: $e');
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> updateChild(Child child, dynamic image, BuildContext context) async {
    try {
      final String? userId = await AuthService.getUserId();
      final String? token = await AuthService.getToken();

      if (userId == null || token == null) {
        return {'status': 'error', 'message': 'You must be logged in'};
      }

      var request = http.MultipartRequest('PATCH', Uri.parse('${AuthService.baseUrl}/children/${child.id}'));
      request.headers.addAll(await AuthService.getHeaders(token));
      request.fields['userId'] = userId;
      request.fields['name'] = child.name;
      request.fields['gender'] = child.gender;
      request.fields['birthDate'] = DateFormat('yyyy-MM-dd').format(child.birthDate);
      request.fields['heightAtBirth'] = child.heightAtBirth.toString();
      request.fields['weightAtBirth'] = child.weightAtBirth.toString();
      request.fields['headCircumferenceAtBirth'] = child.headCircumferenceAtBirth.toString();
      request.fields['bloodType'] = child.bloodType;
      request.fields['parentPhone'] = child.parentPhone ?? '';

      if (image != null) {
        if (image is io.File) {
          request.files.add(await http.MultipartFile.fromPath('photo', image.path));
        } else if (image is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes('photo', image, filename: 'child_photo.png'));
        }
      }

      print('\n📤 Update Child Request:');
      print('├─ URL: ${request.url}');
      print('├─ Headers: ${request.headers}');
      print('└─ Fields: ${request.fields}');

      final response = await request.send();
      final respStr = await response.stream.bytesToString();

      print('\n📥 Update Child Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: $respStr');

      final Map<String, dynamic> data = jsonDecode(respStr);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'status': 'success',
          'message': 'Child updated successfully',
          'data': data['data'],
        };
      }
      return {
        'status': 'error',
        'message': _handleError(response.statusCode, data),
      };
    } catch (e) {
      print('\n🔥 Update Child Error: $e');
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> deleteChild(String childId, BuildContext context) async {
    try {
      final String? token = await AuthService.getToken();

      if (token == null) {
        return {'status': 'error', 'message': 'You must be logged in'};
      }

      final url = Uri.parse('${AuthService.baseUrl}/children/$childId');

      final headers = await AuthService.getHeaders(token);
      print('\n📤 Delete Child Request:');
      print('├─ URL: $url');
      print('└─ Headers: $headers');

      final response = await http.delete(url, headers: headers);

      print('\n📥 Delete Child Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final currentSelectedChildId = context.read<SelectedChildCubit>().state;
        if (currentSelectedChildId == childId) {
          context.read<SelectedChildCubit>().selectChild('');
        }
        return {
          'status': 'success',
          'message': 'Child deleted successfully',
        };
      }
      return {
        'status': 'error',
        'message': _handleError(response.statusCode, data),
      };
    } catch (e) {
      print('\n🔥 Delete Child Error: $e');
      return {'status': 'error', 'message': 'Technical error: ${e.toString()}'};
    }
  }

  static String _handleError(int statusCode, Map<String, dynamic> data) {
    final serverMessage = data['message'] ?? 'No error message available';
    switch (statusCode) {
      case 400:
        return 'Invalid data: $serverMessage';
      case 401:
        return 'Session expired, please log in again';
      case 404:
        return 'Resource not found';
      case 500:
        return 'Server error: $serverMessage';
      default:
        return 'Operation failed (Code: $statusCode): $serverMessage';
    }
  }
} 