class Child {
  final String id;
  final String name;
  final String gender;
  final DateTime birthDate;
  final double heightAtBirth;
  final double weightAtBirth;
  final String bloodType;
  final String? photo;

  Child({
    required this.id,
    required this.name,
    required this.gender,
    required this.birthDate,
    required this.heightAtBirth,
    required this.weightAtBirth,
    required this.bloodType,
    this.photo,
  });

  factory Child.fromJson(Map<String, dynamic> json) {
    return Child(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? 'Male',
      birthDate: DateTime.parse(json['birthDate'] ?? DateTime.now().toIso8601String()),
      heightAtBirth: (json['heightAtBirth'] ?? 0).toDouble(),
      weightAtBirth: (json['weightAtBirth'] ?? 0).toDouble(),
      bloodType: json['bloodType'] ?? '',
      photo: json['photo'],
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
      'bloodType': bloodType,
      'photo': photo,
    };
  }
}