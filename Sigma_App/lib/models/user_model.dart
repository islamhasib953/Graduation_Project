class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  // 🔹 دالة لإنشاء كائن `UserModel` من JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["_id"] ?? "",
      firstName: json["firstName"] ?? "",
      lastName: json["lastName"] ?? "",
      email: json["email"] ?? "",
      role: json["role"] ?? "",
    );
  }

  // 🔹 دالة لتحويل `UserModel` إلى JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "firstName": firstName,
      "lastName": lastName,
      "email": email,
      "role": role,
    };
  }

  // 🔹 كائن فارغ لتفادي الأخطاء عند تحميل البيانات
  factory UserModel.empty() {
    return UserModel(id: "", firstName: "", lastName: "", email: "", role: "");
  }
}
