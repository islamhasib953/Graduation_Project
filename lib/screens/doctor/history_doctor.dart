// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/cubits/growth_cubit.dart';
// import 'package:segma/cubits/history_cubit.dart';
// import 'package:segma/models/history_model.dart';
// import 'package:segma/screens/growth_user/GrowthScreen.dart';
// import 'package:segma/screens/doctor/history_details_doctor.dart';
// import 'package:segma/screens/doctor/log_diagnosis.dart';
// import 'package:segma/services/doctor_service.dart';
// import 'package:segma/services/child_service.dart';
// import 'package:segma/utils/colors.dart';
// import 'package:intl/intl.dart';

// class AllHistoryScreen extends StatefulWidget {
//   const AllHistoryScreen({Key? key}) : super(key: key);

//   @override
//   _AllHistoryScreenState createState() => _AllHistoryScreenState();
// }

// class _AllHistoryScreenState extends State<AllHistoryScreen>
//     with SingleTickerProviderStateMixin {
//   final TextEditingController _childIdController = TextEditingController();
//   late TabController _tabController;
//   String _childId = '';
//   bool _hasSearched = false;

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 2, vsync: this);
//   }

//   void _fetchRecords() {
//     if (_childId.isNotEmpty) {
//       context.read<HistoryCubit>().fetchHistory(_childId);
//       setState(() {
//         _hasSearched = true;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _childIdController.dispose();
//     _tabController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Child Records', style: TextStyle(fontSize: 18.sp)),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(text: 'History'),
//             Tab(text: 'Growth'),
//           ],
//         ),
//       ),
//       body: Column(
//         children: [
//           Padding(
//             padding: EdgeInsets.all(16.r),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _childIdController,
//                     decoration: InputDecoration(
//                       hintText: 'Enter Child ID',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       filled: true,
//                       fillColor: AppColors.lightSearchBackground,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                     ),
//                     style: TextStyle(fontSize: 14.sp),
//                     onChanged: (value) {
//                       setState(() {
//                         _childId = value.trim();
//                       });
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 ElevatedButton(
//                   onPressed: _childId.isNotEmpty ? _fetchRecords : null,
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                   ),
//                   child: Text('Search', style: TextStyle(fontSize: 14.sp)),
//                 ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: TabBarView(
//               controller: _tabController,
//               children: [
//                 HistoryTab(childId: _childId),
//                 GrowthTab(childId: _childId),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: _tabController.index == 0 && _childId.isNotEmpty && _hasSearched
//           ? FloatingActionButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   PageRouteBuilder(
//                     pageBuilder: (context, animation, secondaryAnimation) => LogDiagnosisScreen(childId: _childId),
//                     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                       return FadeTransition(
//                         opacity: animation,
//                         child: child,
//                       );
//                     },
//                   ),
//                 ).then((_) => _fetchRecords());
//               },
//               child: Icon(Icons.add),
//               backgroundColor: AppColors.lightButtonPrimary,
//             )
//           : null,
//     );
//   }
// }

// class HistoryTab extends StatelessWidget {
//   final String childId;

//   const HistoryTab({Key? key, required this.childId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<HistoryCubit, List<History>>(
//       builder: (context, histories) {
//         if (context.read<HistoryCubit>().error != null) {
//           return Center(
//             child: Text(
//               context.read<HistoryCubit>().error!,
//               style: TextStyle(fontSize: 14.sp),
//             ),
//           );
//         }

//         if (histories.isEmpty && childId.isNotEmpty) {
//           return Center(child: Text('No history records found', style: TextStyle(fontSize: 14.sp)));
//         }

//         return ListView.builder(
//           padding: EdgeInsets.all(16.r),
//           itemCount: histories.length,
//           itemBuilder: (context, index) {
//             final history = histories[index];
//             return Card(
//               elevation: 2,
//               margin: EdgeInsets.symmetric(vertical: 8.h),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//               child: ListTile(
//                 contentPadding: EdgeInsets.all(12.r),
//                 title: Text(
//                   history.diagnosis,
//                   style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text(
//                   'Date: ${DateFormat('dd MMM, yyyy').format(history.date)} | Time: ${history.time}',
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//                 trailing: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder: (context, animation, secondaryAnimation) => HistoryDetailsDoctorScreen(
//                           history: history,
//                           childId: childId,
//                         ),
//                         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                           return FadeTransition(
//                             opacity: animation,
//                             child: child,
//                           );
//                         },
//                       ),
//                     ).then((_) => context.read<HistoryCubit>().fetchHistory(childId));
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                   ),
//                   child: Text('Details', style: TextStyle(fontSize: 12.sp)),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }

