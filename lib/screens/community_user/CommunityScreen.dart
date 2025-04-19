// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:shared_preferences/shared_preferences.dart';

// // 🔹 نموذج بيانات المستخدم
// class User {
//   final String id;
//   final String firstName;
//   final String lastName;
//   final String gender;
//   final String phone;
//   final String address;
//   final String email;
//   final String password;
//   final String role;

//   User({
//     required this.id,
//     required this.firstName,
//     required this.lastName,
//     required this.gender,
//     required this.phone,
//     required this.address,
//     required this.email,
//     required this.password,
//     required this.role,
//   });

//   factory User.fromJson(Map<String, dynamic> json) {
//     return User(
//       id: json['_id'] ?? "",
//       firstName: json['firstName'] ?? "",
//       lastName: json['lastName'] ?? "",
//       gender: json['gender'] ?? "",
//       phone: json['phone'] ?? "",
//       address: json['address'] ?? "",
//       email: json['email'] ?? "",
//       password: json['password'] ?? "",
//       role: json['role'] ?? "",
//     );
//   }
// }

// // 🔹 خدمة المستخدم لاسترجاع البيانات باستخدام التوكن
// class UserService {
//   static const String baseUrl = "https://sigma-tau-nine.vercel.app/api/users/";

//   Future<String?> _getToken() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString("token");
//   }

//   Future<String?> _getUserId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     return prefs.getString("userId");
//   }

//   Future<User> fetchUserData() async {
//     final token = await _getToken();
//     final userId = await _getUserId();

//     if (userId == null || token == null) {
//       throw Exception("User ID or Token not found.");
//     }

//     print("Using Token: $token");
//     print("Fetching Data for User ID: $userId");

//     final response = await http.get(
//       Uri.parse("$baseUrl$userId"),
//       headers: {
//         'Content-Type': 'application/json',
//         'Authorization': 'Bearer $token',
//       },
//     );

//     print("Response Status Code: ${response.statusCode}");
//     print("Response Body: ${response.body}");

//     if (response.statusCode == 200 || response.statusCode == 201) {
//       Map<String, dynamic> body = json.decode(response.body);
//       if (body.containsKey("data") && body["data"].containsKey("user")) {
//         return User.fromJson(body["data"]["user"]);
//       } else {
//         throw Exception("Invalid user data format.");
//       }
//     } else {
//       throw Exception("Failed to load user: ${response.body}");
//     }
//   }
// }

// // 🔹 شاشة المجتمع لعرض بيانات المستخدم
// class CommunityScreen extends StatefulWidget {
//   @override
//   _CommunityScreenState createState() => _CommunityScreenState();
// }

// class _CommunityScreenState extends State<CommunityScreen> {
//   late Future<User> futureUser;

//   @override
//   void initState() {
//     super.initState();
//     futureUser = UserService().fetchUserData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("User Profile")),
//       body: FutureBuilder<User>(
//         future: futureUser,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text("Error: ${snapshot.error}"));
//           } else if (!snapshot.hasData) {
//             return Center(child: Text("User not found"));
//           } else {
//             User user = snapshot.data!;
//             return Card(
//               margin: EdgeInsets.all(16.0),
//               child: Padding(
//                 padding: EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Name: ${user.firstName} ${user.lastName}",
//                         style: TextStyle(
//                             fontSize: 18, fontWeight: FontWeight.bold)),
//                     SizedBox(height: 8),
//                     Text("Email: ${user.email}"),
//                     Text("Phone: ${user.phone}"),
//                     Text("Gender: ${user.gender}"),
//                     Text("Address: ${user.address}"),
//                     Text("Role: ${user.role}"),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }
// }
