import 'package:equatable/equatable.dart';

class Doctor extends Equatable {
  final String id;
  final String firstName;
  final String lastName;
  final String? gender;
  final String phone;
  final String? email;
  final String address;
  final String? role;
  final String avatar;
  final String specialise;
  final String about;
  final double rate;
  final String status;
  final List<String> availableDays;
  final List<String> availableTimes;
  final DateTime createdAt;
  final bool isFavorite;
  final List<Appointment>? bookedAppointments;

  const Doctor({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.gender,
    required this.phone,
    this.email,
    required this.address,
    this.role,
    required this.avatar,
    required this.specialise,
    required this.about,
    required this.rate,
    required this.status,
    required this.availableDays,
    required this.availableTimes,
    required this.createdAt,
    required this.isFavorite,
    this.bookedAppointments,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      gender: json['gender'],
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'] ?? '',
      role: json['role'],
      avatar: json['avatar'] ?? '',
      specialise: json['specialise'] ?? '',
      about: json['about'] ?? '',
      rate: (json['rate'] ?? 0).toDouble(),
      status: json['status'] ?? 'Closed',
      availableDays: List<String>.from(json['availableDays'] ?? []),
      availableTimes: List<String>.from(json['availableTimes'] ?? []),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toString()),
      isFavorite: json['isFavorite'] ?? false,
      bookedAppointments: json['bookedAppointments'] != null
          ? (json['bookedAppointments'] as List)
              .map((appointment) => Appointment.fromJson(appointment))
              .toList()
          : null,
    );
  }

  Doctor copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? gender,
    String? phone,
    String? email,
    String? address,
    String? role,
    String? avatar,
    String? specialise,
    String? about,
    double? rate,
    String? status,
    List<String>? availableDays,
    List<String>? availableTimes,
    DateTime? createdAt,
    bool? isFavorite,
    List<Appointment>? bookedAppointments,
  }) {
    return Doctor(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      specialise: specialise ?? this.specialise,
      about: about ?? this.about,
      rate: rate ?? this.rate,
      status: status ?? this.status,
      availableDays: availableDays ?? this.availableDays,
      availableTimes: availableTimes ?? this.availableTimes,
      createdAt: createdAt ?? this.createdAt,
      isFavorite: isFavorite ?? this.isFavorite,
      bookedAppointments: bookedAppointments ?? this.bookedAppointments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        gender,
        phone,
        email,
        address,
        role,
        avatar,
        specialise,
        about,
        rate,
        status,
        availableDays,
        availableTimes,
        createdAt,
        isFavorite,
        bookedAppointments,
      ];

  @override
  String toString() {
    return 'Doctor(id: $id, firstName: $firstName, lastName: $lastName, gender: $gender, phone: $phone, email: $email, address: $address, role: $role, avatar: $avatar, specialise: $specialise, about: $about, rate: $rate, status: $status, availableDays: $availableDays, availableTimes: $availableTimes, createdAt: $createdAt, isFavorite: $isFavorite, bookedAppointments: $bookedAppointments)';
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