// class GrowthTab extends StatelessWidget {
//   final String childId;

//   const GrowthTab({Key? key, required this.childId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<Map<String, dynamic>>(
//       future: DoctorService.getChildRecords(childId),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return Center(child: CircularProgressIndicator());
//         }
//         if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
//           return Center(
//             child: Text(
//               snapshot.hasError
//                   ? 'Error: ${snapshot.error}'
//                   : snapshot.data!['message'] ?? 'No records found',
//               style: TextStyle(fontSize: 14.sp),
//             ),
//           );
//         }

//         final List<dynamic> growthRecords = snapshot.data!['data']['growthRecords'];
//         if (growthRecords.isEmpty) {
//           return Center(child: Text('No growth records found', style: TextStyle(fontSize: 14.sp)));
//         }

//         return ListView.builder(
//           padding: EdgeInsets.all(16.r),
//           itemCount: growthRecords.length,
//           itemBuilder: (context, index) {
//             final record = growthRecords[index];
//             return Card(
//               elevation: 2,
//               margin: EdgeInsets.symmetric(vertical: 8.h),
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//               child: ListTile(
//                 contentPadding: EdgeInsets.all(12.r),
//                 title: Text(
//                   'Record ${index + 1}',
//                   style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
//                 ),
//                 subtitle: Text(
//                   'Date: ${record['date']}',
//                   style: TextStyle(fontSize: 12.sp),
//                 ),
//                 trailing: ElevatedButton(
//                   onPressed: () {
//                     // تهيئة GrowthCubit بالطفل المختار
//                     context.read<GrowthCubit>().initialize(
//                           childId: childId,
//                         );
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder: (context, animation, secondaryAnimation) => GrowthScreen2(
//                           childId: childId,
//                         ),
//                         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                           return FadeTransition(
//                             opacity: animation,
//                             child: child,
//                           );
//                         },
//                       ),
//                     );
//                   },
//                   style: ElevatedButton.styleFrom(
//                     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                   ),
//                   child: Text('Details', style: TextStyle(fontSize: 12.sp)),
//                 ),
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/growth_cubit.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/models/growth_model.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/screens/doctor/log_diagnosis.dart';
import 'package:segma/screens/growth_user/LogGrowthScreen.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'dart:convert';

class PercentileData {
  final double age;
  final double value;

  PercentileData(this.age, this.value);

  factory PercentileData.fromJson(Map<String, dynamic> json) {
    return PercentileData(
      (json['ageInMonths'] as num).toDouble(),
      (json['value'] as num).toDouble(),
    );
  }
}

class AllHistoryScreen extends StatefulWidget {
  const AllHistoryScreen({Key? key}) : super(key: key);

  @override
  _AllHistoryScreenState createState() => _AllHistoryScreenState();
}

class _AllHistoryScreenState extends State<AllHistoryScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _childIdController = TextEditingController();
  late TabController _tabController;
  String _childId = '';
  bool _hasSearched = false;
  bool _isSearching = false;
  Map<String, List<List<PercentileData>>> percentileData = {
    'Head': [],
    'Height': [],
    'Weight': [],
  };
  bool isLoadingPercentiles = true;
  bool isMale = true;
  bool isLoadingChildData = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _fetchChildDataAndInitialize() async {
    try {
      setState(() {
        isMale = true;
        isLoadingChildData = false;
      });
      await _loadPercentileData();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<GrowthCubit>().initialize(childId: _childId);
      });
    } catch (e) {
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
      final String jsonString = await rootBundle.loadString(jsonPath);
      final Map<String, dynamic> jsonData = jsonDecode(jsonString);

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
        isLoadingPercentiles = false;
      });
    } catch (e) {
      setState(() {
        isLoadingPercentiles = false;
      });
    }
  }

  void _fetchRecords() async {
    if (_childId.isNotEmpty) {
      setState(() {
        _isSearching = true;
      });
      await Future.wait([
        context.read<HistoryCubit>().fetchHistory(_childId),
        _fetchChildDataAndInitialize(),
      ]);
      setState(() {
        _hasSearched = true;
        _isSearching = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a child ID')),
      );
    }
  }

  @override
  void dispose() {
    _childIdController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildGrowthChart(List<GrowthRecord> records, String type, GrowthRecord? lastRecord) {
    if (isLoadingPercentiles || percentileData[type]!.isEmpty) {
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

    double minY;
    double maxY;
    double intervalY;

    if (type == 'Head') {
      minY = 32;
      maxY = 52;
      intervalY = 1;
    } else if (type == 'Height') {
      minY = 40;
      maxY = 95;
      intervalY = 5;
    } else {
      minY = 2;
      maxY = 16;
      intervalY = 2;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      height: MediaQuery.of(context).size.height * 0.4,
      child: SfCartesianChart(
        legend: Legend(
          isVisible: true,
          position: LegendPosition.top,
          alignment: ChartAlignment.near,
          textStyle: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          padding: 0,
          itemPadding: 2,
          iconHeight: 8.sp,
          iconWidth: 8.sp,
        ),
        tooltipBehavior: TooltipBehavior(
          enable: true,
          format: 'Age: point.x months\npoint.y',
        ),
        primaryXAxis: NumericAxis(
          title: AxisTitle(
            text: 'Age (completed months and years)',
            textStyle: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          edgeLabelPlacement: EdgeLabelPlacement.shift,
          minimum: 0,
          maximum: 24,
          interval: 2,
          majorGridLines: MajorGridLines(
            width: 0.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
          labelStyle: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        primaryYAxis: NumericAxis(
          title: AxisTitle(
            text: type == 'Head'
                ? 'Head Circumference (cm)'
                : type == 'Height'
                    ? 'Height (cm)'
                    : 'Weight (kg)',
            textStyle: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          minimum: minY,
          maximum: maxY,
          interval: intervalY,
          majorGridLines: MajorGridLines(
            width: 0.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
          ),
          labelStyle: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
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
              cardinalSplineTension: 0.95,
            );
          }).toList(),
          if (chartData.isNotEmpty)
            SplineSeries<Map<String, dynamic>, double>(
              name: 'Child\'s $type',
              dataSource: chartData,
              xValueMapper: (Map<String, dynamic> gd, _) => gd['age'] as double,
              yValueMapper: (Map<String, dynamic> gd, _) => gd['value'] as double,
              color: Theme.of(context).colorScheme.onSurface,
              width: 2.5,
              markerSettings: MarkerSettings(
                isVisible: true,
                shape: DataMarkerType.circle,
                width: 8,
                height: 8,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              splineType: SplineType.cardinal,
              cardinalSplineTension: 0.95,
            ),
        ],
      ),
    );
  }

  void _showGrowthDetailsDialog(BuildContext context, GrowthRecord record) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surface,
          title: Text(
            'Growth Details',
            style: TextStyle(
              fontSize: 18.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow(context, 'Date', DateFormat('dd-MM-yyyy').format(record.date)),
                _buildDetailRow(context, 'Time', record.time),
                _buildDetailRow(context, 'Weight', '${record.weight} kg'),
                _buildDetailRow(context, 'Height', '${record.height} cm'),
                _buildDetailRow(context, 'Head Circumference', '${record.headCircumference} cm'),
                _buildDetailRow(context, 'Age', '${record.ageInMonths} months'),
                _buildDetailRow(context, 'Notes', record.notes.isEmpty ? 'N/A' : record.notes),
                if (record.notesImage.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 8.h),
                    child: Image.network(
                      record.notesImage,
                      height: 100.h,
                      width: 100.w,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          'Child Records',
          style: TextStyle(
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Theme.of(context).colorScheme.primary,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
          indicatorColor: Theme.of(context).colorScheme.primary,
          tabs: const [
            Tab(text: 'Diagnosis'),
            Tab(text: 'Growth'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _childIdController,
                    decoration: InputDecoration(
                      hintText: 'Enter ID for baby',
                      hintStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                      suffixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _childId = value.trim();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: _fetchRecords,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  ),
                  child: _isSearching
                      ? SizedBox(
                          height: 20.h,
                          width: 20.w,
                          child: CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.onPrimary,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Search',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  HistoryTab(childId: _childId, hasSearched: _hasSearched, showGrowthDetailsDialog: _showGrowthDetailsDialog),
                  GrowthTab(
                    childId: _childId,
                    hasSearched: _hasSearched,
                    buildGrowthChart: _buildGrowthChart,
                    showGrowthDetailsDialog: _showGrowthDetailsDialog,
                  ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButton: _hasSearched && _childId.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                if (_tabController.index == 0) {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => LogDiagnosisScreen(childId: _childId),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  ).then((_) => _fetchRecords());
                } else {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => LogGrowthScreen(childId: _childId),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return FadeTransition(
                          opacity: animation,
                          child: child,
                        );
                      },
                    ),
                  ).then((_) => _fetchRecords());
                }
              },
              child: Icon(
                Icons.add,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
            )
          : null,
    );
  }
}

class HistoryTab extends StatelessWidget {
  final String childId;
  final bool hasSearched;
  final void Function(BuildContext, GrowthRecord) showGrowthDetailsDialog;

  const HistoryTab({
    Key? key,
    required this.childId,
    required this.hasSearched,
    required this.showGrowthDetailsDialog,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!hasSearched || childId.isEmpty) {
      return Center(
        child: Text(
          'Please enter a child ID and press Search to view records',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      );
    }

    return BlocBuilder<HistoryCubit, List<History>>(
      builder: (context, histories) {
        return BlocBuilder<GrowthCubit, GrowthState>(
          builder: (context, growthState) {
            List<GrowthRecord> growthRecords = [];
            if (growthState is GrowthLoaded) {
              growthRecords = growthState.records;
            }

            if (context.read<HistoryCubit>().error != null) {
              return Center(
                child: Text(
                  context.read<HistoryCubit>().error!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            if (histories.isEmpty && growthRecords.isEmpty) {
              return Center(
                child: Text(
                  'No history records found',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Table(
                      border: TableBorder.all(
                        color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
                      ),
                      columnWidths: const {
                        0: FlexColumnWidth(1),
                        1: FlexColumnWidth(1),
                        2: FlexColumnWidth(1),
                        3: FlexColumnWidth(1),
                        4: FlexColumnWidth(1),
                      },
                      children: [
                        TableRow(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          children: [
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text(
                                'Head',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text(
                                'Height',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text(
                                'Weight',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.all(8.r),
                              child: Text(
                                'Details',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                        ...growthRecords.asMap().entries.map((entry) {
                          final record = entry.value;
                          return TableRow(
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Text(
                                  '${record.headCircumference} cm',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Text(
                                  '${record.height} cm',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Text(
                                  '${record.weight} kg',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.r),
                                child: Text(
                                  DateFormat('dd/MM/yyyy').format(record.date),
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.r),
                                child: TextButton(
                                  onPressed: () {
                                    showGrowthDetailsDialog(context, record);
                                  },
                                  child: Text(
                                    'Details',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
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
            );
          },
        );
      },
    );
  }
}

class GrowthTab extends StatefulWidget {
  final String childId;
  final bool hasSearched;
  final Widget Function(List<GrowthRecord>, String, GrowthRecord?) buildGrowthChart;
  final void Function(BuildContext, GrowthRecord) showGrowthDetailsDialog;

  const GrowthTab({
    Key? key,
    required this.childId,
    required this.hasSearched,
    required this.buildGrowthChart,
    required this.showGrowthDetailsDialog,
  }) : super(key: key);

  @override
  _GrowthTabState createState() => _GrowthTabState();
}

class _GrowthTabState extends State<GrowthTab> with SingleTickerProviderStateMixin {
  late TabController _growthTabController;

  @override
  void initState() {
    super.initState();
    _growthTabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _growthTabController.dispose();
    super.dispose();
  }

  double _calculateGrowthChange(List<GrowthRecord> records, String type) {
    if (records.length < 2) return 0.0;

    final lastRecord = records.last;
    final secondLastRecord = records[records.length - 2];

    double lastValue;
    double secondLastValue;

    switch (type) {
      case 'Head':
        lastValue = lastRecord.headCircumference;
        secondLastValue = secondLastRecord.headCircumference;
        break;
      case 'Height':
        lastValue = lastRecord.height;
        secondLastValue = secondLastRecord.height;
        break;
      case 'Weight':
        lastValue = lastRecord.weight;
        secondLastValue = secondLastRecord.weight;
        break;
      default:
        return 0.0;
    }

    return lastValue - secondLastValue;
  }

  Widget _buildSummaryTab(List<GrowthRecord> records) {
    if (records.isEmpty) {
      return const Center(child: Text('No records available'));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Records',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(height: 8.h),
            Table(
              border: TableBorder.all(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.2),
              ),
              columnWidths: const {
                0: FlexColumnWidth(1),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Text(
                        'Head',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Text(
                        'Height',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Text(
                        'Weight',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Text(
                        'Date',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.r),
                      child: Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                ...records.asMap().entries.map((entry) {
                  final record = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Text(
                          '${record.headCircumference} cm',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Text(
                          '${record.height} cm',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Text(
                          '${record.weight} kg',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.r),
                        child: Text(
                          DateFormat('dd/MM/yyyy').format(record.date),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(8.r),
                        child: TextButton(
                          onPressed: () {
                            widget.showGrowthDetailsDialog(context, record);
                          },
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
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
    );
  }

  Widget _buildGrowthSection(List<GrowthRecord> records, String type, GrowthRecord? lastRecord) {
    if (records.isEmpty) {
      return const Center(child: Text('No records available'));
    }

    final lastValue = type == 'Head'
        ? lastRecord!.headCircumference
        : type == 'Height'
            ? lastRecord!.height
            : lastRecord!.weight;

    final growthChange = _calculateGrowthChange(records, type);
    final isGained = growthChange >= 0;

    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Last Record',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('dd-MMM-yyyy').format(lastRecord!.date),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${lastValue.toStringAsFixed(2)} ${type == 'Head' ? 'mm' : type == 'Height' ? 'cm' : 'kg'}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            widget.buildGrowthChart(records, type, lastRecord),
            SizedBox(height: 16.h),
            Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Summary',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Text(
                        '${growthChange.abs().toStringAsFixed(2)} ${type == 'Head' ? 'mm' : type == 'Height' ? 'cm' : 'kg'}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isGained ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isGained ? 'Gained' : 'Lost',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isGained ? Colors.green : Colors.red,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Icon(
                        isGained ? Icons.arrow_upward : Icons.arrow_downward,
                        color: isGained ? Colors.green : Colors.red,
                        size: 16.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Total ${type.toLowerCase()} growth past record',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.hasSearched || widget.childId.isEmpty) {
      return Center(
        child: Text(
          'Please enter a child ID and press Search to view records',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
          ),
        ),
      );
    }

    return BlocBuilder<GrowthCubit, GrowthState>(
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
                Text(
                  state.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Please ensure the child ID is correct and you have the necessary permissions.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        if (records.isEmpty) {
          return Center(
            child: Text(
              'No growth records found',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          );
        }

        return Column(
          children: [
            TabBar(
              controller: _growthTabController,
              labelColor: Theme.of(context).colorScheme.primary,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
              indicatorColor: Theme.of(context).colorScheme.primary,
              tabs: const [
                Tab(text: 'Summary'),
                Tab(text: 'Head'),
                Tab(text: 'Height'),
                Tab(text: 'Weight'),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _growthTabController,
                children: [
                  _buildSummaryTab(records),
                  _buildGrowthSection(records, 'Head', lastRecord),
                  _buildGrowthSection(records, 'Height', lastRecord),
                  _buildGrowthSection(records, 'Weight', lastRecord),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}