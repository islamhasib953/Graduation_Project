// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';
// import 'package:segma/services/auth_service.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserService2 {
//   static Future<Map<String, dynamic>> login(
//       String email, String password, BuildContext context) async {
//     try {
//       final url = Uri.parse('${AuthService.baseUrl}/users/login');

//       print('\n📤 Login Request (UserService2):');
//       print('├─ URL: $url');
//       print('└─ Body: ${jsonEncode({'email': email, 'password': password})}');

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       print('\n📥 Login Response (UserService2):');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final String? token = data['data']?['token'];
//         final String? role = data['data']?['role'];
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
//             print('🔥 Error decoding JWT token (UserService2): $e');
//           }
//         }

//         if (token != null && userId != null && role != null) {
//           await AuthService.saveUserData(
//             token: token,
//             userId: userId,
//             accountType: role,
//           );
//           print('\n🔑 Successfully Saved Token (UserService2): $token');
//           print('├─ User ID: $userId');
//           print('├─ Role: $role');
//           if (childId != null) {
//             context.read<SelectedChildCubit>().selectChild(childId);
//             print('🔑 Set childId in Cubit (UserService2): $childId');
//           }

//           final isTokenValid = await _verifyToken(token);
//           if (!isTokenValid) {
//             return {
//               'status': 'error',
//               'message': 'فشل التحقق من الـ Token. من فضلك سجل دخول مرة أخرى.',
//             };
//           }

//           return {
//             'status': 'success',
//             'message': 'تم تسجيل الدخول بنجاح',
//             'data': {
//               'token': token,
//               'userId': userId,
//               'role': role.toLowerCase(),
//             },
//           };
//         }
//         return {
//           'status': 'error',
//           'message':
//               'بيانات الاستجابة غير صالحة: نقص في token أو userId أو role',
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': _handleLoginError(response.statusCode, data),
//           'data': data,
//         };
//       }
//     } catch (e) {
//       print('\n🔥 Login Error (UserService2): $e');
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

//       print('\n📤 Register Request (UserService2):');
//       print('├─ URL: $url');
//       print('├─ Headers: ${await AuthService.getHeaders()}');
//       print('└─ Body: ${jsonEncode(requestBody)}');

//       final response = await http.post(
//         url,
//         headers: await AuthService.getHeaders(),
//         body: jsonEncode(requestBody),
//       );

//       print('\n📥 Register Response (UserService2):');
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
//             accountType: role,
//           );
//           print('\n✅ Successfully Saved Token (UserService2): $token');
//           print('├─ User ID: $userId');
//           print('├─ Role: $role');

//           final isTokenValid = await _verifyToken(token);
//           if (!isTokenValid) {
//             return {
//               'status': 'error',
//               'message': 'فشل التحقق من الـ Token. من فضلك سجل مرة أخرى.',
//             };
//           }
//         } else {
//           print('\n❌ Failed to Save Auth Data (UserService2): Missing userId or token');
//         }

//         if (childId != null) {
//           context.read<SelectedChildCubit>().selectChild(childId);
//           print('🔑 Set childId in Cubit (UserService2): $childId');
//         }

//         print('\n✅ Register Success (UserService2):');
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
//         print('\n❌ Register Error (UserService2): $errorMessage');
//         return {
//           'status': 'error',
//           'message': 'فشل التسجيل (الكود: ${response.statusCode}): $errorMessage',
//           'data': data,
//         };
//       }
//     } catch (e) {
//       print('\n🔥 Register Error (UserService2): $e');
//       return {
//         'status': 'error',
//         'message': 'خطأ تقني: ${e.toString()}',
//       };
//     }
//   }

//   static Future<String?> getToken() async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final token = prefs.getString('token');
//       if (token == null || token.isEmpty) {
//         print('❌ No Token Found in SharedPreferences (UserService2)');
//         return null;
//       }
//       print('✅ Retrieved Token (UserService2): $token');
//       return token;
//     } catch (e) {
//       print('🔥 Error retrieving token (UserService2): $e');
//       return null;
//     }
//   }

