import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/models/appointment_model.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/screens/doctor/DoctorSettingsScreen.dart';
import 'package:segma/screens/doctor/doctor_availability_screen.dart';
import 'package:segma/screens/doctor/history_doctor.dart';
import 'package:segma/screens/notifications_screen.dart';
import 'package:segma/services/doctor_service.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  _DoctorHomeScreenState createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen> {
  late Future<Map<String, dynamic>> _doctorProfileFuture;
  late Future<Map<String, dynamic>> _upcomingAppointmentsFuture;
  int _selectedIndex = 2; // Home كافتراضي

  final List<Widget> _screens = [
    const AllHistoryScreen(),
    const DoctorAvailabilityScreen(),
    const HomeScreenContent(),
    const NotificationsScreen(isDoctor: true),
    const SettingsScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _doctorProfileFuture = DoctorService.getDoctorProfile();
    _upcomingAppointmentsFuture = DoctorService.getDoctorUpcomingAppointments();
  }

  void _refreshData() {
    setState(() {
      _doctorProfileFuture = DoctorService.getDoctorProfile();
      _upcomingAppointmentsFuture = DoctorService.getDoctorUpcomingAppointments();
    });
  }

  void _onNavBarTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    print('DoctorHomeScreen: Building with selectedIndex: $_selectedIndex');
    return WillPopScope(
      onWillPop: () async {
        // Prevent back navigation to login screen
        if (_selectedIndex != 2) {
          _onNavBarTapped(2); // Return to Home screen instead of popping
          return false;
        }
        return false; // Prevent app from closing or navigating back further
      },
      child: Scaffold(
        appBar: _selectedIndex == 2
            ? AppBar(
                title: Text(
                  'Doctor Home',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
              )
            : null,
        body: IndexedStack(
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavBarTapped,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Schedule'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notification'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
    );
  }
}

class HomeScreenContent extends StatefulWidget {
  const HomeScreenContent({super.key});

  @override
  _HomeScreenContentState createState() => _HomeScreenContentState();
}

class _HomeScreenContentState extends State<HomeScreenContent> {
  late Future<Map<String, dynamic>> _doctorProfileFuture;
  late Future<Map<String, dynamic>> _upcomingAppointmentsFuture;

  @override
  void initState() {
    super.initState();
    _doctorProfileFuture = DoctorService.getDoctorProfile();
    _upcomingAppointmentsFuture = DoctorService.getDoctorUpcomingAppointments();
    print('HomeScreenContent: Initialized with futures');
  }

  void _refreshData() {
    setState(() {
      _doctorProfileFuture = DoctorService.getDoctorProfile();
      _upcomingAppointmentsFuture = DoctorService.getDoctorUpcomingAppointments();
    });
  }

  @override
  Widget build(BuildContext context) {
    print('HomeScreenContent: Building');
    return FutureBuilder<Map<String, dynamic>>(
      future: Future.wait([_doctorProfileFuture, _upcomingAppointmentsFuture]).then((results) {
        final doctorData = results[0];
        final appointmentsData = results[1];
        return {
          'doctor': Doctor.fromJson(doctorData['data']), // تحويل البيانات إلى كائن Doctor
          'appointments': appointmentsData['data'] as List, // المصفوفة المباشرة للحجوزات
          'totalAppointments': appointmentsData['totalAppointments'] as int? ?? 0, // استخراج العدد الصحيح
        };
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          print('HomeScreenContent: Waiting for data');
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          print('HomeScreenContent: Error - ${snapshot.error}');
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error loading data: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: _refreshData,
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

        final data = snapshot.data!;
        final doctor = data['doctor'] as Doctor;
        final List<dynamic> appointmentsData = data['appointments'] ?? [];
        final int totalAppointments = data['totalAppointments'] as int? ?? 0;
        final List<DoctorAppointment> appointments = appointmentsData
            .map((appointment) => DoctorAppointment.fromJson(appointment))
            .toList();

        print('HomeScreenContent: Data loaded - Total Appointments: $totalAppointments, Appointments Count: ${appointments.length}');

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
                      backgroundImage: NetworkImage(doctor.avatar ?? 'https://example.com/default-avatar.jpg'),
                      onBackgroundImageError: (error, stackTrace) {
                        print('DoctorHomeScreen: Error loading doctor avatar: $error');
                      },
                      child: const Icon(Icons.person),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, Dr. ${doctor.firstName}',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Theme.of(context).primaryColor,
                                ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'You have $totalAppointments appointments',
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
                  onStatusUpdate: _refreshData,
                );
              }),
          ],
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final DoctorAppointment appointment;
  final VoidCallback onStatusUpdate;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onStatusUpdate,
  });

  void _updateStatus(BuildContext context, String newStatus) async {
    try {
      print('AppointmentCard: Updating status to $newStatus for appointment ${appointment.appointmentId}');
      final response = await DoctorService.updateAppointmentStatus(appointment.appointmentId, newStatus);
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              response['message'] ?? 'Status updated successfully',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        );
        onStatusUpdate();
      } else {
        throw Exception('Failed to update status: ${response['message']}');
      }
    } catch (e) {
      print('AppointmentCard: Error updating status: $e');
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
    print('AppointmentCard: Building for appointment ${appointment.appointmentId}');
    final date = DateTime.parse(appointment.date);
    final formattedDate = DateFormat('dd MMM, yyyy').format(date);
    String placeText = appointment.visitType == 'In-Person' ? 'Home' : appointment.visitType;
    String address = appointment.visitType == 'In-Person' ? ', ${appointment.userAddress}' : '';

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
                            '$placeText$address',
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
                if (appointment.status != 'Pending') // استخدمنا 'Pending' بدلاً من 'PENDING' للتوافق
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: appointment.status == 'Accepted'
                          ? Colors.green
                          : appointment.status == 'Closed'
                              ? Theme.of(context).colorScheme.error
                              : Theme.of(context).disabledColor,
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
            if (appointment.status == 'Pending') ...[
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
                      'Refused',
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