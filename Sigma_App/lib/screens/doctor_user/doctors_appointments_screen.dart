import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/selected_doctor_cubit.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/models/appointment_model.dart';
import 'package:segma/screens/doctor_user/cancel_dialog.dart';
import 'package:segma/screens/doctor_user/doctor_details_screen.dart';
import 'package:segma/services/doctor_service.dart';

class DoctorsAppointmentsScreen extends StatefulWidget {
  const DoctorsAppointmentsScreen({super.key});

  @override
  _DoctorsAppointmentsScreenState createState() => _DoctorsAppointmentsScreenState();
}

class _DoctorsAppointmentsScreenState extends State<DoctorsAppointmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    print('DoctorsAppointmentsScreen: Initializing TabController');
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    print('DoctorsAppointmentsScreen: Disposing TabController');
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DoctorsAppointmentsScreen: Building UI');
    return BlocBuilder<SelectedChildCubit, String?>(
      builder: (context, childId) {
        print('DoctorsAppointmentsScreen: SelectedChildCubit state - childId: $childId');
        if (childId == null) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: Center(
              child: Text(
                'Please select a child',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text(
              'Doctors',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
            ),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Top Doctors'),
                Tab(text: 'Appointments'),
              ],
              indicatorColor: Theme.of(context).colorScheme.primary,
              labelColor: Theme.of(context).colorScheme.onSurface,
              unselectedLabelColor: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildDoctorsList(childId),
              _buildAppointmentsList(childId),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDoctorsList(String childId) {
    print('DoctorsAppointmentsScreen: Building doctors list for childId: $childId');
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: DoctorService.getDoctors(childId),
        builder: (context, snapshot) {
          print('DoctorsAppointmentsScreen: FutureBuilder state for doctors list - connectionState: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }
          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            print('DoctorsAppointmentsScreen: Error loading doctors: $error');
            if (error.contains('Authentication token is missing')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Please log in to view doctors.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16.sp,
                          ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        print('DoctorsAppointmentsScreen: Navigating to login screen');
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text('Log In', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp)),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading doctors: $error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      print('DoctorsAppointmentsScreen: Retry button pressed for doctors list');
                      setState(() {});
                    },
                    child: Text('Retry', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp)),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            print('DoctorsAppointmentsScreen: No data returned for doctors list');
            return Center(
              child: Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
              ),
            );
          }
          final response = snapshot.data!;
          if (response['status'] != 'success') {
            print('DoctorsAppointmentsScreen: Failed to load doctors - Response: $response');
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    response['message'] ?? 'No doctors found',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      print('DoctorsAppointmentsScreen: Retry button pressed for doctors list');
                      setState(() {});
                    },
                    child: Text('Retry', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp)),
                  ),
                ],
              ),
            );
          }
          final dynamic data = response['data'];
          List<Doctor> doctors = [];
          if (data is List) {
            doctors = data.map((doctor) => Doctor.fromJson(doctor)).toList();
          } else if (data is Map) {
            final List<dynamic>? doctorList = data['doctors'] ?? data['data'];
            if (doctorList != null) {
              doctors = doctorList.map((doctor) => Doctor.fromJson(doctor)).toList();
            }
          }
          print('DoctorsAppointmentsScreen: Loaded ${doctors.length} doctors');
          if (doctors.isEmpty) {
            return Center(
              child: Text(
                'No doctors found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
              ),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              final firstName = doctor.firstName ?? '';
              final lastName = doctor.lastName ?? '';
              final fullName = '$firstName $lastName'.trim();
              print('DoctorsAppointmentsScreen: Doctor $index - firstName: $firstName, lastName: $lastName, fullName: $fullName');
              return Builder(
                builder: (BuildContext context) {
                  return _DoctorCard(
                    name: fullName.isEmpty ? 'Unknown Doctor' : fullName,
                    specialty: doctor.specialise ?? 'Unknown Specialty',
                    distance: doctor.address ?? 'Unknown Address',
                    rating: doctor.rate ?? 0.0,
                    isOpen: doctor.status == 'Open',
                    onTap: () {
                      print('DoctorsAppointmentsScreen: Tapped on doctor: ${doctor.id} - $fullName');
                      print('DoctorsAppointmentsScreen: Doctor details - Specialty: ${doctor.specialise ?? 'Unknown'}, Address: ${doctor.address ?? 'Unknown'}, Rating: ${doctor.rate ?? 0.0}, Status: ${doctor.status ?? 'Unknown'}');
                      context.read<SelectedDoctorCubit>().selectDoctor(doctor.id);
                      print('DoctorsAppointmentsScreen: SelectedDoctorCubit updated with doctorId: ${doctor.id}');
                      try {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailsScreen(doctorId: doctor.id),
                          ),
                        ).then((_) {
                          // Refresh appointments list after returning from booking
                          setState(() {});
                        });
                        print('DoctorsAppointmentsScreen: Navigated to DoctorDetailsScreen for doctor: ${doctor.id}');
                      } catch (e) {
                        print('DoctorsAppointmentsScreen: Navigation error: $e');
                      }
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildAppointmentsList(String childId) {
    print('DoctorsAppointmentsScreen: Building appointments list for childId: $childId');
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: FutureBuilder<Map<String, dynamic>>(
        future: DoctorService.getUserAppointments(childId),
        builder: (context, snapshot) {
          print('DoctorsAppointmentsScreen: FutureBuilder state for appointments list - connectionState: ${snapshot.connectionState}');
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          }
          if (snapshot.hasError) {
            final error = snapshot.error.toString();
            print('DoctorsAppointmentsScreen: Error loading appointments: $error');
            if (error.contains('Authentication token is missing')) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Please log in to view appointments.',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16.sp,
                          ),
                    ),
                    SizedBox(height: 16.h),
                    ElevatedButton(
                      onPressed: () {
                        print('DoctorsAppointmentsScreen: Navigating to login screen');
                        Navigator.pushNamed(context, '/login');
                      },
                      child: Text('Log In', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp)),
                    ),
                  ],
                ),
              );
            }
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Error loading appointments: $error',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontSize: 14.sp,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      print('DoctorsAppointmentsScreen: Retry button pressed for appointments list');
                      setState(() {});
                    },
                    child: Text('Retry', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 18.sp)),
                  ),
                ],
              ),
            );
          }
          if (!snapshot.hasData) {
            print('DoctorsAppointmentsScreen: No data returned for appointments list');
            return Center(
              child: Text(
                'No data available',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
              ),
            );
          }
          final response = snapshot.data!;
          if (response['status'] != 'success') {
            print('DoctorsAppointmentsScreen: Failed to load appointments - Response: $response');
            return Center(
              child: Text(
                response['message'] ?? 'No appointments found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
              ),
            );
          }
          final dynamic data = response['data'];
          List<UserAppointment> appointmentsList = [];
          if (data is List) {
            appointmentsList = data.map((appointment) => UserAppointment.fromJson(appointment)).toList();
          } else if (data is Map && data.containsKey('appointment')) {
            final appointmentData = data['appointment'];
            if (appointmentData != null) {
              print('DoctorsAppointmentsScreen: Raw appointment data: $appointmentData'); // Debug print
              appointmentsList.add(UserAppointment.fromJson(appointmentData));
            } else {
              print('DoctorsAppointmentsScreen: No appointment data found in response');
            }
          }
          print('DoctorsAppointmentsScreen: Loaded ${appointmentsList.length} appointments');
          if (appointmentsList.isEmpty) {
            return Center(
              child: Text(
                'No appointments found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontSize: 16.sp,
                    ),
              ),
            );
          }
          final Map<String, List<UserAppointment>> appointmentsByMonth = {};
          for (var appointment in appointmentsList) {
            final date = DateTime.parse(appointment.date!); // Ensure date is not null
            final month = DateFormat('MMMM yyyy').format(date);
            if (!appointmentsByMonth.containsKey(month)) {
              appointmentsByMonth[month] = [];
            }
            appointmentsByMonth[month]!.add(appointment);
          }
          print('DoctorsAppointmentsScreen: Grouped appointments into ${appointmentsByMonth.length} months');
          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: appointmentsByMonth.length,
            itemBuilder: (context, index) {
              final month = appointmentsByMonth.keys.elementAt(index);
              final appointments = appointmentsByMonth[month]!;
              print('DoctorsAppointmentsScreen: Building appointments for month: $month');
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      month,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurface,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...appointments.map((appointment) {
                    final doctorName = appointment.doctorName ?? 'Unknown Doctor';
                    print('DoctorsAppointmentsScreen: Appointment ${appointment.appointmentId} - doctorName: $doctorName');
                    return Builder(
                      builder: (BuildContext context) {
                        return _AppointmentCard(
                          appointment: appointment,
                          onCancel: () {
                            print('DoctorsAppointmentsScreen: Tapped on cancel for appointment: ${appointment.appointmentId}');
                            print('DoctorsAppointmentsScreen: Appointment details - Doctor: $doctorName, Date: ${appointment.date}, Time: ${appointment.time}, Status: ${appointment.status}');
                            showDialog(
                              context: context,
                              builder: (context) => CancelDialog(
                                onConfirm: () async {
                                  try {
                                    print('DoctorsAppointmentsScreen: Confirming cancellation for appointment: ${appointment.appointmentId}');
                                    await DoctorService.cancelAppointment(childId, appointment.appointmentId!);
                                    print('DoctorsAppointmentsScreen: Appointment cancelled successfully');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text('Appointment cancelled successfully'),
                                        backgroundColor: Theme.of(context).colorScheme.secondary,
                                      ),
                                    );
                                    Navigator.pop(context);
                                    setState(() {});
                                  } catch (e) {
                                    print('DoctorsAppointmentsScreen: Error cancelling appointment: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: $e'),
                                        backgroundColor: Theme.of(context).colorScheme.error,
                                      ),
                                    );
                                  }
                                },
                              ),
                            );
                          },
                          onReschedule: () {
                            print('DoctorsAppointmentsScreen: Tapped on reschedule for appointment: ${appointment.appointmentId}');
                            print('DoctorsAppointmentsScreen: Appointment details - Doctor: $doctorName, Date: ${appointment.date}, Time: ${appointment.time}, Status: ${appointment.status}');
                            context.read<SelectedDoctorCubit>().selectDoctor(appointment.doctorId!);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailsScreen(
                                  doctorId: appointment.doctorId!,
                                  appointmentId: appointment.appointmentId,
                                  previousDate: appointment.date,
                                  previousTime: appointment.time,
                                ),
                              ),
                            ).then((_) {
                              // Refresh appointments list after rescheduling
                              setState(() {});
                            });
                            print('DoctorsAppointmentsScreen: Navigated to DoctorDetailsScreen for rescheduling appointment: ${appointment.appointmentId}');
                          },
                        );
                      },
                    );
                  }),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final String name;
  final String specialty;
  final String distance;
  final double rating;
  final bool isOpen;
  final VoidCallback onTap;

  const _DoctorCard({
    super.key,
    required this.name,
    required this.specialty,
    required this.distance,
    required this.rating,
    required this.isOpen,
    required this.onTap,
  });

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String truncateToMaxLength(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    print('DoctorsAppointmentsScreen: Building _DoctorCard for doctor: ${widget.name}');
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: () {
            print('DoctorsAppointmentsScreen: InkWell onTap triggered for doctor: ${widget.name}');
            widget.onTap();
          },
          child: Card(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.symmetric(vertical: 10.h),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade700 : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 30.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truncateToMaxLength(widget.name, 15),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.black,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          truncateToMaxLength(widget.specialty, 15),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 14.sp,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                truncateToMaxLength(widget.distance, 15),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                      fontSize: 14.sp,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.star,
                              color: Theme.of(context).colorScheme.secondary,
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              widget.rating.toStringAsFixed(1),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 14.sp,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: widget.isOpen
                          ? Theme.of(context).colorScheme.secondary.withOpacity(0.9)
                          : Theme.of(context).colorScheme.error.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.isOpen ? 'Open' : 'Closed',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: widget.isOpen ? Theme.of(context).colorScheme.onSecondary : Theme.of(context).colorScheme.onError,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatefulWidget {
  final UserAppointment appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const _AppointmentCard({
    super.key,
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  _AppointmentCardState createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<_AppointmentCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String truncateToMaxLength(String text, int maxLength) {
    if (text.length <= maxLength) {
      return text;
    }
    return '${text.substring(0, maxLength)}...';
  }

  @override
  Widget build(BuildContext context) {
    print('DoctorsAppointmentsScreen: Building _AppointmentCard for appointment: ${widget.appointment.appointmentId}');
    final doctorName = widget.appointment.doctorName ?? 'Unknown Doctor';
    final formattedDate = truncateToMaxLength(DateFormat('EEEE, d MMM yyyy').format(DateTime.parse(widget.appointment.date!)), 20);
    final time = truncateToMaxLength(widget.appointment.time ?? 'Unknown Time', 10);

    // Determine container background color based on status
    Color containerColor;
    switch (widget.appointment.status?.toLowerCase()) {
      case 'confirmed':
      case 'accepted':
        containerColor = Colors.green.withOpacity(0.9);
        break;
      case 'pending':
        containerColor = const Color.fromARGB(255, 243, 232, 136).withOpacity(0.9);
        break;
      case 'closed':
      case 'cancelled':
      case 'refused':
        containerColor = Colors.red.withOpacity(0.9);
        break;
      default:
        containerColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.2);
    }

    print('AppointmentCard: Raw doctorName from appointment: ${widget.appointment.doctorName}');
    print('AppointmentCard: Doctor name for appointment ${widget.appointment.appointmentId}: $doctorName');
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: InkWell(
          onTap: () {
            print('DoctorsAppointmentsScreen: InkWell onTap triggered for appointment: ${widget.appointment.appointmentId}');
          },
          child: Card(
            color: Theme.of(context).cardColor, // Fixed card color
            margin: EdgeInsets.symmetric(vertical: 10.h),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                width: 1.w,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30.r,
                    backgroundColor: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                    child: Icon(
                      Icons.calendar_today,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 30.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          truncateToMaxLength(doctorName, 15),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: Colors.black,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          formattedDate,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                fontSize: 14.sp,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                              size: 16.sp,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              time,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                                    fontSize: 14.sp,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: containerColor, // Dynamic container color based on status
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          widget.appointment.status ?? 'Unknown Status',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white, // Fixed text color for contrast
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}