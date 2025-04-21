// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/cubits/growth_cubit.dart';
// import 'package:segma/models/child_model.dart';
// import 'package:segma/models/growth_model.dart';
// import 'package:segma/screens/growth_user/LogGrowthScreen.dart';
// import 'package:segma/services/child_service.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:intl/intl.dart';

// class PercentileData {
//   final double age; // in months
//   final double value; // height (cm), weight (kg), or head circumference (cm)

//   PercentileData(this.age, this.value);

//   factory PercentileData.fromJson(Map<String, dynamic> json) {
//     return PercentileData(
//       (json['ageInMonths'] as num).toDouble(),
//       (json['value'] as num).toDouble(),
//     );
//   }
// }

// class GrowthScreen2 extends StatefulWidget {
//   final String childId;

//   const GrowthScreen2({
//     Key? key,
//     required this.childId,
//   }) : super(key: key);

//   @override
//   _GrowthScreen2State createState() => _GrowthScreen2State();
// }

// class _GrowthScreen2State extends State<GrowthScreen2> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   Map<String, List<List<PercentileData>>> percentileData = {
//     'Head': [],
//     'Height': [],
//     'Weight': [],
//   };
//   bool isLoadingPercentiles = true;
//   bool isMale = true; // Default value, will be updated after fetching child data
//   bool isLoadingChildData = true;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 4, vsync: this);
//     _fetchChildDataAndInitialize();
//   }

//   Future<void> _fetchChildDataAndInitialize() async {
//     try {
//       final childData = await ChildService.getChildren();
//       print('ChildService.getChildren response: $childData');
//       if (childData['status'] == 'success') {
//         final List<Child> children = childData['data'] as List<Child>;
//         Child? child;
//         try {
//           child = children.firstWhere((c) => c.id == widget.childId);
//         } catch (e) {
//           child = null;
//         }
//         print('Child found: $child');
//         if (child != null) {
//           setState(() {
//             isMale = child?.gender.toLowerCase() == 'boy';
//             isLoadingChildData = false;
//           });
//           print('isMale set to: $isMale');
//           await _loadPercentileData();
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             context.read<GrowthCubit>().initialize(
//                   childId: widget.childId,
//                 );
//           });
//         } else {
//           setState(() {
//             isLoadingChildData = false;
//             isLoadingPercentiles = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Child not found')),
//           );
//         }
//       } else {
//         setState(() {
//           isLoadingChildData = false;
//           isLoadingPercentiles = false;
//         });
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(childData['message'])),
//         );
//       }
//     } catch (e) {
//       print('Error in _fetchChildDataAndInitialize: $e');
//       setState(() {
//         isLoadingChildData = false;
//         isLoadingPercentiles = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error fetching child data: $e')),
//       );
//     }
//   }

//   Future<void> _loadPercentileData() async {
//     try {
//       final String jsonPath = isMale
//           ? 'assets/data/growth_boys.json'
//           : 'assets/data/growth_girls.json';
//       print('Loading JSON from: $jsonPath');
//       final String jsonString = await rootBundle.loadString(jsonPath);
//       print('JSON loaded successfully, length: ${jsonString.length}');
//       final Map<String, dynamic> jsonData = jsonDecode(jsonString);
//       print('JSON decoded successfully: $jsonData');

