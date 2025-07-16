// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:segma/services/auth_service.dart';
// import 'package:segma/services/notification_service.dart';
// import 'package:segma/models/notification.dart';

// class CommunityService {
//   static const String baseUrl = 'https://graduation-projectgmabackend.vercel.app/api/community';

//   static Future<Map<String, dynamic>> addPost({
//     required String userId,
//     required String userName,
//     required String content,
//   }) async {
//     try {
//       final headers = await AuthService.getHeaders();
//       final response = await http.post(
//         Uri.parse('$baseUrl/posts'),
//         headers: headers,
//         body: jsonEncode({
//           'userId': userId,
//           'content': content,
//         }),
//       );

//       if (response.statusCode == 201 || response.statusCode == 200) {
//         // إرسال إشعار لكل المستخدمين
//         final notification = NotificationModel(
//           id: '',
//           userId: userId,
//           title: 'New post in community',
//           body: 'A new post has been added by $userName.',
//           type: 'community',
//           timestamp: DateTime.now(),
//         );
//         await NotificationService.addNotification(notification);

//         return {
//           'status': 'success',
//           'message': 'Post added successfully',
//         };
//       } else {
//         return {
//           'status': 'error',
//           'message': 'Failed to add post: ${response.statusCode}',
//         };
//       }
//     } catch (e) {
//       return {
//         'status': 'error',
//         'message': e.toString(),
//       };
//     }
//   }
// }