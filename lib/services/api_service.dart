// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:intl/intl.dart';
// import 'package:segma/models/child_model.dart';
// import 'package:segma/models/history_model.dart';
// import 'package:segma/models/medication_model.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';

// class AuthService {
//   static const String _baseUrl = "https://graduation-projectgmabackend.vercel.app/api";

//   // 🔹 تسجيل الدخول
//   static Future<Map<String, dynamic>> login(
//       String email, String password, BuildContext context) async {
//     try {
//       final url = Uri.parse('$_baseUrl/users/login');

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
//         final String? accountType = data['data']?['accountType'];
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

//         if (token != null && userId != null && accountType != null) {
//           await _saveUserData(
//             token: token,
//             userId: userId,
//             accountType: accountType,
//           );
//           if (childId != null) {
//             context.read<SelectedChildCubit>().selectChild(childId);
//             print('🔑 Set childId in Cubit: $childId');
//           }
//           print('\n🔑 Login Data Saved:');
//           print('├─ User ID: $userId');
//           print('├─ Token: $token');
//           print('└─ AccountType: $accountType');

//           return {
//             'status': 'success',
//             'message': 'تم تسجيل الدخول بنجاح',
//             'data': {
//               'token': token,
//               'userId': userId,
//               'accountType': accountType.toLowerCase(),
//             },
//           };
//         }
//         return {
//           'status': 'error',
//           'message':
//               'بيانات الاستجابة غير صالحة: نقص في token أو userId أو accountType',
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

//   // دالة getChildren لجلب الأطفال
//   static Future<Map<String, dynamic>> getChildren() async {
//     try {
//       final String? token = await _getToken();
//       final String? userId = await getUserId();

//       if (token == null || userId == null) {
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$_baseUrl/children?userId=$userId');

//       final response = await http.get(
//         url,
//         headers: _getHeaders(token),
//       );

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
//         'message': 'فشل في جلب الأطفال',
//       };
//     } catch (e) {
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   // 🔹 حفظ بيانات المستخدم
//   static Future<void> _saveUserData({
//     required String token,
//     required String userId,
//     String? accountType,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('token', token);
//       await prefs.setString('userId', userId);
//       if (accountType != null) {
//         await prefs.setString('accountType', accountType);
//       }
//       print(
//           '✅ User data saved successfully: Token=$token, UserId=$userId, AccountType=$accountType');
//     } catch (e) {
//       print('🔥 Error saving user data: $e');
//       throw Exception('فشل حفظ بيانات المستخدم');
//     }
//   }

//   // 🔹 معالجة أخطاء تسجيل الدخول
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

//   // دالة لتحديد رؤوس الطلب
//   static Map<String, String> _getHeaders([String? token]) {
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer $token',
//     };
//   }

//   // دالة لمعالجة أخطاء التسجيل
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

//   // دالة التسجيل
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
//       final url = Uri.parse('$_baseUrl/users/register');
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
//       print('├─ Headers: ${_getHeaders()}');
//       print('└─ Body: ${jsonEncode(requestBody)}');

//       final response = await http.post(
//         url,
//         headers: _getHeaders(),
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
//           await _saveUserData(
//             token: token,
//             userId: userId,
//             accountType: role,
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

//   // دالة لإضافة دواء
//   static Future<Map<String, dynamic>> addMedication(Medication medication, {required String childId}) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       // التحقق من البيانات
//       if (medication.name.isEmpty) {
//         return {'status': 'error', 'message': 'اسم الدواء مطلوب'};
//       }
//       if (medication.days.isEmpty) {
//         return {'status': 'error', 'message': 'يجب اختيار يوم واحد على الأقل'};
//       }
//       if (medication.times.isEmpty) {
//         return {'status': 'error', 'message': 'يجب اختيار وقت واحد على الأقل'};
//       }

//       final url = Uri.parse('$_baseUrl/medicines');
//       final requestBody = {
//         'name': medication.name,
//         'days': medication.days,
//         'times': medication.times,
//         'childId': childId,
//         'userId': userId,
//       };

//       print('\n📤 Add Medication Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: ${_getHeaders(token)}');
//       print('└─ Body: ${jsonEncode(requestBody)}');

//       final response = await http.post(
//         url,
//         headers: _getHeaders(token),
//         body: jsonEncode(requestBody),
//       );