//       setState(() {
//         percentileData['Height'] = [
//           (jsonData['height']['3'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['height']['15'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['height']['50'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['height']['85'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['height']['97'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//         ];
//         percentileData['Weight'] = [
//           (jsonData['weight']['3'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['weight']['15'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['weight']['50'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['weight']['85'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['weight']['97'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//         ];
//         percentileData['Head'] = [
//           (jsonData['headCircumference']['3'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['headCircumference']['15'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['headCircumference']['50'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['headCircumference']['85'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//           (jsonData['headCircumference']['97'] as List).map((item) => PercentileData.fromJson(item)).toList(),
//         ];
//         print('Percentile Data loaded: $percentileData');
//         isLoadingPercentiles = false;
//         print('isLoadingPercentiles set to false');
//       });
//     } catch (e, stackTrace) {
//       print('Error loading percentile data: $e');
//       print('Stack trace: $stackTrace');
//       setState(() {
//         isLoadingPercentiles = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   void _showGrowthDetailsDialog(BuildContext context, GrowthRecord record) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: Text('Growth Details', style: TextStyle(fontSize: 18.sp)),
//           content: SingleChildScrollView(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text('Date: ${DateFormat('dd-MM-yyyy').format(record.date)}'),
//                 Text('Time: ${record.time}'),
//                 Text('Weight: ${record.weight} kg'),
//                 Text('Height: ${record.height} cm'),
//                 Text('Head Circumference: ${record.headCircumference} cm'),
//                 Text('Age: ${record.ageInMonths} months'),
//                 Text('Notes: ${record.notes.isEmpty ? 'N/A' : record.notes}'),
//                 if (record.notesImage.isNotEmpty)
//                   Padding(
//                     padding: EdgeInsets.only(top: 8.h),
//                     child: Image.network(
//                       record.notesImage,
//                       height: 100.h,
//                       width: 100.w,
//                       errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () => Navigator.pop(context),
//               child: Text('Close', style: TextStyle(fontSize: 14.sp)),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildGrowthChart(List<GrowthRecord> records, String type, GrowthRecord? lastRecord) {
//     if (isLoadingPercentiles || percentileData[type]!.isEmpty) {
//       print('Chart not rendered: isLoadingPercentiles=$isLoadingPercentiles, percentileData[$type] is empty=${percentileData[type]!.isEmpty}');
//       return const Center(child: CircularProgressIndicator());
//     }

//     final List<Map<String, dynamic>> chartData = records.map((record) {
//       return {
//         'age': record.ageInMonths,
//         'value': type == 'Head'
//             ? record.headCircumference
//             : type == 'Height'
//                 ? record.height
//                 : record.weight,
//       };
//     }).toList();

//     // Calculate dynamic min and max for y-axis based on data
//     double minY = type == 'Head' ? 30 : type == 'Height' ? 40 : 0;
//     double maxY = type == 'Head' ? 55 : type == 'Height' ? 100 : 15;

//     // Adjust min and max based on percentile data
//     for (var percentile in percentileData[type]!) {
//       for (var data in percentile) {
//         if (data.value < minY) minY = data.value - 5;
//         if (data.value > maxY) maxY = data.value + 5;
//       }
//     }

