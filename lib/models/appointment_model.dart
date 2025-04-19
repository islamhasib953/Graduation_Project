import 'package:equatable/equatable.dart';

class UserAppointment extends Equatable {
  final String appointmentId;
  final String childId;
  final String childName;
  final String doctorId; // أضفنا الحقل ده
  final String doctorName;
  final String doctorAvatar;
  final String doctorAddress;
  final String date;
  final String time;
  final String visitType;
  final String status;

  const UserAppointment({
    required this.appointmentId,
    required this.childId,
    required this.childName,
    required this.doctorId, // أضفنا الحقل ده
    required this.doctorName,
    required this.doctorAvatar,
    required this.doctorAddress,
    required this.date,
    required this.time,
    required this.visitType,
    required this.status,
  });

  factory UserAppointment.fromJson(Map<String, dynamic> json) {
    return UserAppointment(
      appointmentId: json['appointmentId'] ?? '',
      childId: json['childId'] ?? '',
      childName: json['childName'] ?? '',
      doctorId: json['doctorId'] ?? '', // أضفنا الحقل ده
      doctorName: json['doctorName'] ?? '',
      doctorAvatar: json['doctorAvatar'] ?? '',
      doctorAddress: json['doctorAddress'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      visitType: json['visitType'] ?? '',
      status: json['status'] ?? 'Pending',
    );
  }

  @override
  List<Object?> get props => [
        appointmentId,
        childId,
        childName,
        doctorId, // أضفنا الحقل ده
        doctorName,
        doctorAvatar,
        doctorAddress,
        date,
        time,
        visitType,
        status,
      ];
}


//*********************************** */
//doctor home

// أضف هذا الموديل الجديد في نهاية ملف appointment_model.dart
class DoctorAppointment {
  final String appointmentId;
  final String userName;
  final String childName;
  final String place;
  final String date;
  final String time;
  final String status;

  DoctorAppointment({
    required this.appointmentId,
    required this.userName,
    required this.childName,
    required this.place,
    required this.date,
    required this.time,
    required this.status,
  });

  factory DoctorAppointment.fromJson(Map<String, dynamic> json) {
    return DoctorAppointment(
      appointmentId: json['appointmentId'] ?? '',
      userName: json['userName'] ?? '',
      childName: json['childName'] ?? '',
      place: json['place'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }
}