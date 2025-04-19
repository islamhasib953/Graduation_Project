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
  const DoctorsAppointmentsScreen({Key? key}) : super(key: key);

  @override
  _DoctorsAppointmentsScreenState createState() =>
      _DoctorsAppointmentsScreenState();
}

class _DoctorsAppointmentsScreenState extends State<DoctorsAppointmentsScreen>
    with SingleTickerProviderStateMixin {
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
            backgroundColor: Colors.black,
            body: Center(
              child: Text(
                'Please select a child',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            ),
          );
        }
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            title: const Text('Doctors', style: TextStyle(color: Colors.white)),
            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Top Doctors'),
                Tab(text: 'Appointments'),
              ],
              indicatorColor: Colors.blue,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
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
    return FutureBuilder<Map<String, dynamic>>(
      future: DoctorService.getDoctors(childId),
      builder: (context, snapshot) {
        print('DoctorsAppointmentsScreen: FutureBuilder state for doctors list - connectionState: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      print('DoctorsAppointmentsScreen: Navigating to login screen');
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text('Log In', style: TextStyle(fontSize: 14.sp)),
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
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    print('DoctorsAppointmentsScreen: Retry button pressed for doctors list');
                    setState(() {});
                  },
                  child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
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
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
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
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    print('DoctorsAppointmentsScreen: Retry button pressed for doctors list');
                    setState(() {});
                  },
                  child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
                ),
              ],
            ),
          );
        }
        final List<Doctor> doctors = (response['data'] as List)
            .map((doctor) => Doctor.fromJson(doctor))
            .toList();
        print('DoctorsAppointmentsScreen: Loaded ${doctors.length} doctors');
        if (doctors.isEmpty) {
          return Center(
            child: Text(
              'No doctors found',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: doctors.length,
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return Builder(
              builder: (BuildContext context) {
                print('DoctorsAppointmentsScreen: Building DoctorCard for doctor: ${doctor.firstName} ${doctor.lastName}');
                return _DoctorCard(
                  name: '${doctor.firstName} ${doctor.lastName}',
                  specialty: doctor.specialise,
                  distance: doctor.address,
                  rating: doctor.rate,
                  isOpen: doctor.status == 'Open',
                  onTap: () {
                    print('DoctorsAppointmentsScreen: Tapped on doctor: ${doctor.id} - ${doctor.firstName} ${doctor.lastName}');
                    print('DoctorsAppointmentsScreen: Doctor details - Specialty: ${doctor.specialise}, Address: ${doctor.address}, Rating: ${doctor.rate}, Status: ${doctor.status}');
                    context.read<SelectedDoctorCubit>().selectDoctor(doctor.id);
                    print('DoctorsAppointmentsScreen: SelectedDoctorCubit updated with doctorId: ${doctor.id}');
                    try {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoctorDetailsScreen(doctorId: doctor.id),
                        ),
                      );
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
    );
  }

  Widget _buildAppointmentsList(String childId) {
    print('DoctorsAppointmentsScreen: Building appointments list for childId: $childId');
    return FutureBuilder<Map<String, dynamic>>(
      future: DoctorService.getUserAppointments(childId),
      builder: (context, snapshot) {
        print('DoctorsAppointmentsScreen: FutureBuilder state for appointments list - connectionState: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      print('DoctorsAppointmentsScreen: Navigating to login screen');
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text('Log In', style: TextStyle(fontSize: 14.sp)),
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
                  style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.h),
                ElevatedButton(
                  onPressed: () {
                    print('DoctorsAppointmentsScreen: Retry button pressed for appointments list');
                    setState(() {});
                  },
                  child: Text('Retry', style: TextStyle(fontSize: 14.sp)),
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
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          );
        }
        final response = snapshot.data!;
        if (response['status'] != 'success') {
          print('DoctorsAppointmentsScreen: Failed to load appointments - Response: $response');
          return Center(
            child: Text(
              response['message'] ?? 'No appointments found',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          );
        }
        final Map<String, List<UserAppointment>> appointmentsData = {};
        (response['data'] as Map<String, dynamic>).forEach((month, appointments) {
          appointmentsData[month] = (appointments as List)
              .map((appointment) => UserAppointment.fromJson(appointment))
              .toList();
        });
        print('DoctorsAppointmentsScreen: Loaded ${appointmentsData.length} months of appointments');
        if (appointmentsData.isEmpty) {
          return Center(
            child: Text(
              'No appointments found',
              style: TextStyle(color: Colors.white, fontSize: 16.sp),
            ),
          );
        }
        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: appointmentsData.length,
          itemBuilder: (context, index) {
            final month = appointmentsData.keys.elementAt(index);
            final appointments = appointmentsData[month]!;
            print('DoctorsAppointmentsScreen: Building appointments for month: $month');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    month,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...appointments.map((appointment) {
                  return Builder(
                    builder: (BuildContext context) {
                      print('DoctorsAppointmentsScreen: Building AppointmentCard for appointment: ${appointment.appointmentId}');
                      return _AppointmentCard(
                        appointment: appointment,
                        onCancel: () {
                          print('DoctorsAppointmentsScreen: Tapped on cancel for appointment: ${appointment.appointmentId}');
                          print('DoctorsAppointmentsScreen: Appointment details - Doctor: ${appointment.doctorName}, Date: ${appointment.date}, Time: ${appointment.time}, Status: ${appointment.status}');
                          showDialog(
                            context: context,
                            builder: (context) => CancelDialog(
                              onConfirm: () async {
                                try {
                                  print('DoctorsAppointmentsScreen: Confirming cancellation for appointment: ${appointment.appointmentId}');
                                  await DoctorService.cancelAppointment(childId, appointment.appointmentId);
                                  print('DoctorsAppointmentsScreen: Appointment cancelled successfully');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Appointment cancelled successfully')),
                                  );
                                  Navigator.pop(context);
                                  setState(() {});
                                } catch (e) {
                                  print('DoctorsAppointmentsScreen: Error cancelling appointment: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        onReschedule: () {
                          print('DoctorsAppointmentsScreen: Tapped on reschedule for appointment: ${appointment.appointmentId}');
                          print('DoctorsAppointmentsScreen: Appointment details - Doctor: ${appointment.doctorName}, Date: ${appointment.date}, Time: ${appointment.time}, Status: ${appointment.status}');
                          context.read<SelectedDoctorCubit>().selectDoctor(appointment.doctorId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorDetailsScreen(
                                doctorId: appointment.doctorId,
                                appointmentId: appointment.appointmentId,
                                previousDate: appointment.date,
                                previousTime: appointment.time,
                              ),
                            ),
                          );
                          print('DoctorsAppointmentsScreen: Navigated to DoctorDetailsScreen for rescheduling appointment: ${appointment.appointmentId}');
                        },
                      );
                    },
                  );
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String specialty;
  final String distance;
  final double rating;
  final bool isOpen;
  final VoidCallback onTap;

  const _DoctorCard({
    Key? key,
    required this.name,
    required this.specialty,
    required this.distance,
    required this.rating,
    required this.isOpen,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('DoctorsAppointmentsScreen: Building _DoctorCard for doctor: $name');
    return InkWell(
      onTap: () {
        print('DoctorsAppointmentsScreen: InkWell onTap triggered for doctor: $name');
        onTap();
      },
      child: Card(
        color: Colors.grey[900],
        margin: EdgeInsets.symmetric(vertical: 8.h),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Icon(Icons.person, color: Colors.white, size: 30),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      specialty,
                      style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, color: Colors.grey, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          distance,
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                        SizedBox(width: 8.w),
                        Icon(Icons.star, color: Colors.yellow, size: 16.sp),
                        SizedBox(width: 4.w),
                        Text(
                          rating.toString(),
                          style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isOpen ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  isOpen ? 'Open' : 'Closed',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppointmentCard extends StatelessWidget {
  final UserAppointment appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const _AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final DateTime date = DateTime.parse(appointment.date);
    final String formattedDate = DateFormat('MMM d, yyyy').format(date);
    return Card(
      color: Colors.grey[900],
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
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
                        appointment.doctorName,
                        style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Date: $formattedDate',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Time: ${appointment.time}',
                        style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: appointment.status == 'Scheduled' ? Colors.blue : Colors.grey,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    appointment.status,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
                SizedBox(width: 8.w),
                TextButton(
                  onPressed: onReschedule,
                  child: const Text('Reschedule', style: TextStyle(color: Colors.blue)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}