//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.end,
//       children: [
//         if (lastRecord != null) // Show Last Record above the chart (top-right)
//           Padding(
//             padding: EdgeInsets.only(right: 16.w, bottom: 4.h),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   DateFormat('dd-MMM yyyy').format(lastRecord.date),
//                   style: TextStyle(fontSize: 5.sp, color: Colors.blue),
//                 ),
//                 Text(
//                   type == 'Head'
//                       ? '${lastRecord.headCircumference} cm'
//                       : type == 'Height'
//                           ? '${lastRecord.height} cm'
//                           : '${lastRecord.weight} kg',
//                   style: TextStyle(fontSize: 5.sp, color: Colors.blue, fontWeight: FontWeight.bold),
//                 ),
//               ],
//             ),
//           ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 16.w), // Small margin on the sides
//           height: MediaQuery.of(context).size.height * 0.5, // Chart takes half the screen height
//           child: SfCartesianChart(
//             title: ChartTitle(
//               text: type, // Title is just the type (Head, Height, Weight)
//               textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//             ),
//             legend: Legend(
//               isVisible: true,
//               position: LegendPosition.top, // Place legend at the top
//               alignment: ChartAlignment.near, // Align legend to the left
//               textStyle: TextStyle(fontSize: 6.sp, color: Colors.blue), // Very small font size
//               padding: 0,
//               itemPadding: 2,
//               iconHeight: 8.sp,
//               iconWidth: 8.sp,
//             ),
//             tooltipBehavior: TooltipBehavior(
//               enable: true,
//               format: 'Age: point.x months\npoint.y',
//             ),
//             zoomPanBehavior: ZoomPanBehavior(
//               enablePinching: true,
//               enablePanning: true,
//               enableDoubleTapZooming: true,
//               zoomMode: ZoomMode.xy,
//             ),
//             primaryXAxis: NumericAxis(
//               title: AxisTitle(
//                 text: 'Age (months)',
//                 textStyle: TextStyle(fontSize: 14.sp),
//               ),
//               edgeLabelPlacement: EdgeLabelPlacement.shift,
//               minimum: 0,
//               maximum: 24,
//               interval: 4,
//               majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
//             ),
//             primaryYAxis: NumericAxis(
//               title: AxisTitle(
//                 text: type == 'Head'
//                     ? 'Head Circumference (cm)'
//                     : type == 'Height'
//                         ? 'Height (cm)'
//                         : 'Weight (kg)',
//                 textStyle: TextStyle(fontSize: 14.sp),
//               ),
//               minimum: minY,
//               maximum: maxY,
//               interval: type == 'Head' ? 5 : type == 'Height' ? 10 : 3,
//               majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
//             ),
//             series: <CartesianSeries>[
//               ...percentileData[type]!.asMap().entries.map((entry) {
//                 int index = entry.key;
//                 List<PercentileData> data = entry.value;
//                 String percentileLabel = ['3rd', '15th', '50th', '85th', '97th'][index];
//                 return SplineSeries<PercentileData, double>(
//                   name: '$percentileLabel Percentile',
//                   dataSource: data,
//                   xValueMapper: (PercentileData pd, _) => pd.age,
//                   yValueMapper: (PercentileData pd, _) => pd.value,
//                   color: [Colors.red, Colors.orange, Colors.green, Colors.blue, Colors.purple][index],
//                   width: 1.5,
//                   enableTooltip: true,
//                   splineType: SplineType.cardinal, // Use cardinal spline for smoothness
//                   cardinalSplineTension: 0.9, // Increase tension for a smoother curve
//                 );
//               }).toList(),
//               if (chartData.isNotEmpty) // Show child's data only if records exist
//                 SplineSeries<Map<String, dynamic>, double>(
//                   name: 'Child\'s $type',
//                   dataSource: chartData,
//                   xValueMapper: (Map<String, dynamic> gd, _) => gd['age'] as double,
//                   yValueMapper: (Map<String, dynamic> gd, _) => gd['value'] as double,
//                   color: type == 'Head'
//                       ? Colors.black
//                       : type == 'Height'
//                           ? Colors.black
//                           : Colors.teal,
//                   width: 2.5,
//                   markerSettings: MarkerSettings(
//                     isVisible: true,
//                     shape: DataMarkerType.circle,
//                     width: 8,
//                     height: 8,
//                     color: type == 'Head'
//                         ? Colors.black
//                         : type == 'Height'
//                             ? Colors.black
//                             : Colors.teal,
//                   ),
//                   splineType: SplineType.cardinal, // Smooth the child's line as well
//                   cardinalSplineTension: 0.9, // Increase tension for a smoother curve
//                 ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildChangeIndicator(GrowthChanges changes, String type) {
//     double changeValue = type == 'Head'
//         ? changes.changes.headCircumferenceChange
//         : type == 'Height'
//             ? changes.changes.heightChange
//             : changes.changes.weightChange;
//     bool isPositive = changeValue >= 0;
//     String unit = type == 'Head' ? 'cm' : type == 'Height' ? 'cm' : 'kg';
//     String changeText = isPositive ? 'Gained' : 'Lost';

