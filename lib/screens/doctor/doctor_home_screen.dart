import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/models/appointment_model.dart';
import 'package:segma/screens/doctor/DoctorSettingsScreen.dart';
import 'package:segma/screens/doctor/doctor_availability_screen.dart';
import 'package:segma/screens/doctor/history_doctor.dart';
import 'package:segma/services/doctor_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({Key? key}) : super(key: key);

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  late Future<Map<String, dynamic>> _upcomingAppointmentsFuture;
  int _selectedIndex = 2; // Home كافتراضي

  @override
  void initState() {
    super.initState();
    _upcomingAppointmentsFuture = DoctorService.getDoctorUpcomingAppointments();
  }

  void _refreshAppointments() {
    setState(() {
      _upcomingAppointmentsFuture = DoctorService.getDoctorUpcomingAppointments();
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0: // History
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AllHistoryScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
        break;
      case 1: // Schedule
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const DoctorAvailabilityScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
        break;
      case 2: // Home (الحالية)
        break;
      case 3: // Notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Notification screen is not implemented yet',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
        break;
      case 4: // Settings
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Doctor Home',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Theme.of(context).iconTheme.color,
            ),
            onPressed: () {
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) => const SettingsScreen(),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _upcomingAppointmentsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    snapshot.hasError
                        ? 'Error loading appointments: ${snapshot.error}'
                        : snapshot.data!['message'] ?? 'Error loading appointments',
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: _refreshAppointments,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text(
                      'Retry',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            );
          }

          final doctor = snapshot.data!['data']['doctor'];
          final List<dynamic> appointmentsData = snapshot.data!['data']['appointments'];
          final List<DoctorAppointment> appointments = appointmentsData
              .map((appointment) => DoctorAppointment.fromJson(appointment))
              .toList();

          return ListView(
            padding: EdgeInsets.all(16.w),
            children: [
              // Doctor Info Card
              Card(
                color: Theme.of(context).cardColor,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40.r,
                        backgroundImage: NetworkImage(doctor['avatar'] ?? 'https://example.com/default-avatar.jpg'),
                        onBackgroundImageError: (error, stackTrace) {
                          print('DoctorHomeScreen: Error loading doctor avatar: $error');
                        },
                        child: Icon(
                          Icons.person,
                          size: 40.r,
                          color: Theme.of(context).iconTheme.color,
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, Dr. ${doctor['name']?.split(' ').first ?? 'Doctor'}',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                  ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'You have ${doctor['upcomingCount'] ?? 0} appointments',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              // Appointments List
              if (appointments.isEmpty)
                Center(
                  child: Text(
                    'No upcoming appointments',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                )
              else
                ...appointments.map((appointment) {
                  return AppointmentCard(
                    appointment: appointment,
                    onStatusUpdate: _refreshAppointments,
                  );
                }).toList(),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onNavBarTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notification',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final DoctorAppointment appointment;
  final VoidCallback onStatusUpdate;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onStatusUpdate,
  }) : super(key: key);

  void _updateStatus(BuildContext context, String newStatus) async {
    try {
      final response = await DoctorService.updateAppointmentStatus(appointment.appointmentId, newStatus);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'],
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
        onStatusUpdate();
      } else {
        throw Exception('Failed to update status: ${response['message']}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error: $e',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onError,
                ),
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(appointment.date);
    final formattedDate = DateFormat('dd MMM, yyyy').format(date);
    final statusColor = appointment.status == 'Accepted'
        ? Colors.green
        : appointment.status == 'Closed'
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).disabledColor;

    return Card(
      color: Theme.of(context).cardColor,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Name: ${appointment.userName}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Child: ${appointment.childName}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14.sp,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            appointment.place,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 14.sp,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            formattedDate,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          SizedBox(width: 8.w),
                          Icon(
                            Icons.access_time,
                            size: 14.sp,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            appointment.time,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (appointment.status != 'PENDING')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      appointment.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
              ],
            ),
            if (appointment.status == 'PENDING') ...[
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () => _updateStatus(context, 'Accepted'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text(
                      'Taken',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _updateStatus(context, 'Closed'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                    ),
                    child: Text(
                      'Close',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onError,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}