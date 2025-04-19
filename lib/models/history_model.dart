import 'package:intl/intl.dart';

class History {
  final String id;
  final String diagnosis;
  final String disease;
  final String treatment;
  final String notes;
  final String notesImage;
  final DateTime date;
  final String time;
  final String doctorName;

  History({
    required this.id,
    required this.diagnosis,
    required this.disease,
    required this.treatment,
    required this.notes,
    required this.notesImage,
    required this.date,
    required this.time,
    required this.doctorName,
  });

  factory History.fromJson(Map<String, dynamic> json) {
    return History(
      id: json['_id'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      disease: json['disease'] ?? '',
      treatment: json['treatment'] ?? '',
      notes: json['notes'] ?? '',
      notesImage: json['notesImage'] ?? '',
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '',
      doctorName: json['doctorName'] ?? 'Dr. Islam Hasib',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'diagnosis': diagnosis,
      'disease': disease,
      'treatment': treatment,
      'notes': notes,
      'notesImage': notesImage,
      'date': date.toIso8601String(),
      'time': time,
      'doctorName': doctorName,
    };
  }

  History copyWith({
    String? id,
    String? diagnosis,
    String? disease,
    String? treatment,
    String? notes,
    String? notesImage,
    DateTime? date,
    String? time,
    String? doctorName,
  }) {
    return History(
      id: id ?? this.id,
      diagnosis: diagnosis ?? this.diagnosis,
      disease: disease ?? this.disease,
      treatment: treatment ?? this.treatment,
      notes: notes ?? this.notes,
      notesImage: notesImage ?? this.notesImage,
      date: date ?? this.date,
      time: time ?? this.time,
      doctorName: doctorName ?? this.doctorName,
    );
  }
}