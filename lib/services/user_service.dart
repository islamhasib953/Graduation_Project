// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';
// import 'package:segma/services/auth_service.dart';

// class UserService {
//   static Future<Map<String, dynamic>> login(
//       String email, String password, BuildContext context) async {
//     try {
//       final url = Uri.parse('${AuthService.baseUrl}/users/login');

//       print('\n📤 Login Request:');
//       print('├─ URL: $url');
//       print('└─ Body: ${jsonEncode({'email': email, 'password': password})}');

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       print('\n📥 Login Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final String? token = data['data']?['token'];
//         final String? role = data['data']?['role']; // تعديل: استخدام role بدل accountType
//         final String? childId = data['data']?['child']?['_id'];

//         String? userId;
//         if (token != null) {
//           try {
//             final parts = token.split('.');
//             if (parts.length == 3) {
//               final payload = parts[1];
//               final decodedPayload =
//                   utf8.decode(base64Url.decode(base64Url.normalize(payload)));
//               final payloadMap =
//                   jsonDecode(decodedPayload) as Map<String, dynamic>;
//               userId = payloadMap['id'];
//             }
//           } catch (e) {
//             print('🔥 Error decoding JWT token: $e');
//           }
//         }

//         if (token != null && userId != null && role != null) {
//           await AuthService.saveUserData(
//             token: token,
//             userId: userId,
//             accountType: role, // تعديل: تمرير role بدل accountType
//           );
//           if (childId != null) {
//             context.read<SelectedChildCubit>().selectChild(childId);
//             print('🔑 Set childId in Cubit: $childId');
//           }
//           print('\n🔑 Login Data Saved:');
//           print('├─ User ID: $userId');
//           print('├─ Token: $token');
//           print('└─ Role: $role'); // تعديل: طباعة Role بدل AccountType

//           return {
//             'status': 'success',
//             'message': 'تم تسجيل الدخول بنجاح',
//             'data': {
//               'token': token,
//               'userId': userId,
//               'role': role.toLowerCase(), // تعديل: إرجاع role بدل accountType
//             },
//           };
//         }
//         return {
//           'status': 'error',
//           'message':
//               'بيانات الاستجابة غير صالحة: نقص في token أو userId أو role', // تعديل: استخدام role في الرسالة
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': _handleLoginError(response.statusCode, data),
//           'data': data,
//         };
//       }
//     } catch (e) {
//       print('\n🔥 Login Error: $e');
//       return {'status': 'error', 'message': 'خطأ في الاتصال: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> register({
//     required String firstName,
//     required String lastName,
//     required String phone,
//     required String email,
//     required String password,
//     required String accountType,
//     required String gender,
//     required String address,
//     String? specialise,
//     String? about,
//     required BuildContext context,
//   }) async {
//     try {
//       final url = Uri.parse('${AuthService.baseUrl}/users/register');
//       final requestBody = {
//         'firstName': firstName.toString(),
//         'lastName': lastName.toString(),
//         'phone': phone.toString(),
//         'email': email.toString(),
//         'password': password.toString(),
//         'role': accountType.toLowerCase().toString(),
//         'gender': gender.toString(),
//         'address': address.toString(),
//         if (specialise != null && accountType.toLowerCase() == 'doctor')
//           'specialise': specialise.toString(),
//         if (about != null && accountType.toLowerCase() == 'doctor')
//           'about': about.toString(),
//       };

//       print('\n📤 Register Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: ${AuthService.getHeaders()}');
//       print('└─ Body: ${jsonEncode(requestBody)}');

//       final response = await http.post(
//         url,
//         headers: AuthService.getHeaders(),
//         body: jsonEncode(requestBody),
//       );

//       print('\n📥 Register Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final String? userId = data['data']?['user']?['_id'];
//         final String? token = data['data']?['token'] ?? data['data']?['user']?['token'];
//         final String? role = data['data']?['user']?['role'];
//         final String? childId = data['data']?['child']?['_id'];

//         if (userId != null && token != null) {
//           await AuthService.saveUserData(
//             token: token,
//             userId: userId,
//             accountType: role, // تعديل: تمرير role بدل accountType
//           );
//           print('\n✅ Saved Auth Data:');
//           print('├─ User ID: $userId');
//           print('├─ Token: $token');
//           print('├─ Role: $role');
//         } else {
//           print('\n❌ Failed to Save Auth Data: Missing userId or token');
//         }

//         if (childId != null) {
//           context.read<SelectedChildCubit>().selectChild(childId);
//           print('🔑 Set childId in Cubit: $childId');
//         }

//         print('\n✅ Register Success:');
//         print('├─ User ID: $userId');
//         print('├─ Token: $token');
//         print('├─ Role: $role');
//         print('├─ Child ID: $childId');

//         return {
//           'status': 'success',
//           'message': data['message'] ?? 'تم التسجيل بنجاح',
//           'data': data['data'],
//         };
//       } else {
//         final errorMessage = _handleRegisterError(response.statusCode, data);
//         print('\n❌ Register Error: $errorMessage');
//         return {
//           'status': 'error',
//           'message': 'فشل التسجيل (الكود: ${response.statusCode}): $errorMessage',
//           'data': data,
//         };
//       }
//     } catch (e) {
//       print('\n🔥 Register Error: $e');
//       return {
//         'status': 'error',
//         'message': 'خطأ تقني: ${e.toString()}',
//       };
//     }
//   }

//   static String _handleLoginError(int statusCode, Map<String, dynamic> data) {
//     final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
//     switch (statusCode) {
//       case 400:
//         return 'بيانات الدخول غير صالحة: $serverMessage';
//       case 401:
//         return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
//       case 404:
//         return 'الحساب غير موجود';
//       default:
//         return 'فشل تسجيل الدخول (الكود: $statusCode): $serverMessage';
//     }
//   }

//   static String _handleRegisterError(int statusCode, Map<String, dynamic> data) {
//     switch (statusCode) {
//       case 400:
//         return data['message'] ?? 'بيانات غير صالحة';
//       case 409:
//         return data['message'] ?? 'البريد الإلكتروني موجود بالفعل';
//       case 500:
//         return data['message'] ?? 'خطأ في الخادم';
//       default:
//         return data['message'] ?? 'خطأ غير معروف';
//     }
//   }
// }



import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static Future<Map<String, dynamic>> login(
      String email, String password, BuildContext context) async {
    try {
      final url = Uri.parse('${AuthService.baseUrl}/users/login');

      print('\n📤 Login Request:');
      print('├─ URL: $url');
      print('└─ Body: ${jsonEncode({'email': email, 'password': password})}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('\n📥 Login Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final String? token = data['data']?['token'];
        final String? role = data['data']?['role'];
        final String? childId = data['data']?['child']?['_id'];

        String? userId;
        if (token != null) {
          try {
            final parts = token.split('.');
            if (parts.length == 3) {
              final payload = parts[1];
              final decodedPayload =
                  utf8.decode(base64Url.decode(base64Url.normalize(payload)));
              final payloadMap =
                  jsonDecode(decodedPayload) as Map<String, dynamic>;
              userId = payloadMap['id'];
            }
          } catch (e) {
            print('🔥 Error decoding JWT token: $e');
          }
        }

        if (token != null && userId != null && role != null) {
          await AuthService.saveUserData(
            token: token,
            userId: userId,
            accountType: role,
          );
          print('\n🔑 Successfully Saved Token: $token');
          print('├─ User ID: $userId');
          print('├─ Role: $role');
          if (childId != null) {
            context.read<SelectedChildCubit>().selectChild(childId);
            print('🔑 Set childId in Cubit: $childId');
          }

          // التحقق من الـ Token بعد الحفظ
          final isTokenValid = await _verifyToken(token);
          if (!isTokenValid) {
            return {
              'status': 'error',
              'message': 'فشل التحقق من الـ Token. من فضلك سجل دخول مرة أخرى.',
            };
          }

          return {
            'status': 'success',
            'message': 'تم تسجيل الدخول بنجاح',
            'data': {
              'token': token,
              'userId': userId,
              'role': role.toLowerCase(),
            },
          };
        }
        return {
          'status': 'error',
          'message':
              'بيانات الاستجابة غير صالحة: نقص في token أو userId أو role',
        };
      } else {
        return {
          'status': 'error',
          'message': _handleLoginError(response.statusCode, data),
          'data': data,
        };
      }
    } catch (e) {
      print('\n🔥 Login Error: $e');
      return {'status': 'error', 'message': 'خطأ في الاتصال: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String accountType,
    required String gender,
    required String address,
    String? specialise,
    String? about,
    required BuildContext context,
  }) async {
    try {
      final url = Uri.parse('${AuthService.baseUrl}/users/register');
      final requestBody = {
        'firstName': firstName.toString(),
        'lastName': lastName.toString(),
        'phone': phone.toString(),
        'email': email.toString(),
        'password': password.toString(),
        'role': accountType.toLowerCase().toString(),
        'gender': gender.toString(),
        'address': address.toString(),
        if (specialise != null && accountType.toLowerCase() == 'doctor')
          'specialise': specialise.toString(),
        if (about != null && accountType.toLowerCase() == 'doctor')
          'about': about.toString(),
      };

      print('\n📤 Register Request:');
      print('├─ URL: $url');
      print('├─ Headers: ${await AuthService.getHeaders()}'); // تعديل: استخدام await
      print('└─ Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: await AuthService.getHeaders(), // تعديل: استخدام await
        body: jsonEncode(requestBody),
      );

      print('\n📥 Register Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final String? userId = data['data']?['user']?['_id'];
        final String? token = data['data']?['token'] ?? data['data']?['user']?['token'];
        final String? role = data['data']?['user']?['role'];
        final String? childId = data['data']?['child']?['_id'];

        if (userId != null && token != null) {
          await AuthService.saveUserData(
            token: token,
            userId: userId,
            accountType: role,
          );
          print('\n✅ Successfully Saved Token: $token');
          print('├─ User ID: $userId');
          print('├─ Role: $role');

          // التحقق من الـ Token بعد الحفظ
          final isTokenValid = await _verifyToken(token);
          if (!isTokenValid) {
            return {
              'status': 'error',
              'message': 'فشل التحقق من الـ Token. من فضلك سجل مرة أخرى.',
            };
          }
        } else {
          print('\n❌ Failed to Save Auth Data: Missing userId or token');
        }

        if (childId != null) {
          context.read<SelectedChildCubit>().selectChild(childId);
          print('🔑 Set childId in Cubit: $childId');
        }

        print('\n✅ Register Success:');
        print('├─ User ID: $userId');
        print('├─ Token: $token');
        print('├─ Role: $role');
        print('├─ Child ID: $childId');

        return {
          'status': 'success',
          'message': data['message'] ?? 'تم التسجيل بنجاح',
          'data': data['data'],
        };
      } else {
        final errorMessage = _handleRegisterError(response.statusCode, data);
        print('\n❌ Register Error: $errorMessage');
        return {
          'status': 'error',
          'message': 'فشل التسجيل (الكود: ${response.statusCode}): $errorMessage',
          'data': data,
        };
      }
    } catch (e) {
      print('\n🔥 Register Error: $e');
      return {
        'status': 'error',
        'message': 'خطأ تقني: ${e.toString()}',
      };
    }
  }

  // دالة لاسترجاع الـ Token
  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null || token.isEmpty) {
        print('❌ No Token Found in SharedPreferences');
        return null;
      }
      print('✅ Retrieved Token: $token');
      return token;
    } catch (e) {
      print('🔥 Error retrieving token: $e');
      return null;
    }
  }

  // دالة للتحقق من الـ Token
  static Future<bool> _verifyToken(String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedToken = prefs.getString('token');
      if (savedToken == null || savedToken.isEmpty) {
        print('❌ No Token Found in SharedPreferences');
        return false;
      }

      if (savedToken != token) {
        print('❌ Token Mismatch: Saved Token does not match provided Token');
        return false;
      }

      print('✅ Token Verified: $savedToken');
      return true;
    } catch (e) {
      print('🔥 Error verifying token: $e');
      return false;
    }
  }

  static String _handleLoginError(int statusCode, Map<String, dynamic> data) {
    final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
    switch (statusCode) {
      case 400:
        return 'بيانات الدخول غير صالحة: $serverMessage';
      case 401:
        return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
      case 404:
        return 'الحساب غير موجود';
      default:
        return 'فشل تسجيل الدخول (الكود: $statusCode): $serverMessage';
    }
  }

  static String _handleRegisterError(int statusCode, Map<String, dynamic> data) {
    switch (statusCode) {
      case 400:
        return data['message'] ?? 'بيانات غير صالحة';
      case 409:
        return data['message'] ?? 'البريد الإلكتروني موجود بالفعل';
      case 500:
        return data['message'] ?? 'خطأ في الخادم';
      default:
        return data['message'] ?? 'خطأ غير معروف';
    }
  }
}