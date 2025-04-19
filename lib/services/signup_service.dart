// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   final String baseUrl = "https://sigma-tau-nine.vercel.app/api/users/register";

//   Future<int> signup({
//     required String firstName,
//     required String lastName,
//     required String gender,
//     required String phone,
//     required String address,
//     required String email,
//     required String password,
//     required String role,
//   }) async {
//     final url = Uri.parse(baseUrl);

//     try {
//       final Map<String, dynamic> requestBody = {
//         "firstName": firstName,
//         "lastName": lastName,
//         "gender": gender,
//         "phone": phone,
//         "address": address,
//         "email": email,
//         "password": password,
//         "role": role
//       };

//       print("Sending data: ${jsonEncode(requestBody)}");

//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode(requestBody),
//       );

//       print("Response status: ${response.statusCode}");
//       print("Response body: ${response.body}");

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         final data = jsonDecode(response.body);

//         if (data.containsKey('data') &&
//             data['data'].containsKey('user') &&
//             data['data']['user'].containsKey('token')) {
//           final token = data['data']['user']['token'];

//           SharedPreferences prefs = await SharedPreferences.getInstance();
//           await prefs.setString('token', token);
//         }
//       }

//       return response.statusCode; // إرجاع كود الاستجابة للتحقق لاحقًا
//     } catch (e) {
//       print("Signup Error: $e");
//       return 500; // إرجاع كود خطأ افتراضي عند الفشل
//     }
//   }
// }

//////////////////////////////////////////////////////////////////////////////////////////
///
///
///
///
///
///
///
///
///
///

// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   static const String _baseUrl = "https://sigma-tau-nine.vercel.app/api/users";

//   // 🔹 تسجيل مستخدم جديد
//   static Future<bool> register({
//     required String firstName,
//     required String lastName,
//     required String gender,
//     required String phone,
//     required String address,
//     required String email,
//     required String password,
//     required String role,
//   }) async {
//     final url = Uri.parse("$_baseUrl/register");

//     try {
//       final response = await http.post(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({
//           "firstName": firstName,
//           "lastName": lastName,
//           "gender": gender,
//           "phone": phone,
//           "address": address,
//           "email": email,
//           "password": password,
//           "role": role
//         }),
//       );

//       print("Response Status Code: \${response.statusCode}");
//       print("Response Body: \${response.body}");

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         final data = jsonDecode(response.body);
//         final user = data["data"]["user"];
//         final String userId = user["_id"];
//         final String token = user["token"];

//         print("User ID: $userId");
//         print("User Token: \$token");

//         await _saveUserData(userId, token);

//         return true;
//       } else {
//         print("Registration failed: \${response.body}");
//         return false;
//       }
//     } catch (e) {
//       print("Registration Error: \$e");
//       return false;
//     }
//   }

//   // 🔹 إرسال بيانات إلى السيرفر
//   static Future<http.Response?> sendData(Map<String, dynamic> data) async {
//     final url = Uri.parse("$_baseUrl/send-data");
//     final token = await _getToken();

//     if (token == null) {
//       print("⚠️ No token found. Ensure the user is logged in.");
//       return null;
//     }

//     try {
//       final response = await http.post(
//         url,
//         headers: _getHeaders(token),
//         body: jsonEncode(data),
//       );

//       print("Send Data Response Status Code: \${response.statusCode}");
//       print("Send Data Response Body: \${response.body}");

//       if (response.statusCode != 200) {
//         print("Error sending data: \${response.body}");
//       }

//       return response;
//     } catch (e) {
//       print("Error sending data: \$e");
//       return null;
//     }
//   }

//   // 🔹 حفظ التوكن و _id في SharedPreferences
//   static Future<void> _saveUserData(String userId, String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString("userId", userId);
//     await prefs.setString("token", token);
//   }

//   // 🔹 استرجاع التوكن من SharedPreferences
//   static Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? token = prefs.getString("token");
//     print("Retrieved Token: \$token");
//     return token;
//   }

//   // 🔹 استرجاع _id من SharedPreferences
//   static Future<String?> getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     String? userId = prefs.getString("userId");
//     print("Retrieved User ID: \$userId");
//     return userId;
//   }

//   // 🔹 إعداد الهيدر مع التوكن
//   static Map<String, String> _getHeaders(String? token) {
//     return {
//       'Content-Type': 'application/json',
//       if (token != null) 'Authorization': 'Bearer \$token',
//     };
//   }
// }
