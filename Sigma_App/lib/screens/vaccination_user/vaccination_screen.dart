
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';
// import 'package:segma/cubits/vaccination_cubit.dart';
// import 'package:segma/models/vaccination_model.dart';
// import 'package:segma/screens/vaccination_user/log_vaccination_screen.dart';
// import 'package:intl/intl.dart';

// class VaccinationScreen extends StatefulWidget {
//   const VaccinationScreen({super.key});

//   @override
//   State<VaccinationScreen> createState() => _VaccinationScreenState();
// }

// class _VaccinationScreenState extends State<VaccinationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     final childId = context.read<SelectedChildCubit>().state ?? '';
//     print('Selected Child ID in VaccinationScreen: $childId');
//     if (childId.isNotEmpty) {
//       context.read<VaccinationCubit>().fetchVaccinations(childId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Vaccinations',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         elevation: 0,
//       ),
//       body: BlocBuilder<VaccinationCubit, VaccinationState>(
//         builder: (context, state) {
//           if (state is VaccinationLoading) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: Theme.of(context).primaryColor,
//               ),
//             );
//           }

//           if (state is VaccinationError) {
//             return Center(
//               child: Text(
//                 state.message,
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
//               ),
//             );
//           }

//           if (state is VaccinationLoaded) {
//             final vaccinations = state.vaccinations;
//             if (vaccinations.isEmpty) {
//               return Center(
//                 child: Text(
//                   'No vaccination records found.',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
//                 ),
//               );
//             }

//             // تجميع التطعيمات حسب ageVaccine
//             Map<String, List<Vaccination>> groupedVaccinations = {};
//             for (var vaccination in vaccinations) {
//               final ageVaccine = vaccination.ageVaccine;
//               if (!groupedVaccinations.containsKey(ageVaccine)) {
//                 groupedVaccinations[ageVaccine] = [];
//               }
//               groupedVaccinations[ageVaccine]!.add(vaccination);
//             }

//             return ListView.builder(
//               padding: EdgeInsets.all(16.w),
//               itemCount: groupedVaccinations.keys.length,
//               itemBuilder: (context, index) {
//                 final ageVaccine = groupedVaccinations.keys.elementAt(index);
//                 final vaccines = groupedVaccinations[ageVaccine]!;

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       ageVaccine,
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
//                     ),
//                     SizedBox(height: 8.h),
//                     ...vaccines.map((vaccination) {
//                       // التحقق لو التطعيم متأخر بناءً على dueDate فقط
//                       bool isOverdue = DateTime.now().isAfter(vaccination.dueDate);

//                       // تحديد لون الـ status
//                       Color statusColor;
//                       if ((vaccination.status ?? 'Pending') == 'Taken') {
//                         statusColor = Colors.green;
//                       } else if ((vaccination.status ?? 'Pending') == 'Missed') {
//                         statusColor = Theme.of(context).colorScheme.error;
//                       } else {
//                         statusColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
//                       }

//                       // التحقق لو هنعرض "Mark Taken"
//                       bool showMarkTaken = (vaccination.status == 'Taken' || vaccination.status == 'Missed');

