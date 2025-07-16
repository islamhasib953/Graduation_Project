// import 'dart:convert';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:timezone/timezone.dart' as tz;

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
//     'high_importance_channel',
//     'High Importance Notifications',
//     description: 'This channel is used for important notifications.',
//     importance: Importance.max,
//   );

//   static Future<void> initialize() async {
//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');
//     const InitializationSettings initializationSettings =
//         InitializationSettings(android: initializationSettingsAndroid);
//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) async {
//         print('Notification clicked: ${response.payload}');
//       },
//     );

//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.createNotificationChannel(_channel);

//     await _flutterLocalNotificationsPlugin
//         .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
//         ?.requestNotificationsPermission();

//     // Save FCM token after initialization
//     await saveFcmToken();

//     // Handle foreground messages
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('📩 Foreground message received: ${message.notification?.title}');
//       if (message.notification != null) {
//         showNotification(
//           title: message.notification!.title ?? 'New Notification',
//           body: message.notification!.body ?? 'No Body',
//         );
//       }
//     });
//   }

//   static Future<void> saveFcmToken() async {
//     try {
//       String? token = await _firebaseMessaging.getToken();
//       if (token != null) {
//         print('✅ FCM Token: $token');
//         await _sendFcmTokenToServer(token);
//       } else {
//         print('⚠️ Failed to retrieve FCM Token');
//       }

//       _firebaseMessaging.onTokenRefresh.listen((newToken) async {
//         print('🔄 FCM Token Refreshed: $newToken');
//         await _sendFcmTokenToServer(newToken);
//       });
//     } catch (e) {
//       print('🔥 Error retrieving or saving FCM Token: $e');
//     }
//   }

//   static Future<void> _sendFcmTokenToServer(String token) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? authToken = prefs.getString('token');

