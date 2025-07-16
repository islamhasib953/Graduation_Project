import 'package:segma/models/notification.model.dart' as custom_notification;

abstract class NotificationState {}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<custom_notification.Notification> notifications;

  NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String? error;

  NotificationError(this.error);
}

class NotificationReadUpdated extends NotificationState {
  final List<custom_notification.Notification> notifications;

  NotificationReadUpdated(this.notifications);
}