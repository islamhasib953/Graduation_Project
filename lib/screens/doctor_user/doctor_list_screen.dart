import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/selected_doctor_cubit.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/screens/doctor_user/doctors_appointments_screen.dart';
import 'package:segma/screens/doctor_user/doctor_details_screen.dart';
import 'package:segma/services/doctor_service.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({Key? key}) : super(key: key);

  @override
  _DoctorListScreenState createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen> {
  @override
  Widget build(BuildContext context) {
    print('DoctorListScreen: Building UI');
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctors', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          TextButton(
            onPressed: () {
              print('DoctorListScreen: Tapped on Appointments button');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DoctorsAppointmentsScreen(),
                ),
              );
              print('DoctorListScreen: Navigated to DoctorsAppointmentsScreen');
            },
            child: Text(
              'Appointments',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
      body: BlocBuilder<SelectedChildCubit, String?>(
        builder: (context, childId) {
          print('DoctorListScreen: SelectedChildCubit state - childId: $childId');
          if (childId == null) {
            return Center(child: Text('Please select a child', style: Theme.of(context).textTheme.bodyLarge));
          }
          return FutureBuilder<Map<String, dynamic>>(
            future: DoctorService.getDoctors(childId),
            builder: (context, snapshot) {
              print('DoctorListScreen: FutureBuilder state - connectionState: ${snapshot.connectionState}');
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
                print('DoctorListScreen: Error loading doctors - Error: ${snapshot.error}, Data: ${snapshot.data}');
                return Center(child: Text('Error loading doctors', style: Theme.of(context).textTheme.bodyLarge));
              }
              final List<Doctor> doctors = (snapshot.data!['data'] as List)
                  .map((doctor) => Doctor.fromJson(doctor))
                  .toList();
              print('DoctorListScreen: Loaded ${doctors.length} doctors');
              if (doctors.isEmpty) {
                return Center(child: Text('No doctors found', style: Theme.of(context).textTheme.bodyLarge));
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  return Builder(
                    builder: (BuildContext context) {
                      print('DoctorListScreen: Building DoctorCard for doctor: ${doctor.firstName} ${doctor.lastName}');
                      return DoctorCard(
                        doctor: doctor,
                        onTap: () {
                          print('DoctorListScreen: Tapped on doctor: ${doctor.id} - ${doctor.firstName} ${doctor.lastName}');
                          print('DoctorListScreen: Doctor details - Specialty: ${doctor.specialise}, Address: ${doctor.address}, Rating: ${doctor.rate}, Status: ${doctor.status}');
                          context.read<SelectedDoctorCubit>().selectDoctor(doctor.id);
                          try {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => DoctorDetailsScreen(doctorId: doctor.id),
                              ),
                            );
                            print('DoctorListScreen: Navigated to DoctorDetailsScreen for doctor: ${doctor.id}');
                          } catch (e) {
                            print('DoctorListScreen: Error navigating to DoctorDetailsScreen: $e');
                          }
                        },
                        onFavoriteToggle: () => _toggleFavorite(childId, doctor.id, doctor.isFavorite),
                      );
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

  Future<void> _toggleFavorite(String childId, String doctorId, bool isCurrentlyFavorite) async {
    try {
      final response = isCurrentlyFavorite
          ? await DoctorService.removeFavorite(childId, doctorId)
          : await DoctorService.toggleFavorite(childId, doctorId);
      if (response['status'] == 'success') {
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isCurrentlyFavorite ? 'Removed from Favorites' : 'Added to Favorites',
            ),
            backgroundColor: Theme.of(context).colorScheme.secondary, // لون النجاح
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update favorites'),
            backgroundColor: Theme.of(context).colorScheme.error, // لون الخطأ
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error, // لون الخطأ
        ),
      );
    }
  }
}

class DoctorCard extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const DoctorCard({
    Key? key,
    required this.doctor,
    required this.onTap,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> with SingleTickerProviderStateMixin {
  late AnimationController _starAnimationController;
  late Animation<double> _starScaleAnimation;

  @override
  void initState() {
    super.initState();
    _starAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _starScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _starAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _starAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('DoctorListScreen: Building DoctorCard for doctor: ${widget.doctor.firstName} ${widget.doctor.lastName}');
    return GestureDetector(
      onTap: () {
        print('DoctorListScreen: GestureDetector onTap triggered for doctor: ${widget.doctor.firstName} ${widget.doctor.lastName}');
        widget.onTap();
      },
      child: Card(
        color: Theme.of(context).cardColor,
        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundImage: widget.doctor.avatar.isNotEmpty ? NetworkImage(widget.doctor.avatar) : null,
                backgroundColor: Theme.of(context).colorScheme.secondary,
                onBackgroundImageError: (error, stackTrace) {
                  print('DoctorListScreen: Error loading doctor avatar: $error');
                },
                child: widget.doctor.avatar.isEmpty
                    ? Icon(Icons.person, size: 24.r)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.doctor.firstName} ${widget.doctor.lastName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      widget.doctor.specialise,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16.sp, color: Theme.of(context).iconTheme.color),
                        SizedBox(width: 4.w),
                        Text(
                          '${widget.doctor.address} (${widget.doctor.rate.toStringAsFixed(1)})',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  widget.onFavoriteToggle();
                  _starAnimationController.forward(from: 0).whenComplete(() => _starAnimationController.reverse());
                },
                child: ScaleTransition(
                  scale: _starScaleAnimation,
                  child: Icon(
                    widget.doctor.isFavorite ? Icons.star : Icons.star_border,
                    color: widget.doctor.isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).iconTheme.color,
                    size: 24.sp,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: widget.doctor.status == 'Open' ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.error,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.doctor.status,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}