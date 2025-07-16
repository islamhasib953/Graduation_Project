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
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthService {
  static const String _baseUrl = "http://35.173.178.21:8000/api";

  static String get baseUrl => _baseUrl;

  static Future<void> _saveUserData({
    required String token,
    required String userId,
    String? role,
    String? fcmToken,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', token);
      await prefs.setString('userId', userId);
      if (role != null) {
        await prefs.setString('role', role);
      }
      if (fcmToken != null) {
        await prefs.setString('fcmToken', fcmToken);
      }
      print('✅ User data saved successfully: Token=$token, UserId=$userId, Role=$role, FCMToken=$fcmToken');
    } catch (e) {
      print('🔥 Error saving user data: $e');
      throw Exception('Failed to save user data');
    }
  }

  static Future<void> saveFcmToken(String fcmToken, String? role) async {
    try {
      final token = await _getToken();
      if (token == null) {
        print('❌ No token found for sending FCM Token');
        return;
      }

      final url = role?.toLowerCase() == 'doctor'
          ? Uri.parse('${AuthService.baseUrl}/doctors/save-fcm-token')
          : Uri.parse('${AuthService.baseUrl}/users/save-fcm-token');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({'fcmToken': fcmToken}),
      );

      print('📥 FCM Token Save Response: ${response.body}');
      if (response.statusCode == 200) {
        await _saveUserData(
          token: token,
          userId: await getUserId() ?? '',
          role: role,
          fcmToken: fcmToken,
        );
      } else {
        print('❌ Failed to save FCM Token: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to save FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('🔥 Error sending FCM Token: $e');
      throw Exception('Failed to save FCM token: $e');
    }
  }

  static Future<Map<String, String>> getHeaders([String? token]) async {
    final String? authToken = token ?? await _getToken();
    return {
      'Content-Type': 'application/json',
      if (authToken != null && authToken.isNotEmpty) 'Authorization': 'Bearer $authToken',
    };
  }

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null || token.isEmpty) {
      print('❌ No Token Found in SharedPreferences');
      return null;
    }
    print('✅ Retrieved Token from SharedPreferences');
    return token;
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');
    if (userId == null || userId.isEmpty) {
      print('❌ No UserId Found in SharedPreferences');
      return null;
    }
    return userId;
  }

  static Future<Map<String, dynamic>> getUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      final role = prefs.getString('role');
      print('✅ Retrieved user data: UserId=$userId, Role=$role');
      return {
        'userId': userId ?? '',
        'role': role ?? '',
      };
    } catch (e) {
      print('🔥 Error retrieving user data: $e');
      throw Exception('Failed to retrieve user data');
    }
  }

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

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('userId');
      await prefs.remove('role');
      await prefs.remove('fcmToken');
      print('✅ Logged out successfully');
    } catch (e) {
      print('🔥 Error during logout: $e');
      throw Exception('Failed to logout');
    }
  }
}