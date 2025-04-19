import 'package:intl/intl.dart';

class Medication {
  final String id;
  final String name;
  final String description;
  final List<String> days;
  final List<DateTime> times;
  final DateTime date;

  Medication({
    required this.id,
    required this.name,
    this.description = '',
    required this.days,
    required this.times,
    required this.date,
  });

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      days: (json['days'] as List<dynamic>?)?.cast<String>() ?? [],
      times: _parseTimes(json['times'] as List<dynamic>? ?? []),
      date: json['date'] != null
          ? DateTime.parse(json['date'])
          : json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  static List<DateTime> _parseTimes(List<dynamic> times) {
    final timeFormat = DateFormat('h:mm a'); // لتحويل "12:02 AM" لـ DateTime
    return times.map((time) {
      try {
        // لو الـ time بصيغة ISO 8601 (زي "2025-04-15T02:34:01.005")
        return DateTime.parse(time as String);
      } catch (e) {
        try {
          // لو الـ time بصيغة "12:02 AM"
          return timeFormat.parse(time as String);
        } catch (e) {
          print('🔥 Error parsing time "$time": $e');
          // لو فشل التحويل، نرجع DateTime افتراضي (ممكن تختاري قيمة تانية حسب احتياجاتك)
          return DateTime.now();
        }
      }
    }).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'days': days,
      'times': times.map((time) => time.toIso8601String()).toList(),
      'date': date.toIso8601String(),
    };
  }
}