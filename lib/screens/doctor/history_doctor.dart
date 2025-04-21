// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/cubits/history_cubit.dart';
// import 'package:segma/models/history_model.dart';
// import 'package:segma/screens/growth_user/GrowthScreen.dart';
// import 'package:segma/screens/doctor/history_details_doctor.dart';
// import 'package:segma/screens/doctor/log_diagnosis.dart';
// import 'package:segma/services/doctor_service.dart';
// import 'package:segma/utils/colors.dart';
// import 'package:intl/intl.dart';

// class AllHistoryScreen extends StatefulWidget {
//   const AllHistoryScreen({Key? key}) : super(key: key);

//   @override
//   _AllHistoryScreenState createState() => _AllHistoryScreenState();
// }

// class _AllHistoryScreenState extends State<AllHistoryScreen> with SingleTickerProviderStateMixin {
//   final TextEditingController _childIdController = TextEditingController();
//   late TabController _tabController;
//   String _childId = '';
//   bool _hasSearched = false;
//   bool _isSearchPressed = false;

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
//         title: Text(
//           'Child Records',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         elevation: 0,
//         bottom: TabBar(
//           controller: _tabController,
//           labelStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
//           unselectedLabelStyle: Theme.of(context).textTheme.bodyLarge,
//           labelColor: Theme.of(context).primaryColor,
//           unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
//           tabs: const [
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
//                       hintText: 'Enter child ID',
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8.r),
//                       ),
//                       filled: true,
//                       fillColor: Theme.of(context).dividerColor,
//                       contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                     ),
//                     style: Theme.of(context).textTheme.bodyLarge,
//                     onChanged: (value) {
//                       setState(() {
//                         _childId = value.trim();
//                       });
//                     },
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 StatefulBuilder(
//                   builder: (context, setState) {
//                     return GestureDetector(
//                       onTapDown: (_) => setState(() => _isSearchPressed = true),
//                       onTapUp: (_) {
//                         setState(() => _isSearchPressed = false);
//                         _fetchRecords();
//                       },
//                       onTapCancel: () => setState(() => _isSearchPressed = false),
//                       child: AnimatedScale(
//                         scale: _isSearchPressed ? 0.95 : 1.0,
//                         duration: const Duration(milliseconds: 100),
//                         child: ElevatedButton(
//                           onPressed: _childId.isNotEmpty ? _fetchRecords : null,
//                           style: ElevatedButton.styleFrom(
//                             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                             backgroundColor: Theme.of(context).primaryColor,
//                             disabledBackgroundColor: Theme.of(context).disabledColor,
//                           ),
//                           child: Text(
//                             'Search',
//                             style: Theme.of(context).textTheme.bodyLarge,
//                           ),
//                         ),
//                       ),
//                     );
//                   },
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
//           ? StatefulBuilder(
//               builder: (context, setState) {
//                 bool _isFabPressed = false;
//                 return GestureDetector(
//                   onTapDown: (_) => setState(() => _isFabPressed = true),
//                   onTapUp: (_) {
//                     setState(() => _isFabPressed = false);
//                     Navigator.push(
//                       context,
//                       PageRouteBuilder(
//                         pageBuilder: (context, animation, secondaryAnimation) => LogDiagnosisScreen(childId: _childId),
//                         transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                           return FadeTransition(
//                             opacity: animation,
//                             child: child,
//                           );
//                         },
//                       ),
//                     ).then((_) => _fetchRecords());
//                   },
//                   onTapCancel: () => setState(() => _isFabPressed = false),
//                   child: AnimatedScale(
//                     scale: _isFabPressed ? 0.95 : 1.0,
//                     duration: const Duration(milliseconds: 100),
//                     child: FloatingActionButton(
//                       onPressed: () {
//                         Navigator.push(
//                           context,
//                           PageRouteBuilder(
//                             pageBuilder: (context, animation, secondaryAnimation) => LogDiagnosisScreen(childId: _childId),
//                             transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                               return FadeTransition(
//                                 opacity: animation,
//                                 child: child,
//                               );
//                             },
//                           ),
//                         ).then((_) => _fetchRecords());
//                       },
//                       backgroundColor: Theme.of(context).primaryColor,
//                       child: Icon(
//                         Icons.add,
//                         size: 24.sp,
//                         color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
//                       ),
//                     ),
//                   ),
//                 );
//               },
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
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }

//         if (histories.isEmpty && childId.isNotEmpty) {
//           return Center(
//             child: Text(
//               'No history records',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: EdgeInsets.all(16.r),
//           itemCount: histories.length,
//           itemBuilder: (context, index) {
//             final history = histories[index];
//             bool _isCardPressed = false;
//             bool _isDetailsPressed = false;