//   static Future<bool> _verifyToken(String token) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       final savedToken = prefs.getString('token');
//       if (savedToken == null || savedToken.isEmpty) {
//         print('❌ No Token Found in SharedPreferences (UserService2)');
//         return false;
//       }

//       if (savedToken != token) {
//         print('❌ Token Mismatch (UserService2): Saved Token does not match provided Token');
//         return false;
//       }

//       print('✅ Token Verified (UserService2): $savedToken');
//       return true;
//     } catch (e) {
//       print('🔥 Error verifying token (UserService2): $e');
//       return false;
//     }
//   }

//   static Future<Map<String, dynamic>> getUserProfile() async {
//     try {
//       final String? token = await AuthService.getToken();

//       if (token == null) {
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/api/users/profile');

//       final headers = await AuthService.getHeaders(token);
//       print('\n📤 Get User Profile Request (UserService2):');
//       print('├─ URL: $url');
//       print('└─ Headers: $headers');

//       final response = await http.get(
//         url,
//         headers: headers,
//       );

//       print('\n📥 Get User Profile Response (UserService2):');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         return {
//           'status': 'success',
//           'data': data['data'],
//         };
//       } else if (response.statusCode == 404) {
//         return {
//           'status': 'error',
//           'message': 'الـ endpoint غير موجود. تحقق من الـ URL: /api/users/profile',
//         };
//       }
//       return {
//         'status': 'error',
//         'message': data['message'] ?? 'فشل في جلب بيانات المستخدم (الكود: ${response.statusCode})',
//       };
//     } catch (e) {
//       print('\n🔥 Get User Profile Error (UserService2): $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> logoutUser() async {
//     try {
//       final String? token = await AuthService.getToken();
//       if (token == null) {
//         return {'status': 'error', 'message': 'No token found'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/api/users/logout');
//       print('UserService2: Logging out user at: $url');
//       final response = await http.post(
//         url,
//         headers: await AuthService.getHeaders(token),
//       ).timeout(const Duration(seconds: 10), onTimeout: () {
//         throw Exception('Request timed out after 10 seconds');
//       });

//       print('UserService2: logoutUser response status: ${response.statusCode}');
//       print('UserService2: logoutUser response body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.clear(); // Clear all stored data including token
//         return {
//           'status': 'success',
//           'message': data['message'] ?? 'Logged out successfully',
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': data['message'] ?? 'Failed to logout: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('UserService2: Error in logoutUser: $e');
//       return {'status': 'error', 'message': 'Error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> deleteUserAccount() async {
//     try {
//       final String? token = await AuthService.getToken();
//       if (token == null) {
//         return {'status': 'error', 'message': 'No token found'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/api/users/profile');
//       print('UserService2: Deleting user account at: $url');
//       final response = await http.delete(
//         url,
//         headers: await AuthService.getHeaders(token),
//       ).timeout(const Duration(seconds: 10), onTimeout: () {
//         throw Exception('Request timed out after 10 seconds');
//       });

//       print('UserService2: deleteUserAccount response status: ${response.statusCode}');
//       print('UserService2: deleteUserAccount response body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final prefs = await SharedPreferences.getInstance();
//         await prefs.clear(); // Clear all stored data including token
//         return {
//           'status': 'success',
//           'message': data['message'] ?? 'Account deleted successfully',
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': data['message'] ?? 'Failed to delete account: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('UserService2: Error in deleteUserAccount: $e');
//       return {'status': 'error', 'message': 'Error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
//     try {
//       final String? token = await AuthService.getToken();
//       if (token == null) {
//         return {'status': 'error', 'message': 'No token found'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/api/users/profile');
//       print('UserService2: Updating user profile at: $url');
//       print('UserService2: Request body: ${jsonEncode(data)}');
//       final response = await http.patch(
//         url,
//         headers: await AuthService.getHeaders(token),
//         body: jsonEncode(data),
//       ).timeout(const Duration(seconds: 10), onTimeout: () {
//         throw Exception('Request timed out after 10 seconds');
//       });

//       print('UserService2: updateUserProfile response status: ${response.statusCode}');
//       print('UserService2: updateUserProfile response body: ${response.body}');

