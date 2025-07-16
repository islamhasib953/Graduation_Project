// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:segma/cubits/notification_cubit.dart';
// import 'package:segma/cubits/notification_state.dart';
// import 'package:segma/models/notification.dart';
// import 'package:segma/utils/themes.dart';
// import 'package:segma/utils/colors.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';
// import 'package:segma/services/auth_service.dart';
// import 'package:segma/screens/doctor/doctor_home_screen.dart';
// import 'package:segma/screens/doctor_user/appointments_screen.dart';

// // Placeholder for MedicineScreen (you should define this class)
// class MedicineScreen extends StatelessWidget {
//   final String childId;
//   const MedicineScreen({Key? key, required this.childId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Medicine')),
//       body: Center(child: Text('Medicine Screen for Child ID: $childId')),
//     );
//   }
// }

// // Placeholder for BraceletScreen (you should define this class)
// class BraceletScreen extends StatelessWidget {
//   final String childId;
//   const BraceletScreen({Key? key, required this.childId}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Bracelet')),
//       body: Center(child: Text('Bracelet Screen for Child ID: $childId')),
//     );
//   }
// }

// // Placeholder for CommunityScreen (you should define this class)
// class CommunityScreen extends StatelessWidget {
//   const CommunityScreen({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Community')),
//       body: const Center(child: Text('Community Screen')),
//     );
//   }
// }

// class NotificationsScreen extends StatefulWidget {
//   const NotificationsScreen({Key? key}) : super(key: key);

//   @override
//   _NotificationsScreenState createState() => _NotificationsScreenState();
// }

// class _NotificationsScreenState extends State<NotificationsScreen> {
//   String _selectedFilter = 'All';
//   String? _role;

//   @override
//   void initState() {
//     super.initState();
//     _loadRoleAndFetchNotifications();
//   }

//   Future<void> _loadRoleAndFetchNotifications() async {
//     try {
//       final userData = await AuthService.getUserData();
//       setState(() {
//         _role = userData['role']?.toLowerCase();
//       });
//       print('🔍 User Role: $_role');
//       if (_role == 'patient') {
//         final childId = context.read<SelectedChildCubit>().state;
//         if (childId != null && childId.isNotEmpty) {
//           context.read<NotificationCubit>().fetchNotifications(role: _role!, childId: childId);
//         } else {
//           print('⚠️ No child selected for patient notifications');
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Please select a child to view notifications')),
//           );
//         }
//       } else if (_role == 'doctor') {
//         context.read<NotificationCubit>().fetchNotifications(role: _role!);
//       } else {
//         print('⚠️ Invalid or missing role');
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('User role not found. Please log in again.')),
//         );
//         Navigator.pushReplacementNamed(context, '/login');
//       }
//     } catch (e) {
//       print('🔥 Error loading role: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error loading notifications: $e')),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         title: Text(
//           'Notifications',
//           style: TextStyle(color: Theme.of(context).primaryColor),
//         ),
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           _buildFilterButtons(),
//           Expanded(
//             child: BlocBuilder<NotificationCubit, NotificationState>(
//               builder: (context, state) {
//                 if (state is NotificationLoading) {
//                   return Center(
//                     child: CircularProgressIndicator(
//                       valueColor: AlwaysStoppedAnimation<Color>(
//                         Theme.of(context).primaryColor,
//                       ),
//                     ),
//                   );
//                 } else if (state is NotificationLoaded) {
//                   final notifications = _filterNotifications(state.notifications);
//                   if (notifications.isEmpty) {
//                     return Center(
//                       child: Text(
//                         'No notifications available',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           color: Theme.of(context).textTheme.bodyMedium?.color,
//                         ),
//                       ),
//                     );
//                   }
//                   return ListView.builder(
//                     padding: EdgeInsets.all(16.w),
//                     itemCount: notifications.length,
//                     itemBuilder: (context, index) {
//                       final notification = notifications[index];
//                       return _buildNotificationCard(notification);
//                     },
//                   );
//                 } else if (state is NotificationError) {
//                   return Center(
//                     child: Text(
//                       state.message,
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         color: AppColors.statusOverdue,
//                       ),
//                     ),
//                   );
//                 }
//                 return Center(
//                   child: Text(
//                     _role == 'patient' ? 'Please select a child to view notifications' : 'No notifications available',
//                     style: TextStyle(
//                       fontSize: 16.sp,
//                       color: Theme.of(context).textTheme.bodyMedium?.color,
//                     ),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterButtons() {
//     return Container(
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//       color: Theme.of(context).appBarTheme.backgroundColor,
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildFilterButton('All'),
//           _buildFilterButton('Bracelet'),
//           _buildFilterButton('Community'),
//           _buildFilterButton('Doctors'),
//           _buildFilterButton('Medicine'),
//         ],
//       ),
//     );
//   }