//             return StatefulBuilder(
//               builder: (context, setState) {
//                 return GestureDetector(
//                   onTapDown: (_) => setState(() => _isCardPressed = true),
//                   onTapUp: (_) => setState(() => _isCardPressed = false),
//                   onTapCancel: () => setState(() => _isCardPressed = false),
//                   child: AnimatedScale(
//                     scale: _isCardPressed ? 0.95 : 1.0,
//                     duration: const Duration(milliseconds: 100),
//                     child: Card(
//                       elevation: 2,
//                       margin: EdgeInsets.symmetric(vertical: 8.h),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                       color: Theme.of(context).cardColor,
//                       child: ListTile(
//                         contentPadding: EdgeInsets.all(12.r),
//                         title: Text(
//                           history.diagnosis,
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         subtitle: Text(
//                           'Date: ${DateFormat('dd MMM, yyyy').format(history.date)} | Time: ${history.time}',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                         trailing: GestureDetector(
//                           onTapDown: (_) => setState(() => _isDetailsPressed = true),
//                           onTapUp: (_) {
//                             setState(() => _isDetailsPressed = false);
//                             Navigator.push(
//                               context,
//                               PageRouteBuilder(
//                                 pageBuilder: (context, animation, secondaryAnimation) => HistoryDetailsDoctorScreen(
//                                   history: history,
//                                   childId: childId,
//                                 ),
//                                 transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                   return FadeTransition(
//                                     opacity: animation,
//                                     child: child,
//                                   );
//                                 },
//                               ),
//                             ).then((_) => context.read<HistoryCubit>().fetchHistory(childId));
//                           },
//                           onTapCancel: () => setState(() => _isDetailsPressed = false),
//                           child: AnimatedScale(
//                             scale: _isDetailsPressed ? 0.95 : 1.0,
//                             duration: const Duration(milliseconds: 100),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   PageRouteBuilder(
//                                     pageBuilder: (context, animation, secondaryAnimation) => HistoryDetailsDoctorScreen(
//                                       history: history,
//                                       childId: childId,
//                                     ),
//                                     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                       return FadeTransition(
//                                         opacity: animation,
//                                         child: child,
//                                       );
//                                     },
//                                   ),
//                                 ).then((_) => context.read<HistoryCubit>().fetchHistory(childId));
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                                 backgroundColor: Theme.of(context).primaryColor,
//                               ),
//                               child: Text(
//                                 'Details',
//                                 style: Theme.of(context).textTheme.bodyLarge,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
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
//           return Center(
//             child: CircularProgressIndicator(
//               color: Theme.of(context).primaryColor,
//             ),
//           );
//         }
//         if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
//           return Center(
//             child: Text(
//               snapshot.hasError ? 'Error: ${snapshot.error}' : snapshot.data!['message'] ?? 'No growth records',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }

//         final List<dynamic> growthRecords = snapshot.data!['data']['growthRecords'];
//         if (growthRecords.isEmpty) {
//           return Center(
//             child: Text(
//               'No growth records',
//               style: Theme.of(context).textTheme.bodyMedium,
//             ),
//           );
//         }

//         return ListView.builder(
//           padding: EdgeInsets.all(16.r),
//           itemCount: growthRecords.length,
//           itemBuilder: (context, index) {
//             final record = growthRecords[index];
//             bool _isCardPressed = false;
//             bool _isDetailsPressed = false;

//             return StatefulBuilder(
//               builder: (context, setState) {
//                 return GestureDetector(
//                   onTapDown: (_) => setState(() => _isCardPressed = true),
//                   onTapUp: (_) => setState(() => _isCardPressed = false),
//                   onTapCancel: () => setState(() => _isCardPressed = false),
//                   child: AnimatedScale(
//                     scale: _isCardPressed ? 0.95 : 1.0,
//                     duration: const Duration(milliseconds: 100),
//                     child: Card(
//                       elevation: 2,
//                       margin: EdgeInsets.symmetric(vertical: 8.h),
//                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
//                       color: Theme.of(context).cardColor,
//                       child: ListTile(
//                         contentPadding: EdgeInsets.all(12.r),
//                         title: Text(
//                           'Record ${index + 1}',
//                           style: Theme.of(context).textTheme.titleMedium,
//                         ),
//                         subtitle: Text(
//                           'Date: ${record['date']}',
//                           style: Theme.of(context).textTheme.bodyMedium,
//                         ),
//                         trailing: GestureDetector(
//                           onTapDown: (_) => setState(() => _isDetailsPressed = true),
//                           onTapUp: (_) {
//                             setState(() => _isDetailsPressed = false);
//                             Navigator.push(
//                               context,
//                               PageRouteBuilder(
//                                 pageBuilder: (context, animation, secondaryAnimation) => GrowthScreen(childId: childId),
//                                 transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                   return FadeTransition(
//                                     opacity: animation,
//                                     child: child,
//                                   );
//                                 },
//                               ),
//                             );
//                           },
//                           onTapCancel: () => setState(() => _isDetailsPressed = false),
//                           child: AnimatedScale(
//                             scale: _isDetailsPressed ? 0.95 : 1.0,
//                             duration: const Duration(milliseconds: 100),
//                             child: ElevatedButton(
//                               onPressed: () {
//                                 Navigator.push(
//                                   context,
//                                   PageRouteBuilder(
//                                     pageBuilder: (context, animation, secondaryAnimation) => GrowthScreen(childId: childId),
//                                     transitionsBuilder: (context, animation, secondaryAnimation, child) {
//                                       return FadeTransition(
//                                         opacity: animation,
//                                         child: child,
//                                       );
//                                     },
//                                   ),
//                                 );
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                                 backgroundColor: Theme.of(context).primaryColor,
//                               ),
//                               child: Text(
//                                 'Details',
//                                 style: Theme.of(context).textTheme.bodyLarge,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//                 );
//               },
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
import 'package:segma/models/history_model.dart';
import 'package:segma/screens/growth_user/GrowthScreen.dart';
import 'package:segma/screens/doctor/history_details_doctor.dart';
import 'package:segma/screens/doctor/log_diagnosis.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/services/child_service.dart';
import 'package:segma/utils/colors.dart';
import 'package:intl/intl.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _fetchRecords() {
    if (_childId.isNotEmpty) {
      context.read<HistoryCubit>().fetchHistory(_childId);
      setState(() {
        _hasSearched = true;
      });
    }
  }

  @override
  void dispose() {
    _childIdController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Child Records', style: TextStyle(fontSize: 18.sp)),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'History'),
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
                      hintText: 'Enter Child ID',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      filled: true,
                      fillColor: AppColors.lightSearchBackground,
                      contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                    style: TextStyle(fontSize: 14.sp),
                    onChanged: (value) {
                      setState(() {
                        _childId = value.trim();
                      });
                    },
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: _childId.isNotEmpty ? _fetchRecords : null,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  child: Text('Search', style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                HistoryTab(childId: _childId),
                GrowthTab(childId: _childId),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 0 && _childId.isNotEmpty && _hasSearched
          ? FloatingActionButton(
              onPressed: () {
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
              },
              child: Icon(Icons.add),
              backgroundColor: AppColors.lightButtonPrimary,
            )
          : null,
    );
  }
}