//       final Map<String, dynamic> responseData = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         return {
//           'status': 'success',
//           'message': responseData['message'] ?? 'Profile updated successfully',
//           'data': responseData['data'],
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': responseData['message'] ?? 'Failed to update profile: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('UserService2: Error in updateUserProfile: $e');
//       return {'status': 'error', 'message': 'Error: $e'};
//     }
//   }

//   static Future<Map<String, dynamic>> getChildRecords(String childId) async {
//     try {
//       final String? token = await AuthService.getToken();
//       if (token == null) {
//         return {'status': 'error', 'message': 'No token found'};
//       }

//       final url = Uri.parse('${AuthService.baseUrl}/api/users/child/records');
//       print('UserService2: Fetching child records from: $url');
//       print('UserService2: Request body: ${jsonEncode({'childId': childId})}');
//       final response = await http.post(
//         url,
//         headers: await AuthService.getHeaders(token),
//         body: jsonEncode({'childId': childId}),
//       ).timeout(const Duration(seconds: 10), onTimeout: () {
//         throw Exception('Request timed out after 10 seconds');
//       });

//       print('UserService2: getChildRecords response status: ${response.statusCode}');
//       print('UserService2: getChildRecords response body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200) {
//         final growthRecords = data['data']?['growthRecords'] ?? [];
//         final medicalHistory = data['data']?['medicalHistory'] ?? [];