//   Widget _buildFilterButton(String filter) {
//     bool isSelected = _selectedFilter == filter;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedFilter = filter;
//         });
//       },
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? Theme.of(context).primaryColor
//               : Theme.of(context).inputDecorationTheme.fillColor,
//           borderRadius: BorderRadius.circular(20.r),
//         ),
//         child: Text(
//           filter,
//           style: TextStyle(
//             color: isSelected
//                 ? Colors.white
//                 : Theme.of(context).textTheme.bodyMedium?.color,
//             fontSize: 14.sp,
//             fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ),
//     );
//   }

//   List<NotificationModel> _filterNotifications(List<NotificationModel> notifications) {
//     if (_selectedFilter == 'All') {
//       return notifications;
//     }
//     return notifications.where((notification) {
//       return notification.type.toLowerCase() == _selectedFilter.toLowerCase();
//     }).toList();
//   }

//   Widget _buildNotificationCard(NotificationModel notification) {
//     final isDarkMode = Theme.of(context).brightness == Brightness.dark;
//     return Card(
//       elevation: 4,
//       margin: EdgeInsets.symmetric(vertical: 8.h),
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: ListTile(
//         contentPadding: EdgeInsets.all(16.w),
//         leading: CircleAvatar(
//           backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
//           child: Icon(
//             _getNotificationIcon(notification.type),
//             color: Theme.of(context).primaryColor,
//             size: 24.sp,
//           ),
//         ),
//         title: Text(
//           notification.title,
//           style: TextStyle(
//             fontSize: 16.sp,
//             fontWeight: FontWeight.bold,
//             color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
//           ),
//         ),
//         subtitle: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(height: 5.h),
//             Text(
//               notification.body,
//               style: TextStyle(
//                 fontSize: 14.sp,
//                 color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
//               ),
//             ),
//             SizedBox(height: 5.h),
//             Text(
//               DateFormat('d-MMM-yyyy HH:mm').format(notification.timestamp),
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
//               ),
//             ),
//             if (notification.status != null) ...[
//               SizedBox(height: 5.h),
//               Text(
//                 'Status: ${notification.status}',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: notification.status == 'Accepted'
//                       ? Colors.green
//                       : notification.status == 'Cancelled'
//                           ? AppColors.statusOverdue
//                           : Colors.orange,
//                 ),
//               ),
//             ],
//           ],
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (!notification.isRead)
//               Container(
//                 width: 10.w,
//                 height: 10.h,
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).primaryColor,
//                   shape: BoxShape.circle,
//                 ),
//               ),
//             SizedBox(width: 8.w),
//             TextButton(
//               onPressed: () {
//                 if (!notification.isRead) {
//                   context.read<NotificationCubit>().markAsRead(notification.id);
//                 }
//                 _navigateToDetails(notification);
//               },
//               child: Text(
//                 'View Details',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Theme.of(context).primaryColor,
//                 ),
//               ),
//             ),
//           ],
//         ),
//         onTap: () {
//           if (!notification.isRead) {
//             context.read<NotificationCubit>().markAsRead(notification.id);
//           }
//           _navigateToDetails(notification);
//         },
//       ),
//     );
//   }

//   IconData _getNotificationIcon(String type) {
//     switch (type.toLowerCase()) {
//       case 'bracelet':
//         return Icons.watch;
//       case 'community':
//         return Icons.group;
//       case 'doctors':
//         return Icons.medical_services;
//       case 'medicine':
//         return Icons.medication;
//       default:
//         return Icons.notifications;
//     }
//   }

//   void _navigateToDetails(NotificationModel notification) {
//     final childId = context.read<SelectedChildCubit>().state;

