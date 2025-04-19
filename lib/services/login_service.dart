// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   static const String _baseUrl = "https://sigma-tau-nine.vercel.app/api/users";

//   /// 🔹 تسجيل الدخول باستخدام البريد الإلكتروني وكلمة المرور
//   static Future<Map<String, dynamic>> login(
//       String email, String password) async {
//     try {
//       final response = await http.post(
//         Uri.parse('$_baseUrl/login'),
//         headers: {'Content-Type': 'application/json'},
//         body: jsonEncode({'email': email, 'password': password}),
//       );

//       print("Response Status Code: ${response.statusCode}");
//       print("Response Body: ${response.body}");

//       final Map<String, dynamic> data = jsonDecode(response.body);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         // ✅ استخراج التوكن من الـ API
//         final String? token =
//             data.containsKey('data') ? data['data']['accessToken'] : null;

//         print(
//             "Extracted Token: $token"); // ✅ تأكيد أن التوكن يتم استخراجه بنجاح

//         if (token != null) {
//           await _saveUserData(token);
//           return {'success': true, 'message': 'Login successful', 'data': data};
//         } else {
//           return {'success': false, 'message': 'Invalid response data'};
//         }
//       } else {
//         return {
//           'success': false,
//           'message': _handleLoginError(response.statusCode),
//           'data': data
//         };
//       }
//     } catch (e) {
//       print("Login Error: $e");
//       return {'success': false, 'message': 'Connection error: $e'};
//     }
//   }

//   /// 🔹 التعامل مع أخطاء تسجيل الدخول بناءً على كود الاستجابة
//   static String _handleLoginError(int statusCode) {
//     switch (statusCode) {
//       case 401:
//         return 'Invalid email or password';
//       case 404:
//         return 'User not found';
//       default:
//         return 'Login failed. Status code: $statusCode';
//     }
//   }

//   /// 🔹 حفظ التوكن في التخزين المحلي
//   static Future<void> _saveUserData(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('token', token);
//   }
// }
