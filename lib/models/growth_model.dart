import 'package:equatable/equatable.dart';

/// Represents a growth record for a child, containing measurements and additional metadata.
class GrowthRecord extends Equatable {
  final String id;
  final String childId;
  final double weight;
  final double height;
  final double headCircumference;
  final DateTime date;
  final String time;
  final String notes;
  final String notesImage;
  final double ageInMonths;

  const GrowthRecord({
    required this.id,
    required this.childId,
    required this.weight,
    required this.height,
    required this.headCircumference,
    required this.date,
    required this.time,
    required this.notes,
    required this.notesImage,
    required this.ageInMonths,
  });

  factory GrowthRecord.fromJson(Map<String, dynamic> json) {
    // Validate numeric values to ensure they are non-negative
    double validateNumber(dynamic value) {
      final numValue = (value as num?)?.toDouble() ?? 0.0;
      return numValue < 0 ? 0.0 : numValue;
    }

    return GrowthRecord(
      id: json['_id'] ?? '',
      childId: json['childId'] ?? '', // إضافة childId
      weight: validateNumber(json['weight']),
      height: validateNumber(json['height']),
      headCircumference: validateNumber(json['headCircumference']),
      date: DateTime.parse(json['date'] ?? DateTime.now().toIso8601String()),
      time: json['time'] ?? '',
      notes: json['notes'] ?? '',
      notesImage: json['notesImage'] ?? '',
      ageInMonths: validateNumber(json['ageInMonths']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'childId': childId,
      'weight': weight,
      'height': height,
      'headCircumference': headCircumference,
      'date': date.toIso8601String(),
      'time': time,
      'notes': notes,
      'notesImage': notesImage,
      'ageInMonths': ageInMonths,
    };
  }

  @override
  List<Object> get props => [
        id,
        childId,
        weight,
        height,
        headCircumference,
        date,
        time,
        notes,
        notesImage,
        ageInMonths,
      ];
}

/// Represents the changes in growth measurements between two growth records.
class GrowthChange extends Equatable {
  /// Change in height in centimeters.
  final double heightChange;

  /// Change in weight in kilograms.
  final double weightChange;

  /// Change in head circumference in centimeters.
  final double headCircumferenceChange;

  const GrowthChange({
    required this.heightChange,
    required this.weightChange,
    required this.headCircumferenceChange,
  });

  @override
  List<Object> get props => [heightChange, weightChange, headCircumferenceChange];
}

/// Represents the changes in growth along with the previous growth record.
class GrowthChanges extends Equatable {
  /// The previous growth record (if available).
  final GrowthRecord? previousRecord;

  /// The changes in growth measurements.
  final GrowthChange changes;

  const GrowthChanges({
    required this.previousRecord,
    required this.changes,
  });

  @override
  List<Object?> get props => [previousRecord, changes];
}