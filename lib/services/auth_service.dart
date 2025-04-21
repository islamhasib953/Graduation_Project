// import 'package:shared_preferences/shared_preferences.dart';

// class AuthService {
//   static const String _baseUrl = "https://graduation-projectgmabackend.vercel.app/api";

//   static String get baseUrl => _baseUrl;

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

//   static Future<Map<String, String>> getHeaders([String? token]) async {
//     // إذا لم يتم تمرير token، جيب الـ Token من SharedPreferences
//     final String? authToken = token ?? await _getToken();
//     return {
//       'Content-Type': 'application/json',
//       if (authToken != null) 'Authorization': 'Bearer $authToken',
//     };
//   }

//   static Future<String?> _getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     final token = prefs.getString('token');
//     if (token == null || token.isEmpty) {
//       print('❌ No Token Found in SharedPreferences');
//       return null;
//     }
//     print('✅ Retrieved Token from SharedPreferences: $token');
//     return token;
//   }

//   static Future<String?> getUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('userId');
//   }

//   // Expose methods for use in other services
//   static Future<void> saveUserData({
//     required String token,
//     required String userId,
//     String? accountType,
//   }) async {
//     await _saveUserData(token: token, userId: userId, accountType: accountType);
//   }

//   static Future<String?> getToken() async {
//     return await _getToken();
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = "https://graduation-projectgmabackend.vercel.app/api";

  static String get baseUrl => _baseUrl;

  static Future<void> _saveUserData({
    required String token,
    required String userId,
    String? role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', userId);
      if (role != null) {
        await prefs.setString('role', role);
      }
      print(
          '✅ User data saved successfully: Token=$token, UserId=$userId, Role=$role');
    } catch (e) {
      print('🔥 Error saving user data: $e');
      throw Exception('فشل حفظ بيانات المستخدم');
    }
  }

  static Future<Map<String, String>> getHeaders([String? token]) async {
    // إذا لم يتم تمرير token، جيب الـ Token من SharedPreferences
    final String? authToken = token ?? await _getToken();
    return {
      'Content-Type': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      print('❌ No Token Found in SharedPreferences');
      return null;
    }
    print('✅ Retrieved Token from SharedPreferences: $token');
    return token;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  // Expose methods for use in other services
  static Future<void> saveUserData({
    required String token,
    required String userId,
    String? role,
  }) async {
    await _saveUserData(token: token, userId: userId, role: role);
  }

  static Future<String?> getToken() async {
    return await _getToken();
  }
}