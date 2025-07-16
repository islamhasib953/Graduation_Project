import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:segma/models/notification.model.dart' as custom_notification;
import 'package:segma/cubits/notification_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  Future<void> fetchNotifications(String childId, {bool isDoctor = false}) async {
    try {
      emit(NotificationLoading());
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        emit(NotificationError('No token found'));
        return;
      }

      final String endpoint = isDoctor
          ? 'https://graduation-projectgmabackend.vercel.app/api/notifications/doctor'
          : 'https://graduation-projectgmabackend.vercel.app/api/notifications/user/$childId';

      final response = await http.get(
        Uri.parse(endpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'SUCCESS') {
          final List<dynamic> notificationsJson = responseData['data'];
          final List<custom_notification.Notification> notifications = notificationsJson
              .map((json) => custom_notification.Notification.fromJson(json))
              .toList();
          emit(NotificationLoaded(notifications));
        } else {
          emit(NotificationError(responseData['message'] ?? 'Failed to fetch notifications'));
        }
      } else {
        emit(NotificationError('Failed to fetch notifications: ${response.body}'));
      }
    } catch (e) {
      emit(NotificationError('Error fetching notifications: $e'));
    }
  }

  Future<void> markAsRead(String notificationId, String childId, {bool isDoctor = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('token');

      if (token == null) {
        emit(NotificationError('No token found'));
        return;
      }

      final response = await http.patch(
        Uri.parse('https://graduation-projectgmabackend.vercel.app/api/notifications/$notificationId/read'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        if (responseData['status'] == 'SUCCESS') {
          // إعادة جلب الإشعارات بعد التحديث
          await fetchNotifications(childId, isDoctor: isDoctor);
        } else {
          emit(NotificationError(responseData['message'] ?? 'Failed to mark notification as read'));
        }
      } else {
        emit(NotificationError('Failed to mark notification as read: ${response.body}'));
      }
    } catch (e) {
      emit(NotificationError('Error marking notification as read: $e'));
    }
  }
}