//     switch (notification.type.toLowerCase()) {
//       case 'medicine':
//         if (childId != null && childId.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => MedicineScreen(childId: childId)),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Please select a child to view this notification')),
//           );
//         }
//         break;
//       case 'doctors':
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => _role == 'doctor' ? const DoctorHomeScreen() : const AppointmentsScreen(),
//           ),
//         );
//         break;
//       case 'bracelet':
//         if (childId != null && childId.isNotEmpty) {
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => BraceletScreen(childId: childId)),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Please select a child to view this notification')),
//           );
//         }
//         break;
//       case 'community':
//         Navigator.push(
//           context,
//           MaterialPageRoute(builder: (context) => const CommunityScreen()),
//         );
//         break;
//       default:
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('No navigation defined for this notification type')),
//         );
//     }
//   }
// }

import 'package:flutter/material.dart' hide Notification; // إخفاء Notification من flutter/material.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/notification_cubit.dart';
import 'package:segma/cubits/notification_state.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/selected_doctor_cubit.dart';
import 'package:segma/models/notification.model.dart';
import 'package:intl/intl.dart';

class NotificationsScreen extends StatefulWidget {
  final bool isDoctor;

  const NotificationsScreen({super.key, this.isDoctor = false});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  void _fetchNotifications() {
    if (!widget.isDoctor) {
      final childId = context.read<SelectedChildCubit>().state;
      if (childId != null && childId.isNotEmpty) {
        context.read<NotificationCubit>().fetchNotifications(childId, isDoctor: widget.isDoctor);
      }
    } else {
      final doctorId = context.read<SelectedDoctorCubit>().state;
      context.read<NotificationCubit>().fetchNotifications(doctorId ?? '', isDoctor: widget.isDoctor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectedChildCubit, String?>(
      listener: (context, childId) {
        if (!widget.isDoctor && childId != null && childId.isNotEmpty) {
          context.read<NotificationCubit>().fetchNotifications(childId, isDoctor: widget.isDoctor);
        }
      },
      child: BlocListener<SelectedDoctorCubit, String?>(
        listener: (context, doctorId) {
          if (widget.isDoctor && doctorId != null) {
            context.read<NotificationCubit>().fetchNotifications(doctorId, isDoctor: widget.isDoctor);
          }
        },
        child: BlocBuilder<SelectedChildCubit, String?>(
          builder: (context, childId) {
            if (!widget.isDoctor && (childId == null || childId.isEmpty)) {
              return Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                  elevation: 0,
                  title: Text(
                    'Notifications',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                body: Center(
                  child: Text(
                    'Please select a child to view notifications.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
                title: Text(
                  'Notifications',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              body: BlocBuilder<NotificationCubit, NotificationState>(
                builder: (context, state) {
                  if (state is NotificationLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is NotificationError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            state.error ?? 'An error occurred',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16.h),
                          ElevatedButton(
                            onPressed: _fetchNotifications,
                            child: Text(
                              'Retry',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  List<Notification> notifications = [];
                  if (state is NotificationLoaded) {
                    notifications = state.notifications;
                  } else if (state is NotificationReadUpdated) {
                    notifications = state.notifications;
                  }

                  if (notifications.isEmpty) {
                    return Center(
                      child: Text(
                        'No notifications found.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                    physics: const BouncingScrollPhysics(),
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final notification = notifications[index];
                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        margin: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Theme.of(context).cardColor,
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.all(16.r),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notification.title,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(context).primaryColor,
                                          ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      notification.body,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Theme.of(context).brightness == Brightness.dark
                                                ? Colors.white70
                                                : Colors.black87,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 8.h),
                                    Text(
                                      DateFormat('MMM d, yyyy – HH:mm').format(notification.createdAt),
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              if (!notification.isRead)
                                IconButton(
                                  icon: Icon(
                                    Icons.mark_chat_read,
                                    color: Theme.of(context).primaryColor,
                                    size: 20.sp,
                                  ),
                                  onPressed: () {
                                    final id = widget.isDoctor
                                        ? context.read<SelectedDoctorCubit>().state ?? ''
                                        : childId ?? '';
                                    context.read<NotificationCubit>().markAsRead(
                                          notification.id,
                                          id,
                                          isDoctor: widget.isDoctor,
                                        );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}