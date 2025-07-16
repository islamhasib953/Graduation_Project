import 'package:equatable/equatable.dart';

class UserAppointment extends Equatable {
  final String appointmentId;
  final String childId;
  final String childName;
  final String doctorId;
  final String doctorName; // Combined firstName and lastName
  final String? doctorAvatar;
  final String? doctorAddress;
  final String date;
  final String time;
  final String visitType;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  const UserAppointment({
    required this.appointmentId,
    required this.childId,
    required this.childName,
    required this.doctorId,
    required this.doctorName,
    this.doctorAvatar,
    this.doctorAddress,
    required this.date,
    required this.time,
    required this.visitType,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory UserAppointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] as Map<String, dynamic>? ?? {};
    final firstName = doctor['firstName']?.toString() ?? '';
    final lastName = doctor['lastName']?.toString() ?? '';
    final doctorName = '$firstName $lastName'.trim();

    return UserAppointment(
      appointmentId: json['_id']?.toString() ?? '',
      childId: json['childId']?.toString() ?? '',
      childName: json['child']?['name']?.toString() ?? '',
      doctorId: json['doctorId']?.toString() ?? '', // Note: doctorId might not exist, adjust if needed
      doctorName: doctorName,
      doctorAvatar: json['doctorAvatar']?.toString(),
      doctorAddress: json['doctorAddress']?.toString(),
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      visitType: json['visitType']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: json['createdAt']?.toString(),
      updatedAt: json['updatedAt']?.toString(),
    );
  }

  @override
  List<Object?> get props => [
        appointmentId,
        childId,
        childName,
        doctorId,
        doctorName,
        doctorAvatar,
        doctorAddress,
        date,
        time,
        visitType,
        status,
        createdAt,
        updatedAt,
      ];
}

// Other models (DoctorAppointment, Appointment) remain unchanged unless needed
//*********************************** */
//doctor home

// أضف هذا الموديل الجديد في نهاية ملف appointment_model.
class DoctorAppointment extends Equatable {
  final String appointmentId;
  final String userName;
  final String userAddress;
  final String childName;
  final String date;
  final String time;
  final String status;
  final String visitType;

  const DoctorAppointment({
    required this.appointmentId,
    required this.userName,
    required this.userAddress,
    required this.childName,
    required this.date,
    required this.time,
    required this.status,
    required this.visitType,
  });

  factory DoctorAppointment.fromJson(Map<String, dynamic> json) {
    return DoctorAppointment(
      appointmentId: json['_id']?.toString() ?? '',
      userName: '${json['user']['firstName'] ?? ''} ${json['user']['lastName'] ?? ''}',
      userAddress: json['user']['address']?.toString() ?? '',
      childName: json['child']['name']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Pending',
      visitType: json['visitType']?.toString() ?? 'Online',
    );
  }

  DoctorAppointment copyWith({
    String? appointmentId,
    String? userName,
    String? userAddress,
    String? childName,
    String? date,
    String? time,
    String? status,
    String? visitType,
  }) {
    return DoctorAppointment(
      appointmentId: appointmentId ?? this.appointmentId,
      userName: userName ?? this.userName,
      userAddress: userAddress ?? this.userAddress,
      childName: childName ?? this.childName,
      date: date ?? this.date,
      time: time ?? this.time,
      status: status ?? this.status,
      visitType: visitType ?? this.visitType,
    );
  }

  @override
  List<Object?> get props => [
        appointmentId,
        userName,
        userAddress,
        childName,
        date,
        time,
        status,
        visitType,
      ];

  @override
  String toString() {
    return 'DoctorAppointment(appointmentId: $appointmentId, userName: $userName, userAddress: $userAddress, childName: $childName, date: $date, time: $time, status: $status, visitType: $visitType)';
  }
}

class Appointment extends Equatable {
  final String date;
  final String time;

  const Appointment({
    required this.date,
    required this.time,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      date: json['date'] ?? '',
      time: json['time'] ?? '',
    );
  }

  Appointment copyWith({
    String? date,
    String? time,
  }) {
    return Appointment(
      date: date ?? this.date,
      time: time ?? this.time,
    );
  }

  @override
  List<Object?> get props => [date, time];

  @override
  String toString() {
    return 'Appointment(date: $date, time: $time)';
  }
}