import 'package:flutter/material.dart';

class Child {
  final String id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final double heightAtBirth;
  final double weightAtBirth;
  final double headCircumferenceAtBirth; // الحقل الجديد
  final String bloodType;
  final String? photo;
  final String? parentPhone;

  Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.heightAtBirth,
    required this.weightAtBirth,
    required this.headCircumferenceAtBirth, // الحقل الجديد
    required this.bloodType,
    this.photo,
    this.parentPhone,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? 'Male',
      birthDate: DateTime.parse(json['birthDate'] ?? DateTime.now().toIso8601String()),
      heightAtBirth: (json['heightAtBirth'] ?? 0).toDouble(),
      weightAtBirth: (json['weightAtBirth'] ?? 0).toDouble(),
      headCircumferenceAtBirth: (json['headCircumferenceAtBirth'] ?? 0).toDouble(), // الحقل الجديد
      bloodType: json['bloodType'] ?? '',
      photo: json['photo'],
      parentPhone: json['parentPhone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'heightAtBirth': heightAtBirth,
      'weightAtBirth': weightAtBirth,
      'headCircumferenceAtBirth': headCircumferenceAtBirth, // الحقل الجديد
      'bloodType': bloodType,
      'photo': photo,
      'parentPhone': parentPhone,
    };
  }
}