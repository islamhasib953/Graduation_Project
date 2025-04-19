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
import 'package:segma/utils/colors.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SelectedChildCubit, String?>(
      builder: (context, childId) {
        if (childId == null) {
          return const Center(child: Text('Please select a child'));
        }
        return FutureBuilder<Map<String, dynamic>>(
          future: DoctorService.getUserAppointments(childId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
              return const Center(child: Text('Error loading appointments'));
            }
            final Map<String, List<UserAppointment>> appointmentsData = {};
            (snapshot.data!['data'] as Map<String, dynamic>).forEach((month, appointments) {
              appointmentsData[month] = (appointments as List)
                  .map((appointment) => UserAppointment.fromJson(appointment))
                  .toList();
            });
            if (appointmentsData.isEmpty) {
              return const Center(child: Text('No appointments found'));
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
                      return AppointmentCard(
                        appointment: appointment,
                        onCancel: () {
                          showDialog(
                            context: context,
                            builder: (context) => CancelDialog(
                              onConfirm: () async {
                                try {
                                  await DoctorService.cancelAppointment(childId, appointment.appointmentId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Appointment cancelled successfully')),
                                  );
                                  Navigator.pop(context);
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          );
                        },
                        onReschedule: () {
                          // Ensure doctorId is available in UserAppointment
                          if (appointment.doctorId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Error: Doctor ID not available')),
                            );
                            return;
                          }
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
      },
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final UserAppointment appointment;
  final VoidCallback onCancel;
  final VoidCallback onReschedule;

  const AppointmentCard({
    Key? key,
    required this.appointment,
    required this.onCancel,
    required this.onReschedule,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final date = DateTime.parse(appointment.date);
    final formattedDate = DateFormat('dd MMM, yyyy').format(date);
    final statusColor = appointment.status == 'Accepted'
        ? AppColors.statusUpcoming
        : appointment.status == 'Refused'
            ? AppColors.statusOverdue
            : Theme.of(context).colorScheme.secondary;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor,
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24.r,
            backgroundImage: NetworkImage(appointment.doctorAvatar),
            onBackgroundImageError: (error, stackTrace) {},
            child: appointment.doctorAvatar.isEmpty ? Icon(Icons.person, size: 24.r) : null,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      appointment.doctorName,
                      style: Theme.of(context).textTheme.titleMedium,
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
                onPressed: onCancel,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusOverdue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
                child: Text('Cancel', style: Theme.of(context).textTheme.bodySmall),
              ),
              SizedBox(height: 4.h),
              ElevatedButton(
                onPressed: onReschedule,
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