//       print('\n📥 Medication Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final medicationData = data['data']?['medicine'];
//         if (medicationData != null) {
//           final addedMedication = Medication.fromJson(medicationData);
//           print('\n✅ Medication Added:');
//           print('├─ ID: ${addedMedication.id}');
//           print('├─ Name: ${addedMedication.name}');
//           print('├─ Days: ${addedMedication.days.join(', ')}');
//           print('└─ Times: ${addedMedication.times.join(', ')}');
//           return {
//             'status': 'success',
//             'message': 'تم إضافة الدواء بنجاح',
//             'data': addedMedication,
//           };
//         }
//         return {
//           'status': 'error',
//           'message': 'فشل في استرجاع بيانات الدواء المضاف',
//         };
//       } else {
//         final errorMessage = _handleMedicationError(response.statusCode, data);
//         print('\n❌ Medication Error: $errorMessage');
//         return {'status': 'error', 'message': errorMessage, 'data': data};
//       }
//     } catch (e) {
//       print('\n🔥 Add Medication Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   // دالة لجلب الأدوية
//   static Future<Map<String, dynamic>> getMedications({required String childId}) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$_baseUrl/medicines/$childId');

//       print('\n📤 Get Medications Request:');
//       print('├─ URL: $url');
//       print('└─ Headers: ${_getHeaders(token)}');

//       final response = await http.get(
//         url,
//         headers: _getHeaders(token),
//       );

//       print('\n📥 Medications Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final List<dynamic> medicines = data['data'] ?? [];
//         final medications = medicines.map((m) => Medication.fromJson(m)).toList();
//         return {
//           'status': 'success',
//           'data': medications,
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleMedicationError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Get Medications Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   // دالة لتحديث دواء
//   static Future<Map<String, dynamic>> updateMedication(Medication medication, {required String childId}) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       if (medication.id.isEmpty) {
//         return {'status': 'error', 'message': 'معرف الدواء مطلوب'};
//       }

//       final url = Uri.parse('$_baseUrl/medicines/${medication.id}/$childId');
//       final body = {
//         'name': medication.name,
//         'days': medication.days,
//         'times': medication.times,
//         'userId': userId,
//       };

//       print('\n📤 Update Medication Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: ${_getHeaders(token)}');
//       print('└─ Body: ${jsonEncode(body)}');

//       final response = await http.put(
//         url,
//         headers: _getHeaders(token),
//         body: jsonEncode(body),
//       );

//       print('\n📥 Update Medication Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final updatedMedication = Medication.fromJson(data['data']);
//         return {
//           'status': 'success',
//           'message': 'تم تحديث الدواء بنجاح',
//           'data': updatedMedication,
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleMedicationError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Update Medication Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   // دالة لحذف دواء
//   static Future<Map<String, dynamic>> deleteMedication(String medicationId, {required String childId}) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       if (medicationId.isEmpty) {
//         return {'status': 'error', 'message': 'معرف الدواء مطلوب'};
//       }

//       final url = Uri.parse('$_baseUrl/medicines/$medicationId/$childId');

//       print('\n📤 Delete Medication Request:');
//       print('├─ URL: $url');
//       print('└─ Headers: ${_getHeaders(token)}');

//       final response = await http.delete(
//         url,
//         headers: _getHeaders(token),
//       );

//       print('\n📥 Delete Medication Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'status': 'success',
//           'message': 'تم حذف الدواء بنجاح',
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleMedicationError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Delete Medication Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> addHistory(HistoryItem history, String childId) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$_baseUrl/history');
//       final body = {
//         ...history.toMap(),
//         'userId': userId,
//       };

//       print('\n📤 Add History Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: ${_getHeaders(token)}');
//       print('└─ Body: ${jsonEncode(body)}');

//       final response = await http.post(
//         url,
//         headers: _getHeaders(token),
//         body: jsonEncode(body),
//       );

