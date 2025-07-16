class Notification {
  final String id;
  final String? userId;
  final String? childId;
  final String? doctorId;
  final String title;
  final String body;
  final String type;
  final String target;
  final String? recipientId;
  final String? recipientType;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    this.userId,
    this.childId,
    this.doctorId,
    required this.title,
    required this.body,
    required this.type,
    required this.target,
    this.recipientId,
    this.recipientType,
    required this.isRead,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['_id'],
      userId: json['userId'],
      childId: json['childId'],
      doctorId: json['doctorId'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      target: json['target'],
      recipientId: json['recipientId'],
      recipientType: json['recipientType'],
      isRead: json['isRead'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'childId': childId,
      'doctorId': doctorId,
      'title': title,
      'body': body,
      'type': type,
      'target': target,
      'recipientId': recipientId,
      'recipientType': recipientType,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}