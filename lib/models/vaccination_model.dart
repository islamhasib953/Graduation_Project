import 'package:intl/intl.dart';

class Vaccination {
  final String id;
  final String userVaccinationId;
  final String ageVaccine;
  final String doseName;
  final String disease;
  final String dosageAmount;
  final String administrationMethod;
  final String description;
  final DateTime dueDate;
  String? status; // Taken, Skipped, Pending
  DateTime? actualDate; // التاريخ الفعلي لأخذ التطعيم
  int? delayDays; // عدد أيام التأخير
  String? notes; // ملاحظات
  String? image; // رابط الصورة

  Vaccination({
    required this.id,
    required this.userVaccinationId,
    required this.ageVaccine,
    required this.doseName,
    required this.disease,
    required this.dosageAmount,
    required this.administrationMethod,
    required this.description,
    required this.dueDate,
    this.status,
    this.actualDate,
    this.delayDays,
    this.notes,
    this.image,
  });

  factory Vaccination.fromJson(Map<String, dynamic> json) {
    // معالجة البيانات بناءً على المصدر (getVaccinations أو getVaccinationById)
    final dueDate = DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String());
    final actualDate = json['actualDate'] != null ? DateTime.parse(json['actualDate']) : null;
    final status = json['status'] as String?;
    final delayDays = json['delayDays'] as int?;
    final notes = json['notes'] as String?;
    final image = json['image'] as String?;

    return Vaccination(
      id: json['_id'] ?? json['vaccineInfoId'] ?? '',
      userVaccinationId: json['userVaccinationId'] ?? json['userVaccineId'] ?? '',
      ageVaccine: json['ageVaccine'] ?? '',
      doseName: json['doseName'] ?? '',
      disease: json['disease'] ?? '',
      dosageAmount: json['dosageAmount'] ?? '',
      administrationMethod: json['administrationMethod'] ?? '',
      description: json['description'] ?? '',
      dueDate: dueDate,
      status: status,
      actualDate: actualDate,
      delayDays: delayDays,
      notes: notes,
      image: image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userVaccinationId': userVaccinationId,
      'ageVaccine': ageVaccine,
      'doseName': doseName,
      'disease': disease,
      'dosageAmount': dosageAmount,
      'administrationMethod': administrationMethod,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status,
      'actualDate': actualDate?.toIso8601String(),
      'delayDays': delayDays,
      'notes': notes,
      'image': image,
    };
  }

  // دالة للتحقق إذا كان التطعيم أتاخد في نفس يوم dueDate
  bool isTakenOnDueDate() {
    if (actualDate == null || status != 'Taken') return false;
    return actualDate!.year == dueDate.year &&
        actualDate!.month == dueDate.month &&
        actualDate!.day == dueDate.day;
  }

  // دالة للتحقق إذا كان التطعيم متأخر
  bool isOverdue() {
    if (actualDate == null || status != 'Taken') return false;
    return actualDate!.isAfter(dueDate) && delayDays != null && delayDays! > 0;
  }
}

class VaccinationLog {
  final String vaccineInfoId;
  final String userVaccineId;
  final DateTime dueDate;
  final DateTime? actualDate;
  final int? delayDays;
  final String status;
  final String? notes;
  final String? image;

  VaccinationLog({
    required this.vaccineInfoId,
    required this.userVaccineId,
    required this.dueDate,
    this.actualDate,
    this.delayDays,
    required this.status,
    this.notes,
    this.image,
  });

  factory VaccinationLog.fromJson(Map<String, dynamic> json) {
    // معالجة البيانات بناءً على المصدر
    final dueDate = DateTime.parse(json['dueDate'] ?? DateTime.now().toIso8601String());
    final actualDate = json['actualDate'] != null ? DateTime.parse(json['actualDate']) : null;
    final status = json['status'] as String? ?? 'Pending';
    final delayDays = json['delayDays'] as int?;
    final notes = json['notes'] as String?;
    final image = json['image'] as String?;

    return VaccinationLog(
      vaccineInfoId: json['vaccineInfoId'] ?? json['_id'] ?? '',
      userVaccineId: json['userVaccineId'] ?? json['userVaccinationId'] ?? '',
      dueDate: dueDate,
      actualDate: actualDate,
      delayDays: delayDays,
      status: status,
      notes: notes,
      image: image,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'vaccineInfoId': vaccineInfoId,
      'userVaccineId': userVaccineId,
      'dueDate': dueDate.toIso8601String(),
      'actualDate': actualDate?.toIso8601String(),
      'delayDays': delayDays,
      'status': status,
      'notes': notes,
      'image': image,
    };
  }
}