//       if (authToken == null) {
//         print('⚠️ No auth token found');
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('https://graduation-projectgmabackend.vercel.app/api/save-fcm-token'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode({'fcmToken': token}),
//       );

//       if (response.statusCode == 200) {
//         print('✅ FCM Token saved successfully');
//       } else {
//         print('⚠️ Failed to save FCM Token: ${response.body}');
//       }
//     } catch (e) {
//       print('🔥 Error sending FCM Token to server: $e');
//     }
//   }

//   static Future<void> showNotification({
//     required String title,
//     required String body,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);
//     await _flutterLocalNotificationsPlugin.show(
//       0,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: 'notification_payload',
//     );
//   }

//   static Future<void> handleBackgroundMessage(RemoteMessage message) async {
//     print('📩 Handling background message: ${message.messageId}');
//     if (message.notification != null) {
//       await showNotification(
//         title: message.notification!.title ?? 'No Title',
//         body: message.notification!.body ?? 'No Body',
//       );
//     }
//   }

//   static Future<void> sendAppointmentStatusNotification({
//     required String childId,
//     required String userId,
//     required String appointmentId,
//     required String doctorName,
//     required String date,
//     required String time,
//     required String status,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? authToken = prefs.getString('token');

//       if (authToken == null) {
//         print('⚠️ No auth token found');
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('https://graduation-projectgmabackend.vercel.app/api/send-appointment-status-notification'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode({
//           'childId': childId,
//           'userId': userId,
//           'appointmentId': appointmentId,
//           'doctorName': doctorName,
//           'date': date,
//           'time': time,
//           'status': status,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('✅ Appointment status notification sent successfully');
//       } else {
//         print('⚠️ Failed to send appointment status notification: ${response.body}');
//       }
//     } catch (e) {
//       print('🔥 Error sending appointment status notification: $e');
//     }
//   }

//   static Future<void> sendAppointmentCancellationNotification({
//     required String childId,
//     required String userId,
//     required String appointmentId,
//     required String doctorName,
//     required String date,
//     required String time,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? authToken = prefs.getString('token');

//       if (authToken == null) {
//         print('⚠️ No auth token found');
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('https://graduation-projectgmabackend.vercel.app/api/send-appointment-cancellation-notification'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode({
//           'childId': childId,
//           'userId': userId,
//           'appointmentId': appointmentId,
//           'doctorName': doctorName,
//           'date': date,
//           'time': time,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('✅ Appointment cancellation notification sent successfully');
//       } else {
//         print('⚠️ Failed to send appointment cancellation notification: ${response.body}');
//       }
//     } catch (e) {
//       print('🔥 Error sending appointment cancellation notification: $e');
//     }
//   }

//   static Future<void> sendAppointmentNotification({
//     required String childId,
//     required String doctorId,
//     required String appointmentId,
//     required String userId,
//     required String date,
//     required String time,
//     required String doctorName,
//     required bool isReschedule,
//   }) async {
//     try {
//       final prefs = await SharedPreferences.getInstance();
//       String? authToken = prefs.getString('token');

//       if (authToken == null) {
//         print('⚠️ No auth token found');
//         return;
//       }

//       final response = await http.post(
//         Uri.parse('https://graduation-projectgmabackend.vercel.app/api/send-appointment-notification'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $authToken',
//         },
//         body: jsonEncode({
//           'childId': childId,
//           'doctorId': doctorId,
//           'appointmentId': appointmentId,
//           'userId': userId,
//           'date': date,
//           'time': time,
//           'doctorName': doctorName,
//           'isReschedule': isReschedule,
//         }),
//       );

//       if (response.statusCode == 200) {
//         print('✅ Appointment notification sent successfully');
//       } else {
//         print('⚠️ Failed to send appointment notification: ${response.body}');
//       }
//     } catch (e) {
//       print('🔥 Error sending appointment notification: $e');
//     }
//   }

//   static Future<void> scheduleLocalNotification({
//     required int id,
//     required String title,
//     required String body,
//     required tz.TZDateTime scheduledDate,
//   }) async {
//     const AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       'high_importance_channel',
//       'High Importance Notifications',
//       channelDescription: 'This channel is used for important notifications.',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     const NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidPlatformChannelSpecifics);

//     await _flutterLocalNotificationsPlugin.zonedSchedule(
//       id,
//       title,
//       body,
//       scheduledDate,
//       platformChannelSpecifics,
//       androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
//       // إزالة uiLocalNotificationDateInterpretation لأنه غير مدعوم في الإصدار الحالي
//       // uiLocalNotificationDateInterpretation: null, // لتجنب التحذير
//     );
//   }
// }

import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:segma/services/auth_service.dart'; // استيراد AuthService

class NotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        print('Notification clicked: ${response.payload}');
      },
    );

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    await _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    await saveFcmToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message received: ${message.notification?.title}');
      if (message.notification != null) {
        showNotification(
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? 'No Body',
        );
      }
    });
  }

static Future<void> saveFcmToken() async {
  try {
    String? token = await _firebaseMessaging.getToken();
    if (token != null) {
      print('✅ FCM Token: $token');
      await _sendFcmTokenToServer(token);
    } else {
      print('⚠️ Failed to retrieve FCM Token');
    }

    _firebaseMessaging.onTokenRefresh.listen((newToken) async {
      print('🔄 FCM Token Refreshed: $newToken');
      await _sendFcmTokenToServer(newToken);
    });
  } catch (e) {
    print('🔥 Error retrieving or saving FCM Token: $e');
  }
}

static Future<void> _sendFcmTokenToServer(String token) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? authToken = prefs.getString('token');
    String? role = prefs.getString('role'); // جلب الدور من SharedPreferences

    if (authToken == null) {
      print('⚠️ No auth token found');
      return;
    }

    // تحديد الـ URL بناءً على الدور
    final url = role?.toLowerCase() == 'doctor'
        ? Uri.parse('${AuthService.baseUrl}/doctors/save-fcm-token')
        : Uri.parse('${AuthService.baseUrl}/users/save-fcm-token');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
      body: jsonEncode({'fcmToken': token}),
    );

    if (response.statusCode == 200) {
      print('✅ FCM Token saved successfully');
    } else {
      print('⚠️ Failed to save FCM Token: ${response.body}');
    }
  } catch (e) {
    print('🔥 Error sending FCM Token to server: $e');
  }
}

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  static Future<void> handleBackgroundMessage(RemoteMessage message) async {
    print('📩 Handling background message: ${message.messageId}');
    if (message.notification != null) {
      await showNotification(
        title: message.notification!.title ?? 'No Title',
        body: message.notification!.body ?? 'No Body',
      );
    }
  }

  static Future<void> sendAppointmentStatusNotification({
    required String childId,
    required String userId,
    required String appointmentId,
    required String doctorName,
    required String date,
    required String time,
    required String status,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('token');

      if (authToken == null) {
        print('⚠️ No auth token found');
        return;
      }

      final response = await http.post(
        Uri.parse('https://graduation-projectgmabackend.vercel.app/api/send-appointment-status-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'childId': childId,
          'userId': userId,
          'appointmentId': appointmentId,
          'doctorName': doctorName,
          'date': date,
          'time': time,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Appointment status notification sent successfully');
      } else {
        print('⚠️ Failed to send appointment status notification: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error sending appointment status notification: $e');
    }
  }

  static Future<void> sendAppointmentCancellationNotification({
    required String childId,
    required String userId,
    required String appointmentId,
    required String doctorName,
    required String date,
    required String time,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('token');

      if (authToken == null) {
        print('⚠️ No auth token found');
        return;
      }

      final response = await http.post(
        Uri.parse('https://graduation-projectgmabackend.vercel.app/api/send-appointment-cancellation-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'childId': childId,
          'userId': userId,
          'appointmentId': appointmentId,
          'doctorName': doctorName,
          'date': date,
          'time': time,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Appointment cancellation notification sent successfully');
      } else {
        print('⚠️ Failed to send appointment cancellation notification: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error sending appointment cancellation notification: $e');
    }
  }

  static Future<void> sendAppointmentNotification({
    required String childId,
    required String doctorId,
    required String appointmentId,
    required String userId,
    required String date,
    required String time,
    required String doctorName,
    required bool isReschedule,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? authToken = prefs.getString('token');

      if (authToken == null) {
        print('⚠️ No auth token found');
        return;
      }

      final response = await http.post(
        Uri.parse('https://graduation-projectgmabackend.vercel.app/api/send-appointment-notification'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({
          'childId': childId,
          'doctorId': doctorId,
          'appointmentId': appointmentId,
          'userId': userId,
          'date': date,
          'time': time,
          'doctorName': doctorName,
          'isReschedule': isReschedule,
        }),
      );

      if (response.statusCode == 200) {
        print('✅ Appointment notification sent successfully');
      } else {
        print('⚠️ Failed to send appointment notification: ${response.body}');
      }
    } catch (e) {
      print('🔥 Error sending appointment notification: $e');
    }
  }

  static Future<void> scheduleLocalNotification({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.max,
      priority: Priority.high,
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }
}