//       print('\n📥 Add History Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'status': 'success',
//           'message': 'تم إضافة السجل بنجاح',
//           'data': HistoryItem.fromMap(data['data']),
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleHistoryError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Add History Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> getHistories(String childId) async {
//     try {
//       final String? token = await _getToken();

//       if (token == null) {
//         print('❌ Missing Auth Data:');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$_baseUrl/history/$childId');

//       print('\n📤 Get Histories Request:');
//       print('├─ URL: $url');
//       print('└─ Headers: ${_getHeaders(token)}');

//       final response = await http.get(
//         url,
//         headers: _getHeaders(token),
//       );

//       print('\n📥 Histories Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final List<dynamic> histories = data['data'] ?? [];
//         return {
//           'status': 'success',
//           'data':
//               histories.map<HistoryItem>((h) => HistoryItem.fromMap(h)).toList(),
//         };
//       } else if (response.statusCode == 404) {
//         return {'status': 'success', 'data': []};
//       }

//       return {
//         'status': 'error',
//         'message': _handleHistoryError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Get Histories Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> updateHistory({
//     required String historyId,
//     required HistoryItem history,
//   }) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$_baseUrl/history/$historyId');
//       final body = {
//         ...history.toMap(),
//         'userId': userId,
//       };

//       print('\n📤 Update History Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: ${_getHeaders(token)}');
//       print('└─ Body: ${jsonEncode(body)}');

//       final response = await http.put(
//         url,
//         headers: _getHeaders(token),
//         body: jsonEncode(body),
//       );

//       print('\n📥 Update History Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'status': 'success',
//           'message': 'تم تحديث السجل بنجاح',
//           'data': HistoryItem.fromMap(data['data']),
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleHistoryError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Update History Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> deleteHistory(String historyId) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$_baseUrl/history/$historyId');

//       print('\n📤 Delete History Request:');
//       print('├─ URL: $url');
//       print('└─ Headers: ${_getHeaders(token)}');

//       final response = await http.delete(
//         url,
//         headers: _getHeaders(token),
//       );

//       print('\n📥 Delete History Response:');
//       print('├─ Status: ${response.statusCode}');
//       print('└─ Body: ${response.body}');

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         return {
//           'status': 'success',
//           'message': 'تم حذف السجل بنجاح',
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleHistoryError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Delete History Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   static Future<Map<String, dynamic>> addChild(Child child, BuildContext context) async {
//     try {
//       final String? userId = await getUserId();
//       final String? token = await _getToken();

//       if (userId == null || token == null) {
//         print('❌ Missing Auth Data:');
//         print('├─ User ID: $userId');
//         print('└─ Token: $token');
//         return {'status': 'error', 'message': 'يجب تسجيل الدخول'};
//       }

//       final url = Uri.parse('$_baseUrl/children');
//       final body = {
//         'userId': userId,
//         'name': child.name,
//         'gender': child.gender,
//         'birthDate': DateFormat('yyyy-MM-dd').format(child.birthDate),
//         'heightAtBirth': child.heightAtBirth,
//         'weightAtBirth': child.weightAtBirth,
//         'bloodType': child.bloodType,
//         'photo': null,
//       };

//       print('\n📤 Add Child Request:');
//       print('├─ URL: $url');
//       print('├─ Headers: ${_getHeaders(token)}');
//       print('└─ Body: ${jsonEncode(body)}');

//       final response = await http.post(
//         url,
//         headers: _getHeaders(token),
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
//           'message': 'تم إضافة الطفل بنجاح',
//           'data': data['data'],
//         };
//       }
//       return {
//         'status': 'error',
//         'message': _handleError(response.statusCode, data),
//       };
//     } catch (e) {
//       print('\n🔥 Add Child Error: $e');
//       return {'status': 'error', 'message': 'خطأ تقني: ${e.toString()}'};
//     }
//   }

//   static String _handleError(int statusCode, Map<String, dynamic> data) {
//     final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
//     switch (statusCode) {
//       case 400:
//         return 'بيانات غير صالحة: $serverMessage';
//       case 401:
//         return 'انتهت الجلسة، من فضلك سجل الدخول مرة أخرى';
//       case 404:
//         return 'المورد غير موجود';
//       case 500:
//         return 'خطأ في الخادم: $serverMessage';
//       default:
//         return 'فشل العملية (الكود: $statusCode): $serverMessage';
//     }
//   }

//   static String _handleHistoryError(int statusCode, Map<String, dynamic> data) {
//     final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
//     switch (statusCode) {
//       case 400:
//         return 'بيانات السجل غير صالحة: $serverMessage';
//       case 401:
//         return 'انتهت الجلسة، من فضلك سجل الدخول مرة أخرى';
//       case 404:
//         return 'السجل غير موجود';
//       case 500:
//         return 'خطأ في الخادم: $serverMessage';
//       default:
//         return 'فشل العملية (الكود: $statusCode): $serverMessage';
//     }
//   }

//   static String _handleMedicationError(int statusCode, Map<String, dynamic> data) {
//     final serverMessage = data['message'] ?? 'لا توجد رسالة خطأ';
//     switch (statusCode) {
//       case 400:
//         return 'بيانات الدواء غير صالحة: $serverMessage';
//       case 401:
//         return 'انتهت الجلسة، من فضلك سجل الدخول مرة أخرى';
//       case 404:
//         return 'الدواء أو المستخدم غير موجود';
//       default:
//         return 'فشل العملية (الكود: $statusCode): $serverMessage';
//     }
//   }

//   static Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('token');
//   }

//   static Future<String?> getUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userId');
//   }
// }