//         return {
//           'status': 'success',
//           'data': {
//             'growthRecords': growthRecords,
//             'medicalHistory': medicalHistory,
//           },
//         };
//       } else if (response.statusCode == 404) {
//         return {
//           'status': 'error',
//           'message': 'No records found for this child',
//           'data': {'growthRecords': [], 'medicalHistory': []},
//         };
//       } else if (response.statusCode == 401) {
//         return {
//           'status': 'error',
//           'message': 'Unauthorized: Invalid or expired token',
//         };
//       } else if (response.statusCode == 400) {
//         return {
//           'status': 'error',
//           'message': 'Bad request: Invalid childId',
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': data['message'] ?? 'Failed to load child records: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       print('UserService2: Error in getChildRecords: $e');
//       return {'status': 'error', 'message': 'Error: $e'};
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
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });

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
            return {
              'status': 'error',
              'message': 'فشل في فك تشفير الـ token: $e',
            };
          }
        }

        if (token != null && userId != null && role != null) {
          await AuthService.saveUserData(
            token: token,
            userId: userId,
            role: role,
          );
          print('\n🔑 Successfully Saved Token: $token');
          print('├─ User ID: $userId');
          print('├─ Role: $role');
          if (childId != null) {
            context.read<SelectedChildCubit>().selectChild(childId);
            print('🔑 Set childId in Cubit: $childId');
          }

          final isTokenValid = await _verifyToken(token);
          if (!isTokenValid) {
            return {
              'status': 'error',
              'message': 'فشل التحقق من الـ token. من فضلك سجل دخول مرة أخرى.',
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
      return {
        'status': 'error',
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String role,
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
        'role': role.toLowerCase().toString(),
        'gender': gender.toString(),
        'address': address.toString(),
        if (specialise != null && role.toLowerCase() == 'doctor')
          'specialise': specialise.toString(),
        if (about != null && role.toLowerCase() == 'doctor')
          'about': about.toString(),
      };

      print('\n📤 Register Request:');
      print('├─ URL: $url');
      print('├─ Headers: ${await AuthService.getHeaders()}');
      print('└─ Body: ${jsonEncode(requestBody)}');

      final response = await http.post(
        url,
        headers: await AuthService.getHeaders(),
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });

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
            role: role,
          );
          print('\n✅ Successfully Saved Token: $token');
          print('├─ User ID: $userId');
          print('├─ Role: $role');

          final isTokenValid = await _verifyToken(token);
          if (!isTokenValid) {
            return {
              'status': 'error',
              'message': 'فشل التحقق من الـ token. من فضلك سجل مرة أخرى.',
            };
          }
        } else {
          print('\n❌ Failed to Save Auth Data: Missing userId or token');
          return {
            'status': 'error',
            'message': 'فشل حفظ بيانات المصادقة: userId أو token غير موجود',
          };
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
          'message': errorMessage,
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

  static Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final String? token = await AuthService.getToken();

      if (token == null) {
        return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
      }

      final url = Uri.parse('${AuthService.baseUrl}/users/profile');

      final headers = await AuthService.getHeaders(token);
      print('\n📤 Get User Profile Request:');
      print('├─ URL: $url');
      print('└─ Headers: $headers');

      final response = await http.get(
        url,
        headers: headers,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });

      print('\n📥 Get User Profile Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'data': data['data'],
        };
      } else if (response.statusCode == 401) {
        return {
          'status': 'error',
          'message': 'غير مصرح: الـ token غير صالح أو منتهي الصلاحية',
        };
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'الـ endpoint غير موجود. تحقق من الـ URL: /users/profile',
        };
      }
      return {
        'status': 'error',
        'message': data['message'] ?? 'فشل في جلب بيانات المستخدم (الكود: ${response.statusCode})',
      };
    } catch (e) {
      print('\n🔥 Get User Profile Error: $e');
      return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
    }
  }

  static Future<Map<String, dynamic>> logoutUser() async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'لم يتم العثور على الـ token'};
      }

      // جلب الـ role من SharedPreferences عشان نحدد الـ endpoint الصح
      final prefs = await SharedPreferences.getInstance();
      final String? role = prefs.getString('role');
      print('🔍 Retrieved Role for Logout: $role');

      // تحديد الـ endpoint بناءً على الـ role
      final String endpoint = role != null && role.toLowerCase() == 'doctor'
          ? '${AuthService.baseUrl}/doctors/logout'
          : '${AuthService.baseUrl}/users/logout';
      final url = Uri.parse(endpoint);

      print('📤 Logout Request:');
      print('├─ URL: $url');
      print('├─ Headers: ${await AuthService.getHeaders(token)}');

      final response = await http.post(
        url,
        headers: await AuthService.getHeaders(token),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('تجاوز مهلة الطلب بعد 10 ثوانٍ');
      });

      print('📥 Logout Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        return {
          'status': 'success',
          'message': data['message'] ?? 'تم تسجيل الخروج بنجاح',
        };
      } else if (response.statusCode == 401) {
        return {
          'status': 'error',
          'message': 'غير مصرح: الـ token غير صالح أو منتهي الصلاحية',
        };
      } else if (response.statusCode == 403) {
        // معالجة الـ 403 error بناءً على الـ role
        if (role != null && role.toLowerCase() == 'doctor') {
          return {
            'status': 'error',
            'message': 'خطأ: الـ doctors/logout غير متاح. جرب /users/logout بدلاً منه.',
          };
        }
        return {
          'status': 'error',
          'message': 'خطأ في الصلاحيات: ربما الـ role غير مدعوم في هذا الـ endpoint',
        };
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'الـ endpoint غير موجود. تحقق من الـ URL: $endpoint',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'فشل تسجيل الخروج: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔥 Error in logoutUser: $e');
      return {'status': 'error', 'message': 'خطأ: $e'};
    }
  }

  static Future<Map<String, dynamic>> deleteUserAccount() async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'لم يتم العثور على الـ token'};
      }

      // جلب الـ role من SharedPreferences عشان نحدد الـ endpoint الصح
      final prefs = await SharedPreferences.getInstance();
      final String? role = prefs.getString('role');
      print('🔍 Retrieved Role for Delete Account: $role');

      // تحديد الـ endpoint بناءً على الـ role
      final String endpoint = role != null && role.toLowerCase() == 'doctor'
          ? '${AuthService.baseUrl}/doctors/profile'
          : '${AuthService.baseUrl}/users/profile';
      final url = Uri.parse(endpoint);

      print('📤 Delete Account Request:');
      print('├─ URL: $url');
      print('├─ Headers: ${await AuthService.getHeaders(token)}');

      final response = await http.delete(
        url,
        headers: await AuthService.getHeaders(token),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('تجاوز مهلة الطلب بعد 10 ثوانٍ');
      });

      print('📥 Delete Account Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        await prefs.remove('token');
        await prefs.remove('role');
        return {
          'status': 'success',
          'message': data['message'] ?? 'تم حذف الحساب بنجاح',
        };
      } else if (response.statusCode == 401) {
        return {
          'status': 'error',
          'message': 'غير مصرح: الـ token غير صالح أو منتهي الصلاحية',
        };
      } else if (response.statusCode == 403) {
        // معالجة الـ 403 error بناءً على الـ role
        if (role != null && role.toLowerCase() == 'doctor') {
          return {
            'status': 'error',
            'message': 'خطأ: الـ doctors/profile غير متاح. جرب /users/profile بدلاً منه.',
          };
        }
        return {
          'status': 'error',
          'message': 'خطأ في الصلاحيات: ربما الـ role غير مدعوم في هذا الـ endpoint',
        };
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'الـ endpoint غير موجود. تحقق من الـ URL: $endpoint',
        };
      } else {
        return {
          'status': 'error',
          'message': data['message'] ?? 'فشل حذف الحساب: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔥 Error in deleteUserAccount: $e');
      return {'status': 'error', 'message': 'خطأ: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateUserProfile(Map<String, dynamic> data) async {
    try {
      final String? token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'لم يتم العثور على الـ token'};
      }

      // جلب الـ role من SharedPreferences عشان نحدد الـ endpoint الصح
      final prefs = await SharedPreferences.getInstance();
      final String? role = prefs.getString('role');
      print('🔍 Retrieved Role for Update Profile: $role');

      // تحديد الـ endpoint بناءً على الـ role
      final String endpoint = role != null && role.toLowerCase() == 'doctor'
          ? '${AuthService.baseUrl}/doctors/profile'
          : '${AuthService.baseUrl}/users/profile';
      final url = Uri.parse(endpoint);

      print('📤 Update Profile Request:');
      print('├─ URL: $url');
      print('├─ Headers: ${await AuthService.getHeaders(token)}');
      print('└─ Body: ${jsonEncode(data)}');

      final response = await http.patch(
        url,
        headers: await AuthService.getHeaders(token),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('تجاوز مهلة الطلب بعد 10 ثوانٍ');
      });

      print('📥 Update Profile Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'status': 'success',
          'message': responseData['message'] ?? 'تم تحديث الملف الشخصي بنجاح',
          'data': responseData['data'],
        };
      } else if (response.statusCode == 401) {
        return {
          'status': 'error',
          'message': 'غير مصرح: الـ token غير صالح أو منتهي الصلاحية',
        };
      } else if (response.statusCode == 403) {
        if (role != null && role.toLowerCase() == 'doctor') {
          return {
            'status': 'error',
            'message': 'خطأ: الـ doctors/profile غير متاح. جرب /users/profile بدلاً منه.',
          };
        }
        return {
          'status': 'error',
          'message': 'خطأ في الصلاحيات: ربما الـ role غير مدعوم في هذا الـ endpoint',
        };
      } else if (response.statusCode == 404) {
        return {
          'status': 'error',
          'message': 'الـ endpoint غير موجود. تحقق من الـ URL: $endpoint',
        };
      } else {
        return {
          'status': 'error',
          'message': responseData['message'] ?? 'فشل تحديث الملف الشخصي: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('🔥 Error in updateUserProfile: $e');
      return {'status': 'error', 'message': 'خطأ: $e'};
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
      case 429:
        return 'عدد محاولات كتير جدًا. حاول مرة تانية بعد شوية.';
      default:
        return 'فشل تسجيل الدخول (الكود: $statusCode): $serverMessage';
    }
  }

  static String _handleRegisterError(int statusCode, Map<String, dynamic> data) {
    final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
    switch (statusCode) {
      case 400:
        return 'بيانات غير صالحة: $serverMessage';
      case 409:
        return 'البريد الإلكتروني موجود بالفعل';
      case 429:
        return 'عدد محاولات التسجيل كتير جدًا. حاول مرة تانية بعد شوية.';
      case 500:
        return 'خطأ في الخادم: $serverMessage';
      default:
        return 'فشل التسجيل (الكود: $statusCode): $serverMessage';
    }
  }
}