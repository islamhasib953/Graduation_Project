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
    print('Parsing JSON: $json'); // لتتبع القيم اللي بتيجي
    return History(
      id: json['_id'] as String? ?? '',
      diagnosis: json['diagnosis'] as String? ?? '',
      disease: json['disease'] as String? ?? '',
      treatment: json['treatment'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      notesImage: json['notesImage'] as String? ?? '',
      date: (json['date'] != null)
          ? (DateTime.tryParse(json['date'] as String)?.toLocal() ?? DateTime.now())
          : DateTime.now(),
      time: json['time'] as String? ?? '00:00',
      doctorName: json['doctorName'] as String? ?? 'Dr. Islam Hasib',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'diagnosis': diagnosis,
      'disease': disease,
      'treatment': treatment,
      'notes': notes,
      'notesImage': notesImage.isEmpty ? null : notesImage,
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