//                       return GestureDetector(
//                         onTap: () {
//                           // التحقق من الـ dueDate قبل فتح LogVaccinationScreen
//                           if (DateTime.now().isBefore(vaccination.dueDate)) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'You cannot log this vaccination yet. The due date (${DateFormat('d-MMM-yyyy').format(vaccination.dueDate)}) has not arrived.',
//                                 ),
//                               ),
//                             );
//                           } else {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => LogVaccinationScreen(
//                                   vaccination: vaccination,
//                                   childId: context.read<SelectedChildCubit>().state ?? '',
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         child: Container(
//                           margin: EdgeInsets.only(bottom: 12.h),
//                           padding: EdgeInsets.all(12.w),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).cardColor,
//                             borderRadius: BorderRadius.circular(8.r),
//                           ),
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       vaccination.disease,
//                                       style: Theme.of(context)
//                                           .textTheme
//                                           .bodyLarge
//                                           ?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
//                                     ),
//                                     SizedBox(height: 4.h),
//                                     Text(
//                                       vaccination.description,
//                                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
//                                     ),
//                                     SizedBox(height: 4.h),
//                                     Text(
//                                       'Due Date: ${DateFormat('d-MMM-yyyy').format(vaccination.dueDate)}',
//                                       style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
//                                     ),
//                                     SizedBox(height: 4.h),
//                                     Text(
//                                       isOverdue ? 'Overdue' : (vaccination.status ?? 'Pending'),
//                                       style: TextStyle(
//                                         color: isOverdue ? Theme.of(context).colorScheme.error : statusColor,
//                                         fontSize: 14.sp,
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                     if (showMarkTaken) ...[
//                                       SizedBox(height: 4.h),
//                                       Text(
//                                         'Mark Taken',
//                                         style: TextStyle(
//                                           color: Colors.green,
//                                           fontSize: 14.sp,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                     ],
//                                   ],
//                                 ),
//                               ),
//                               Icon(
//                                 Icons.arrow_forward_ios,
//                                 size: 16.sp,
//                                 color: Theme.of(context).iconTheme.color,
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                     SizedBox(height: 16.h),
//                   ],
//                 );
//               },
//             );
//           }

//           return Center(
//             child: Text(
//               'Please select a child to view vaccinations.',
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';
// import 'package:segma/cubits/vaccination_cubit.dart';
// import 'package:segma/models/vaccination_model.dart';
// import 'package:segma/screens/vaccination_user/log_vaccination_screen.dart';
// import 'package:intl/intl.dart';

// class VaccinationScreen extends StatefulWidget {
//   const VaccinationScreen({super.key});

//   @override
//   State<VaccinationScreen> createState() => _VaccinationScreenState();
// }

// class _VaccinationScreenState extends State<VaccinationScreen> {
//   @override
//   void initState() {
//     super.initState();
//     final childId = context.read<SelectedChildCubit>().state ?? '';
//     print('Selected Child ID in VaccinationScreen: $childId');
//     if (childId.isNotEmpty) {
//       context.read<VaccinationCubit>().fetchVaccinations(childId);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Vaccinations',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         elevation: 0,
//       ),
//       body: BlocBuilder<VaccinationCubit, VaccinationState>(
//         builder: (context, state) {
//           if (state is VaccinationLoading) {
//             return Center(
//               child: CircularProgressIndicator(
//                 color: Theme.of(context).primaryColor,
//               ),
//             );
//           }

//           if (state is VaccinationError) {
//             return Center(
//               child: Text(
//                 state.message,
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
//               ),
//             );
//           }

//           if (state is VaccinationLoaded) {
//             final vaccinations = state.vaccinations;
//             if (vaccinations.isEmpty) {
//               return Center(
//                 child: Text(
//                   'No vaccination records found.',
//                   style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
//                 ),
//               );
//             }

//             Map<String, List<Vaccination>> groupedVaccinations = {};
//             for (var vaccination in vaccinations) {
//               final ageVaccine = vaccination.ageVaccine;
//               if (!groupedVaccinations.containsKey(ageVaccine)) {
//                 groupedVaccinations[ageVaccine] = [];
//               }
//               groupedVaccinations[ageVaccine]!.add(vaccination);
//             }

//             return ListView.builder(
//               padding: EdgeInsets.all(16.w),
//               itemCount: groupedVaccinations.keys.length,
//               itemBuilder: (context, index) {
//                 final ageVaccine = groupedVaccinations.keys.elementAt(index);
//                 final vaccines = groupedVaccinations[ageVaccine]!;

//                 return Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       ageVaccine,
//                       style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
//                     ),
//                     SizedBox(height: 8.h),
//                     ...vaccines.map((vaccination) {
//                       bool isOverdue = DateTime.now().isAfter(vaccination.dueDate);

//                       Color statusColor;
//                       if ((vaccination.status ?? 'Pending') == 'Taken') {
//                         statusColor = Colors.green;
//                       } else if ((vaccination.status ?? 'Pending') == 'Missed') {
//                         statusColor = Theme.of(context).colorScheme.error;
//                       } else {
//                         statusColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
//                       }

//                       bool showMarkTaken = (vaccination.status == 'Taken' || vaccination.status == 'Missed');

//                       return GestureDetector(
//                         onTap: () {
//                           if (DateTime.now().isBefore(vaccination.dueDate)) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(
//                                 content: Text(
//                                   'You cannot log this vaccination yet. The due date (${DateFormat('d-MMM-yyyy').format(vaccination.dueDate)}) has not arrived.',
//                                 ),
//                               ),
//                             );
//                           } else {
//                             Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                 builder: (context) => LogVaccinationScreen(
//                                   vaccination: vaccination,
//                                   childId: context.read<SelectedChildCubit>().state ?? '',
//                                 ),
//                               ),
//                             );
//                           }
//                         },
//                         child: Container(
//                           margin: EdgeInsets.only(bottom: 12.h),
//                           padding: EdgeInsets.all(12.w),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context).cardColor,
//                             borderRadius: BorderRadius.circular(8.r),
//                           ),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               if (vaccination.status != null)
//                                 Container(
//                                   padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
//                                   decoration: BoxDecoration(
//                                     color: vaccination.status == 'Pending'
//                                         ? Colors.orange
//                                         : vaccination.status == 'Missed'
//                                             ? Colors.red
//                                             : Colors.green,
//                                     borderRadius: BorderRadius.circular(12.r),
//                                     boxShadow: [
//                                       BoxShadow(
//                                         color: Colors.black12,
//                                         blurRadius: 4,
//                                         offset: Offset(0, 2),
//                                       ),
//                                     ],
//                                   ),
//                                   child: Text(
//                                     vaccination.status!,
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 12.sp,
//                                       fontWeight: FontWeight.bold,
//                                     ),
//                                   ),
//                                 ),
//                               SizedBox(height: 8.h),
//                               Row(
//                                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           vaccination.disease,
//                                           style: Theme.of(context)
//                                               .textTheme
//                                               .bodyLarge
//                                               ?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Text(
//                                           vaccination.description,
//                                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Text(
//                                           'Due Date: ${DateFormat('d-MMM-yyyy').format(vaccination.dueDate)}',
//                                           style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
//                                         ),
//                                         SizedBox(height: 4.h),
//                                         Text(
//                                           isOverdue ?
//                                           'Overdue'
//                                            : (vaccination.status ?? ''),
//                                           style: TextStyle(
//                                             color: isOverdue ? Theme.of(context).colorScheme.error : statusColor,
//                                             fontSize: 14.sp,
//                                             fontWeight: FontWeight.bold,
//                                           ),
//                                         ),
//                                         // if (showMarkTaken) ...[
//                                         //   SizedBox(height: 4.h),
//                                         //   Text(
//                                         //     'Mark Taken',
//                                         //     style: TextStyle(
//                                         //       color: Colors.green,
//                                         //       fontSize: 14.sp,
//                                         //       fontWeight: FontWeight.bold,
//                                         //     ),
//                                         //   ),
//                                         // ],
//                                       ],
//                                     ),
//                                   ),
//                                   Icon(
//                                     Icons.arrow_forward_ios,
//                                     size: 16.sp,
//                                     color: Theme.of(context).iconTheme.color,
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       );
//                     }),
//                     SizedBox(height: 16.h),
//                   ],
//                 );
//               },
//             );
//           }

//           return Center(
//             child: Text(
//               'Please select a child to view vaccinations.',
//               style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }



import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/vaccination_cubit.dart';
import 'package:segma/models/vaccination_model.dart';
import 'package:segma/screens/vaccination_user/log_vaccination_screen.dart';
import 'package:intl/intl.dart';

class VaccinationScreen extends StatefulWidget {
  const VaccinationScreen({super.key});

  @override
  State<VaccinationScreen> createState() => _VaccinationScreenState();
}

class _VaccinationScreenState extends State<VaccinationScreen> {
  @override
  void initState() {
    super.initState();
    final childId = context.read<SelectedChildCubit>().state ?? '';
    print('Selected Child ID in VaccinationScreen: $childId');
    if (childId.isNotEmpty) {
      context.read<VaccinationCubit>().fetchVaccinations(childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Vaccinations',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: BlocBuilder<VaccinationCubit, VaccinationState>(
        builder: (context, state) {
          if (state is VaccinationLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }

          if (state is VaccinationError) {
            return Center(
              child: Text(
                state.message,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
              ),
            );
          }

          if (state is VaccinationLoaded) {
            final vaccinations = state.vaccinations;
            if (vaccinations.isEmpty) {
              return Center(
                child: Text(
                  'No vaccination records found.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
                ),
              );
            }

            Map<String, List<Vaccination>> groupedVaccinations = {};
            for (var vaccination in vaccinations) {
              final ageVaccine = vaccination.ageVaccine;
              if (!groupedVaccinations.containsKey(ageVaccine)) {
                groupedVaccinations[ageVaccine] = [];
              }
              groupedVaccinations[ageVaccine]!.add(vaccination);
            }

            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: groupedVaccinations.keys.length,
              itemBuilder: (context, index) {
                final ageVaccine = groupedVaccinations.keys.elementAt(index);
                final vaccines = groupedVaccinations[ageVaccine]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ageVaccine,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp),
                    ),
                    SizedBox(height: 8.h),
                    ...vaccines.map((vaccination) {
                      bool isOverdue = DateTime.now().isAfter(vaccination.dueDate);

                      bool showMarkTaken = (vaccination.status == 'Taken' || vaccination.status == 'Missed');

                      return GestureDetector(
                        onTap: () {
                          if (DateTime.now().isBefore(vaccination.dueDate)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'You cannot log this vaccination yet. The due date (${DateFormat('d-MMM-yyyy').format(vaccination.dueDate)}) has not arrived.',
                                ),
                              ),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LogVaccinationScreen(
                                  vaccination: vaccination,
                                  childId: context.read<SelectedChildCubit>().state ?? '',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12.h),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      vaccination.disease,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      vaccination.description,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Due Date: ${DateFormat('d-MMM-yyyy').format(vaccination.dueDate)}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                                    ),
                                    if (isOverdue) ...[
                                      SizedBox(height: 4.h),
                                      Text(
                                        'Overdue',
                                        style: TextStyle(
                                          color: Theme.of(context).colorScheme.error,
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                    // if (showMarkTaken) ...[
                                    //   SizedBox(height: 4.h),
                                    //   Text(
                                    //     'Mark Taken',
                                    //     style: TextStyle(
                                    //       color: Colors.green,
                                    //       fontSize: 14.sp,
                                    //       fontWeight: FontWeight.bold,
                                    //     ),
                                    //   ),
                                    // ],
                                  ],
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    size: 16.sp,
                                    color: Theme.of(context).iconTheme.color,
                                  ),
                                  if (vaccination.status != null) ...[
                                    SizedBox(height: 16.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                      decoration: BoxDecoration(
                                        color: vaccination.status == 'Pending'
                                            ? Colors.orange
                                            : vaccination.status == 'Missed'
                                                ? Colors.red
                                                : Colors.green,
                                        borderRadius: BorderRadius.circular(12.r),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black12,
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        vaccination.status!,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    SizedBox(height: 16.h),
                  ],
                );
              },
            );
          }

          return Center(
            child: Text(
              'Please select a child to view vaccinations.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 18.sp),
            ),
          );
        },
      ),
    );
  }
}