class HistoryTab extends StatelessWidget {
  final String childId;

  const HistoryTab({Key? key, required this.childId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryCubit, List<History>>(
      builder: (context, histories) {
        if (context.read<HistoryCubit>().error != null) {
          return Center(
            child: Text(
              context.read<HistoryCubit>().error!,
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }

        if (histories.isEmpty && childId.isNotEmpty) {
          return Center(child: Text('No history records found', style: TextStyle(fontSize: 14.sp)));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final history = histories[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: ListTile(
                contentPadding: EdgeInsets.all(12.r),
                title: Text(
                  history.diagnosis,
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: ${DateFormat('dd MMM, yyyy').format(history.date)} | Time: ${history.time}',
                  style: TextStyle(fontSize: 12.sp),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => HistoryDetailsDoctorScreen(
                          history: history,
                          childId: childId,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    ).then((_) => context.read<HistoryCubit>().fetchHistory(childId));
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  child: Text('Details', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class GrowthTab extends StatelessWidget {
  final String childId;

  const GrowthTab({Key? key, required this.childId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: DoctorService.getChildRecords(childId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
          return Center(
            child: Text(
              snapshot.hasError
                  ? 'Error: ${snapshot.error}'
                  : snapshot.data!['message'] ?? 'No records found',
              style: TextStyle(fontSize: 14.sp),
            ),
          );
        }

        final List<dynamic> growthRecords = snapshot.data!['data']['growthRecords'];
        if (growthRecords.isEmpty) {
          return Center(child: Text('No growth records found', style: TextStyle(fontSize: 14.sp)));
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.r),
          itemCount: growthRecords.length,
          itemBuilder: (context, index) {
            final record = growthRecords[index];
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8.h),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              child: ListTile(
                contentPadding: EdgeInsets.all(12.r),
                title: Text(
                  'Record ${index + 1}',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Date: ${record['date']}',
                  style: TextStyle(fontSize: 12.sp),
                ),
                trailing: ElevatedButton(
                  onPressed: () {
                    // تهيئة GrowthCubit بالطفل المختار
                    context.read<GrowthCubit>().initialize(
                          childId: childId,
                        );
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) => GrowthScreen2(
                          childId: childId,
                        ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  ),
                  child: Text('Details', style: TextStyle(fontSize: 12.sp)),
                ),
              ),
            );
          },
        );
      },
    );
  }
}