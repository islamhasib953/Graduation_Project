// import 'package:flutter/material.dart';

// import 'package:segma/screens/GrowthScreen.dart';

// class LogGrowthScreen extends StatefulWidget {
//   @override
//   _LogGrowthScreenState createState() => _LogGrowthScreenState();
// }

// class _LogGrowthScreenState extends State<LogGrowthScreen> {
//   DateTime selectedDate = DateTime.now();
//   TimeOfDay selectedTime = TimeOfDay.now();
//   TextEditingController weightController = TextEditingController();
//   TextEditingController heightController = TextEditingController();
//   TextEditingController headCircumferenceController = TextEditingController();
//   TextEditingController noteController = TextEditingController();
// // Stores selected image

//   // *Select Date*
//   Future<void> _selectDate(BuildContext context) async {
//     DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   // *Select Time*
//   Future<void> _selectTime(BuildContext context) async {
//     TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: selectedTime,
//     );
//     if (picked != null && picked != selectedTime) {
//       setState(() {
//         selectedTime = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text("Log Growth", style: TextStyle(color: Colors.white)),
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           children: [
//             // *Date Picker*
//             _buildEditableRow("Date", "${selectedDate.toLocal()}".split(' ')[0],
//                 () => _selectDate(context)),

//             // *Time Picker*
//             _buildEditableRow("Time", selectedTime.format(context),
//                 () => _selectTime(context)),

//             SizedBox(height: 10),

//             // *Weight, Height, Head Circumference*
//             _buildEditableTextField("Weight", weightController, "Kg"),
//             _buildEditableTextField("Height", heightController, "Cm"),
//             _buildEditableTextField(
//                 "Head Circumference", headCircumferenceController, "Cm"),

//             SizedBox(height: 10),

//             // *Note Field*
//             TextField(
//               controller: noteController,
//               style: TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: "Add Note Here",
//                 hintStyle: TextStyle(color: Colors.grey),
//                 filled: true,
//                 fillColor: Colors.grey[900],
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                   borderSide: BorderSide.none,
//                 ),
//               ),
//             ),

//             SizedBox(height: 10),

//             SizedBox(height: 20),

//             // *Save Button*
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.blue,
//                 minimumSize: Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) =>
//                           GrowthScreen()), // Navigate to GrowthPage
//                 );
//               },
//               child: Text("Save",
//                   style: TextStyle(color: Colors.white, fontSize: 16)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // *Editable Row for Date & Time*
//   Widget _buildEditableRow(String label, String value, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//         margin: EdgeInsets.only(bottom: 10),
//         decoration: BoxDecoration(
//           border: Border(bottom: BorderSide(color: Colors.grey[700]!)),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label, style: TextStyle(color: Colors.white)),
//             Text(value, style: TextStyle(color: Colors.green)),
//           ],
//         ),
//       ),
//     );
//   }

//   // *Editable Text Fields*
//   Widget _buildEditableTextField(
//       String label, TextEditingController controller, String unit) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 10),
//       padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: TextStyle(color: Colors.white)),
//           Container(
//             width: 80,
//             child: TextField(
//               controller: controller,
//               keyboardType: TextInputType.number,
//               style: TextStyle(color: Colors.green),
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: unit,
//                 hintStyle: TextStyle(color: Colors.green),
//               ),
//               textAlign: TextAlign.right,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
