// import 'package:flutter/material.dart';
// import 'package:segma/screens/LogGrowthScreen.dart';

// class GrowthScreen extends StatefulWidget {
//   @override
//   _GrowthTrackerScreenState createState() => _GrowthTrackerScreenState();
// }

// class _GrowthTrackerScreenState extends State<GrowthScreen> {
//   int _selectedIndex = 0; // Default selected page

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(
//           'Growth',
//           style: TextStyle(color: Colors.white),
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.black,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back_ios, color: Colors.white),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 10),

//           // *Rounded Tab Bar*
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16),
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Colors.grey[900],
//                 borderRadius: BorderRadius.circular(30),
//               ),
//               padding: EdgeInsets.all(6),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildTabButton("Summary", 0),
//                   _buildTabButton("Head", 1),
//                   _buildTabButton("Height", 2),
//                   _buildTabButton("Weight", 3),
//                 ],
//               ),
//             ),
//           ),

//           SizedBox(height: 20),

//           // *Content Area*
//           Expanded(
//             child: IndexedStack(
//               index: _selectedIndex,
//               children: [
//                 SummaryPage(),
//                 HeadGrowthPage(),
//                 HeightGrowthPage(),
//                 WeightGrowthPage(),
//               ],
//             ),
//           ),
//           SizedBox(height: 5),

//           // *Add New Record Button*
//           _buildAddNewRecordButton(context),
//         ],
//       ),
//     );
//   }

//   // *Rounded Tab Button*
//   Widget _buildTabButton(String text, int index) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () {
//           setState(() {
//             _selectedIndex = index;
//           });
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 12),
//           decoration: BoxDecoration(
//             color: _selectedIndex == index ? Colors.blue : Colors.transparent,
//             borderRadius: BorderRadius.circular(30),
//           ),
//           alignment: Alignment.center,
//           child: Text(
//             text,
//             style: TextStyle(
//               color: _selectedIndex == index ? Colors.white : Colors.grey,
//               fontWeight: FontWeight.bold,
//               fontSize: 14,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // *New Record Button*
//   Widget _buildAddNewRecordButton(BuildContext context) {
//     return Center(
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => LogGrowthScreen()),
//           );
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 18, horizontal: 80),
//           decoration: BoxDecoration(
//             color: Colors.grey[900],
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Text(
//             "+ Add New Record",
//             style: TextStyle(
//               color: Colors.blue,
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // *Dummy Pages*
// class SummaryPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text("Summary Page", style: TextStyle(color: Colors.white)),
//     );
//   }
// }

// class HeadGrowthPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Text("Head Growth Page", style: TextStyle(color: Colors.white)),
//     );
//   }
// }

// class HeightGrowthPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLastRecordCard(),
//           SizedBox(height: 10),
//           _buildGrowthChart(),
//           SizedBox(height: 10),
//           _buildGrowthSummary(),
//         ],
//       ),
//     );
//   }

//   // *Last Record Card*
//   Widget _buildLastRecordCard() {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Last Record",
//                 style: TextStyle(color: Colors.white, fontSize: 14),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 "22-Nov, 2024",
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 "50.2",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "Mm",
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // *Growth Chart Placeholder*
//   Widget _buildGrowthChart() {
//     return Container(
//       height: 180,
//       decoration: BoxDecoration(
//         color: Colors.grey[850],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Text(
//           "Chart Placeholder",
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   // *Growth Summary Card*
//   Widget _buildGrowthSummary() {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "2.25 Mm",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Icon(Icons.arrow_upward, color: Colors.green, size: 16),
//                   SizedBox(width: 4),
//                   Text(
//                     "Gained",
//                     style: TextStyle(color: Colors.green, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Summary",
//                   style: TextStyle(color: Colors.white, fontSize: 14),
//                 ),
//                 Text(
//                   "Total Height growth past month",
//                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class WeightGrowthPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.all(16.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           _buildLastRecordCard(),
//           SizedBox(height: 10),
//           _buildGrowthChart(),
//           SizedBox(height: 10),
//           _buildGrowthSummary(),
//         ],
//       ),
//     );
//   }

//   // *Last Record Card*
//   Widget _buildLastRecordCard() {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "Last Record",
//                 style: TextStyle(color: Colors.white, fontSize: 14),
//               ),
//               SizedBox(height: 4),
//               Text(
//                 "22-Nov, 2024",
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.end,
//             children: [
//               Text(
//                 "50.2",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 22,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Text(
//                 "Mm",
//                 style: TextStyle(color: Colors.grey, fontSize: 12),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   // *Growth Chart Placeholder*
//   Widget _buildGrowthChart() {
//     return Container(
//       height: 180,
//       decoration: BoxDecoration(
//         color: Colors.grey[850],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Center(
//         child: Text(
//           "Chart Placeholder",
//           style: TextStyle(color: Colors.white),
//         ),
//       ),
//     );
//   }

//   // *Growth Summary Card*
//   Widget _buildGrowthSummary() {
//     return Container(
//       padding: EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey[900],
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: Row(
//         children: [
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "2.25 Mm",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontSize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Row(
//                 children: [
//                   Icon(Icons.arrow_upward, color: Colors.green, size: 16),
//                   SizedBox(width: 4),
//                   Text(
//                     "Gained",
//                     style: TextStyle(color: Colors.green, fontSize: 14),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//           SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   "Summary",
//                   style: TextStyle(color: Colors.white, fontSize: 14),
//                 ),
//                 Text(
//                   "Total Height growth past month",
//                   style: TextStyle(color: Colors.grey, fontSize: 12),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // *New Record Page*
// class NewRecordPage extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text("New Record"),
//         backgroundColor: Colors.black,
//       ),
//       body: Center(
//         child: Text(
//           "New Record Page",
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GrowthScreen extends StatelessWidget {
  final String childId;

  const GrowthScreen({Key? key, required this.childId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Growth Details', style: TextStyle(fontSize: 18.sp)),
      ),
      body: Center(
        child: Text(
          'Growth details for Child ID: $childId',
          style: TextStyle(fontSize: 16.sp),
        ),
      ),
    );
  }
}