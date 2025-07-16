import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/selected_doctor_cubit.dart';
import 'package:segma/models/appointment_model.dart';
import 'package:segma/screens/doctor_user/cancel_dialog.dart';
import 'package:segma/screens/doctor_user/doctor_details_screen.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/services/notification_service.dart';
import 'package:segma/utils/colors.dart';
import 'package:segma/services/auth_service.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedChildCubit, String?>(
      builder: (context, childId) {
        if (childId == null) {
          return const Center(child: Text('Please select a child'));
        }
        return FutureBuilder<Map<String, dynamic>>(
          future: DoctorService.getUserAppointments(childId),
          key: ValueKey(childId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
              return const Center(child: Text('Error loading appointments'));
            }
            final dynamic data = snapshot.data!['data'];
            List<UserAppointment> appointmentsList = [];
            if (data is List) {
              appointmentsList = data.map((appointment) => UserAppointment.fromJson(appointment)).toList();
            } else if (data is Map && data.containsKey('appointment')) {
              // Handle single appointment object
              final appointmentData = data['appointment'];
              if (appointmentData != null) {
                appointmentsList.add(UserAppointment.fromJson(appointmentData));
              }
            }
            if (appointmentsList.isEmpty) {
              return const Center(child: Text('No appointments found'));
            }
            final Map<String, List<UserAppointment>> appointmentsData = {};
            for (var appointment in appointmentsList) {
              final date = DateTime.parse(appointment.date);
              final month = DateFormat('MMMM yyyy').format(date);
              if (!appointmentsData.containsKey(month)) {
                appointmentsData[month] = [];
              }
              appointmentsData[month]!.add(appointment);
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: appointmentsData.length,
              itemBuilder: (context, index) {
                final month = appointmentsData.keys.elementAt(index);
                final appointments = appointmentsData[month]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      child: Text(
                        month,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ...appointments.map((appointment) {
                      final doctorName = appointment.doctorName ?? 'Unknown Doctor';
                      print('AppointmentsScreen: Appointment ${appointment.appointmentId} - doctorName: $doctorName');
                      return AppointmentCard(
                        appointment: appointment,
                        onCancel: () {
                          showDialog(
                            context: context,
                            builder: (context) => CancelDialog(
                              onConfirm: () async {
                                try {
                                  final response = await DoctorService.cancelAppointment(childId, appointment.appointmentId);
                                  if (response['status'] == 'success') {
                                    final userId = await AuthService.getUserId();
                                    await NotificationService.sendAppointmentCancellationNotification(
                                      childId: childId,
                                      userId: userId ?? '',
                                      appointmentId: appointment.appointmentId,
                                      doctorName: doctorName,
                                      date: appointment.date,
                                      time: appointment.time,
                                    );
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Appointment cancelled successfully')),
                                      );
                                      Navigator.pop(context);
                                      setState(() {});
                                    }
                                  } else {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response['message'] ?? 'Failed to cancel appointment')),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Error: $e')),
                                    );
                                  }
                                }
                              },
                            ),
                          );
                        },
                        onReschedule: () {
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
                        },
                      );
                    }),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final UserAppointment appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(appointment.date);
    final formattedDate = DateFormat('dd MMM, yyyy').format(date);
    final statusColor = appointment.status == 'Accepted'
        ? AppColors.statusUpcoming
        : appointment.status == 'Refused'
            ? AppColors.statusOverdue
            : Theme.of(context).colorScheme.secondary;
    final doctorName = appointment.doctorName ?? 'Unknown Doctor';
    print('AppointmentCard: Building for appointment ${appointment.appointmentId} - doctorName: $doctorName');

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: appointment.doctorAvatar != null && appointment.doctorAvatar!.isNotEmpty
                ? NetworkImage(appointment.doctorAvatar!)
                : null,
            onBackgroundImageError: (error, stackTrace) {},
            child: appointment.doctorAvatar == null || appointment.doctorAvatar!.isEmpty
                ? Icon(Icons.person, size: 24.r)
                : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      doctorName,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: statusColor,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        appointment.status,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16.sp, color: Theme.of(context).iconTheme.color),
                    SizedBox(width: 4.w),
                    Text(
                      formattedDate,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.access_time, size: 16.sp, color: Theme.of(context).iconTheme.color),
                    SizedBox(width: 4.w),
                    Text(
                      appointment.time,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.local_hospital, size: 16.sp, color: Theme.of(context).iconTheme.color),
                    SizedBox(width: 4.w),
                    Text(
                      appointment.visitType,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: (appointment.status == 'Accepted' || appointment.status == 'Pending') ? onCancel : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusOverdue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall),
              ),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: (appointment.status == 'Accepted' || appointment.status == 'Pending') ? onReschedule : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Reschedule', style: Theme.of(context).textTheme.bodySmall),
              ),
            ],
          ),
        ],
      ),
    );
  }
}