//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade800,
//         borderRadius: BorderRadius.circular(8.r),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(
//             isPositive ? Icons.arrow_upward : Icons.arrow_downward,
//             color: isPositive ? Colors.green : Colors.red,
//             size: 16.sp,
//           ),
//           SizedBox(width: 8.w),
//           Text(
//             '${changeValue.abs().toStringAsFixed(2)} $unit $changeText',
//             style: TextStyle(
//               fontSize: 14.sp,
//               color: isPositive ? Colors.green : Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoadingChildData) {
//       return const Scaffold(
//         body: Center(child: CircularProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Growth', style: TextStyle(fontSize: 18.sp)),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: const [
//             Tab(text: 'Summary'),
//             Tab(text: 'Head'),
//             Tab(text: 'Height'),
//             Tab(text: 'Weight'),
//           ],
//         ),
//       ),
//       body: BlocBuilder<GrowthCubit, GrowthState>(
//         builder: (context, state) {
//           if (state is GrowthLoading) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           List<GrowthRecord> records = [];
//           GrowthRecord? lastRecord;
//           GrowthChanges changes = GrowthChanges(
//             previousRecord: null,
//             changes: const GrowthChange(heightChange: 0, weightChange: 0, headCircumferenceChange: 0),
//           );

//           if (state is GrowthLoaded) {
//             records = state.records;
//             lastRecord = state.lastRecord;
//             changes = state.changes;
//           } else if (state is GrowthError && state.message.contains('No growth records found')) {
//             records = [];
//             lastRecord = null;
//             changes = GrowthChanges(
//               previousRecord: null,
//               changes: const GrowthChange(heightChange: 0, weightChange: 0, headCircumferenceChange: 0),
//             );
//           } else if (state is GrowthError) {
//             return Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text('Error', style: TextStyle(fontSize: 16.sp)),
//                   SizedBox(height: 8.h),
//                   Text(state.message, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
//                 ],
//               ),
//             );
//           }

//           return TabBarView(
//             controller: _tabController,
//             children: [
//               // Summary Tab
//               SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       if (lastRecord != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Last Record',
//                               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                             ),
//                             SizedBox(height: 8.h),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   DateFormat('dd-MMM yyyy').format(lastRecord.date),
//                                   style: TextStyle(fontSize: 14.sp, color: Colors.blue),
//                                 ),
//                                 Text(
//                                   'Head: ${lastRecord.headCircumference} cm',
//                                   style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       SizedBox(height: 16.h),
//                       Text(
//                         'History',
//                         style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                       ),
//                       SizedBox(height: 8.h),
//                       if (records.isEmpty)
//                         const Center(child: Text('No growth records found', style: TextStyle(color: Colors.blue)))
//                       else
//                         Table(
//                           border: TableBorder.all(color: Colors.grey.shade300),
//                           columnWidths: const {
//                             0: FlexColumnWidth(1),
//                             1: FlexColumnWidth(1),
//                             2: FlexColumnWidth(1),
//                             3: FlexColumnWidth(1),
//                             4: FlexColumnWidth(1),
//                           },
//                           children: [
//                             TableRow(
//                               decoration: BoxDecoration(color: Colors.grey.shade200),
//                               children: [
//                                 Padding(
//                                   padding: EdgeInsets.all(8.r),
//                                   child: Text('Head', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.all(8.r),
//                                   child: Text('Height', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.all(8.r),
//                                   child: Text('Weight', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.all(8.r),
//                                   child: Text('Date', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
//                                 ),
//                                 Padding(
//                                   padding: EdgeInsets.all(8.r),
//                                   child: Text('Details', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
//                                 ),
//                               ],
//                             ),
//                             ...records.asMap().entries.map((entry) {
//                               final record = entry.value;
//                               return TableRow(
//                                 children: [
//                                   Padding(
//                                     padding: EdgeInsets.all(8.r),
//                                     child: Text('${record.headCircumference} cm', style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.r),
//                                     child: Text('${record.height} cm', style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.r),
//                                     child: Text('${record.weight} kg', style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.r),
//                                     child: Text(
//                                       DateFormat('dd/MM/yyyy').format(record.date),
//                                       style: TextStyle(fontSize: 12.sp, color: Colors.blue),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding: EdgeInsets.all(8.r),
//                                     child: TextButton(
//                                       onPressed: () => _showGrowthDetailsDialog(context, record),
//                                       child: Text('Details', style: TextStyle(fontSize: 12.sp)),
//                                     ),
//                                   ),
//                                 ],
//                               );
//                             }).toList(),
//                           ],
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Head Tab
//               SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                   child: Column(
//                     children: [
//                       if (lastRecord != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Last Record',
//                               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                             ),
//                             SizedBox(height: 8.h),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   DateFormat('dd-MMM yyyy').format(lastRecord.date),
//                                   style: TextStyle(fontSize: 14.sp, color: Colors.blue),
//                                 ),
//                                 Text(
//                                   '${lastRecord.headCircumference} cm',
//                                   style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16.h),
//                           ],
//                         ),
//                       _buildGrowthChart(records, 'Head', lastRecord),
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8.h),
//                         child: _buildChangeIndicator(changes, 'Head'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Height Tab
//               SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                   child: Column(
//                     children: [
//                       if (lastRecord != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Last Record',
//                               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                             ),
//                             SizedBox(height: 8.h),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   DateFormat('dd-MMM yyyy').format(lastRecord.date),
//                                   style: TextStyle(fontSize: 14.sp, color: Colors.blue),
//                                 ),
//                                 Text(
//                                   '${lastRecord.height} cm',
//                                   style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16.h),
//                           ],
//                         ),
//                       _buildGrowthChart(records, 'Height', lastRecord),
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8.h),
//                         child: _buildChangeIndicator(changes, 'Height'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               // Weight Tab
//               SingleChildScrollView(
//                 child: Padding(
//                   padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//                   child: Column(
//                     children: [
//                       if (lastRecord != null)
//                         Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Last Record',
//                               style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                             ),
//                             SizedBox(height: 8.h),
//                             Row(
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text(
//                                   DateFormat('dd-MMM yyyy').format(lastRecord.date),
//                                   style: TextStyle(fontSize: 14.sp, color: Colors.blue),
//                                 ),
//                                 Text(
//                                   '${lastRecord.weight} kg',
//                                   style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue),
//                                 ),
//                               ],
//                             ),
//                             SizedBox(height: 16.h),
//                           ],
//                         ),
//                       _buildGrowthChart(records, 'Weight', lastRecord),
//                       Padding(
//                         padding: EdgeInsets.symmetric(vertical: 8.h),
//                         child: _buildChangeIndicator(changes, 'Weight'),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton.extended(
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => LogGrowthScreen(childId: widget.childId),
//             ),
//           );
//         },
//         label: Text('Add New Record', style: TextStyle(fontSize: 14.sp)),
//         icon: const Icon(Icons.add),
//       ),
//     );
//   }
// }


import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/growth_cubit.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/models/growth_model.dart';
import 'package:segma/screens/growth_user/LogGrowthScreen.dart';
import 'package:segma/services/child_service.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';

class PercentileData {
  final double age; // in months
  final double value; // height (cm), weight (kg), or head circumference (cm)

  PercentileData(this.age, this.value);

  factory PercentileData.fromJson(Map<String, dynamic> json) {
    return PercentileData(
      (json['ageInMonths'] as num).toDouble(),
      (json['value'] as num).toDouble(),
    );
  }
}

class GrowthScreen2 extends StatefulWidget {
  final String childId;

  const GrowthScreen2({
    Key? key,
    required this.childId,
  }) : super(key: key);

  @override
  _GrowthScreen2State createState() => _GrowthScreen2State();
}

class _GrowthScreen2State extends State<GrowthScreen2> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, List<List<PercentileData>>> percentileData = {
    'Head': [],
    'Height': [],
    'Weight': [],
  };
  bool isLoadingPercentiles = true;
  bool isMale = true; // Default value, will be updated after fetching child data
  bool isLoadingChildData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _fetchChildDataAndInitialize();
  }

  Future<void> _fetchChildDataAndInitialize() async {
    try {
      final childData = await ChildService.getChildren();
      print('ChildService.getChildren response: $childData');
      if (childData['status'] == 'success') {
        final List<Child> children = childData['data'] as List<Child>;
        Child? child;
        try {
          child = children.firstWhere((c) => c.id == widget.childId);
        } catch (e) {
          child = null;
        }
        print('Child found: $child');
        if (child != null) {
          setState(() {
            isMale = child?.gender.toLowerCase() == 'boy';
            isLoadingChildData = false;
          });
          print('isMale set to: $isMale');
          await _loadPercentileData();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<GrowthCubit>().initialize(
                  childId: widget.childId,
                );
          });
        } else {
          setState(() {
            isLoadingChildData = false;
            isLoadingPercentiles = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Child not found')),
          );
        }
      } else {
        setState(() {
          isLoadingChildData = false;
          isLoadingPercentiles = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(childData['message'])),
        );
      }
    } catch (e) {
      print('Error in _fetchChildDataAndInitialize: $e');
      setState(() {
        isLoadingChildData = false;
        isLoadingPercentiles = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching child data: $e')),
      );
    }
  }

  Future<void> _loadPercentileData() async {
    try {
      final String jsonPath = isMale
          ? 'assets/data/growth_boys.json'
          : 'assets/data/growth_girls.json';
      print('Loading JSON from: $jsonPath');
      final String jsonString = await rootBundle.loadString(jsonPath);
      print('JSON loaded successfully, length: ${jsonString.length}');
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);
      print('JSON decoded successfully: $jsonData');

      setState(() {
        percentileData['Height'] = [
          (jsonData['height']['3'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['height']['15'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['height']['50'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['height']['85'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['height']['97'] as List).map((item) => PercentileData.fromJson(item)).toList(),
        ];
        percentileData['Weight'] = [
          (jsonData['weight']['3'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['weight']['15'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['weight']['50'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['weight']['85'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['weight']['97'] as List).map((item) => PercentileData.fromJson(item)).toList(),
        ];
        percentileData['Head'] = [
          (jsonData['headCircumference']['3'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['headCircumference']['15'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['headCircumference']['50'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['headCircumference']['85'] as List).map((item) => PercentileData.fromJson(item)).toList(),
          (jsonData['headCircumference']['97'] as List).map((item) => PercentileData.fromJson(item)).toList(),
        ];
        print('Percentile Data loaded: $percentileData');
        isLoadingPercentiles = false;
        print('isLoadingPercentiles set to false');
      });
    } catch (e, stackTrace) {
      print('Error loading percentile data: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        isLoadingPercentiles = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showGrowthDetailsDialog(BuildContext context, GrowthRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Growth Details', style: TextStyle(fontSize: 18.sp)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Date: ${DateFormat('dd-MM-yyyy').format(record.date)}'),
                Text('Time: ${record.time}'),
                Text('Weight: ${record.weight} kg'),
                Text('Height: ${record.height} cm'),
                Text('Head Circumference: ${record.headCircumference} cm'),
                Text('Age: ${record.ageInMonths} months'),
                Text('Notes: ${record.notes.isEmpty ? 'N/A' : record.notes}'),
                if (record.notesImage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Image.network(
                      record.notesImage,
                      height: 100.h,
                      width: 100.w,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close', style: TextStyle(fontSize: 14.sp)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGrowthChart(List<GrowthRecord> records, String type, GrowthRecord? lastRecord) {
    if (isLoadingPercentiles || percentileData[type]!.isEmpty) {
      print('Chart not rendered: isLoadingPercentiles=$isLoadingPercentiles, percentileData[$type] is empty=${percentileData[type]!.isEmpty}');
      return const Center(child: CircularProgressIndicator());
    }

    final List<Map<String, dynamic>> chartData = records.map((record) {
      return {
        'age': record.ageInMonths,
        'value': type == 'Head'
            ? record.headCircumference
            : type == 'Height'
                ? record.height
                : record.weight,
      };
    }).toList();

    // Set min and max for y-axis based on type
    double minY;
    double maxY;
    double intervalY;

    if (type == 'Head') {
      minY = 32;
      maxY = 52;
      intervalY = 1; // For Head: 32, 33, 34, ..., 52
    } else if (type == 'Height') {
      minY = 40;
      maxY = 95;
      intervalY = 5; // For Height: 40, 45, 50, ..., 95
    } else {
      minY = 2;
      maxY = 16;
      intervalY = 2; // For Weight: 2, 4, 6, ..., 16
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w), // Small margin on the sides
      height: MediaQuery.of(context).size.height * 0.5, // Chart takes half the screen height
      child: SfCartesianChart(
        title: ChartTitle(
          text: type, // Title is just the type (Head, Height, Weight)
          textStyle: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
        legend: Legend(
          isVisible: true,
          position: LegendPosition.top, // Place legend at the top
          alignment: ChartAlignment.near, // Align legend to the left
          textStyle: TextStyle(fontSize: 6.sp, color: Colors.blue), // Very small font size
          padding: 0,
          itemPadding: 2,
          iconHeight: 8.sp,
          iconWidth: 8.sp,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'Age: point.x months\npoint.y',
        ),
        zoomPanBehavior: ZoomPanBehavior(
          enablePinching: true,
          enablePanning: true,
          enableDoubleTapZooming: true,
          zoomMode: ZoomMode.xy,
        ),
        primaryXAxis: NumericAxis(
          title: AxisTitle(
            text: 'Age (months)',
            textStyle: TextStyle(fontSize: 14.sp),
          ),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          minimum: 0,
          maximum: 24,
          interval: 2, // Changed to 2 for Age: 0, 2, 4, 6, ..., 24
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: type == 'Head'
                ? 'Head Circumference (cm)'
                : type == 'Height'
                    ? 'Height (cm)'
                    : 'Weight (kg)',
            textStyle: TextStyle(fontSize: 14.sp),
          ),
          minimum: minY,
          maximum: maxY,
          interval: intervalY,
          majorGridLines: MajorGridLines(width: 0.5, color: Colors.grey[300]),
        ),
        series: <CartesianSeries>[
          ...percentileData[type]!.asMap().entries.map((entry) {
            int index = entry.key;
            List<PercentileData> data = entry.value;
            String percentileLabel = ['3rd', '15th', '50th', '85th', '97th'][index];
            return SplineSeries<PercentileData, double>(
              name: '$percentileLabel Percentile',
              dataSource: data,
              xValueMapper: (PercentileData pd, _) => pd.age,
              yValueMapper: (PercentileData pd, _) => pd.value,
              color: [Colors.red, Colors.orange, Colors.green, Colors.blue, Colors.purple][index],
              width: 1.5,
              enableTooltip: true,
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.95, // Very smooth curve
            );
          }).toList(),
          if (chartData.isNotEmpty) // Show child's data only if records exist
            SplineSeries<Map<String, dynamic>, double>(
              name: 'Child\'s $type',
              dataSource: chartData,
              xValueMapper: (Map<String, dynamic> gd, _) => gd['age'] as double,
              yValueMapper: (Map<String, dynamic> gd, _) => gd['value'] as double,
              color: type == 'Head'
                  ? Colors.black
                  : type == 'Height'
                      ? Colors.black
                      : Colors.teal,
              width: 2.5,
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 8,
                height: 8,
                color: type == 'Head'
                    ? Colors.black
                    : type == 'Height'
                        ? Colors.black
                        : Colors.teal,
              ),
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.95, // Very smooth curve
            ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(GrowthChanges changes, String type) {
    double changeValue = type == 'Head'
        ? changes.changes.headCircumferenceChange
        : type == 'Height'
            ? changes.changes.heightChange
            : changes.changes.weightChange;
    bool isPositive = changeValue >= 0;
    String unit = type == 'Head' ? 'cm' : type == 'Height' ? 'cm' : 'kg';
    String changeText = isPositive ? 'Gained' : 'Lost';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
            color: isPositive ? Colors.green : Colors.red,
            size: 16.sp,
          ),
          SizedBox(width: 8.w),
          Text(
            '${changeValue.abs().toStringAsFixed(2)} $unit $changeText',
            style: TextStyle(
              fontSize: 14.sp,
              color: isPositive ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingChildData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Growth', style: TextStyle(fontSize: 18.sp)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Summary'),
            Tab(text: 'Head'),
            Tab(text: 'Height'),
            Tab(text: 'Weight'),
          ],
        ),
      ),
      body: BlocBuilder<GrowthCubit, GrowthState>(
        builder: (context, state) {
          if (state is GrowthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          List<GrowthRecord> records = [];
          GrowthRecord? lastRecord;
          GrowthChanges changes = GrowthChanges(
            previousRecord: null,
            changes: const GrowthChange(heightChange: 0, weightChange: 0, headCircumferenceChange: 0),
          );

          if (state is GrowthLoaded) {
            records = state.records;
            lastRecord = state.lastRecord;
            changes = state.changes;
          } else if (state is GrowthError && state.message.contains('No growth records found')) {
            records = [];
            lastRecord = null;
            changes = GrowthChanges(
              previousRecord: null,
              changes: const GrowthChange(heightChange: 0, weightChange: 0, headCircumferenceChange: 0),
            );
          } else if (state is GrowthError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error', style: TextStyle(fontSize: 16.sp)),
                  SizedBox(height: 8.h),
                  Text(state.message, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                ],
              ),
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // Summary Tab
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'History',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                      SizedBox(height: 8.h),
                      if (records.isEmpty)
                        const Center(child: Text('No growth records found', style: TextStyle(color: Colors.blue)))
                      else
                        Table(
                          border: TableBorder.all(color: Colors.grey.shade300),
                          columnWidths: const {
                            0: FlexColumnWidth(1),
                            1: FlexColumnWidth(1),
                            2: FlexColumnWidth(1),
                            3: FlexColumnWidth(1),
                            4: FlexColumnWidth(1),
                          },
                          children: [
                            TableRow(
                              decoration: BoxDecoration(color: Colors.grey.shade200),
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: Text('Head', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: Text('Height', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: Text('Weight', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: Text('Date', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: EdgeInsets.all(8.r),
                                  child: Text('Details', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                            ...records.asMap().entries.map((entry) {
                              final record = entry.value;
                              return TableRow(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.all(8.r),
                                    child: Text('${record.headCircumference} cm', style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.r),
                                    child: Text('${record.height} cm', style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.r),
                                    child: Text('${record.weight} kg', style: TextStyle(fontSize: 12.sp, color: Colors.blue)),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.r),
                                    child: Text(
                                      DateFormat('dd/MM/yyyy').format(record.date),
                                      style: TextStyle(fontSize: 12.sp, color: Colors.blue),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.r),
                                    child: TextButton(
                                      onPressed: () => _showGrowthDetailsDialog(context, record),
                                      child: Text('Details', style: TextStyle(fontSize: 12.sp)),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
              // Head Tab
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    children: [
                      if (lastRecord != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Record',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd-MMM yyyy').format(lastRecord.date),
                                  style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                                ),
                                Text(
                                  '${lastRecord.headCircumference} cm',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      _buildGrowthChart(records, 'Head', lastRecord),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: _buildChangeIndicator(changes, 'Head'),
                      ),
                    ],
                  ),
                ),
              ),
              // Height Tab
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    children: [
                      if (lastRecord != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Record',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd-MMM yyyy').format(lastRecord.date),
                                  style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                                ),
                                Text(
                                  '${lastRecord.height} cm',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      _buildGrowthChart(records, 'Height', lastRecord),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: _buildChangeIndicator(changes, 'Height'),
                      ),
                    ],
                  ),
                ),
              ),
              // Weight Tab
              SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Column(
                    children: [
                      if (lastRecord != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Last Record',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  DateFormat('dd-MMM yyyy').format(lastRecord.date),
                                  style: TextStyle(fontSize: 14.sp, color: Colors.blue),
                                ),
                                Text(
                                  '${lastRecord.weight} kg',
                                  style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.blue),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                          ],
                        ),
                      _buildGrowthChart(records, 'Weight', lastRecord),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        child: _buildChangeIndicator(changes, 'Weight'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LogGrowthScreen(childId: widget.childId),
            ),
          );
        },
        label: Text('Add New Record', style: TextStyle(fontSize: 14.sp)),
        icon: const Icon(Icons.add),
      ),
    );
  }
}