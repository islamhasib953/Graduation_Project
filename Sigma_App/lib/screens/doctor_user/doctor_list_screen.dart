import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/selected_doctor_cubit.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/screens/doctor_user/doctors_appointments_screen.dart';
import 'package:segma/screens/doctor_user/doctor_details_screen.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:intl/intl.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

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
              final dynamic data = snapshot.data!['data'];
              List<Doctor> doctors = [];
              if (data is List) {
                doctors = data.map((doctor) => Doctor.fromJson(doctor)).toList();
              } else if (data is Map) {
                final List<dynamic>? doctorList = data['doctors'] ?? data['data'];
                if (doctorList != null) {
                  doctors = doctorList.map((doctor) => Doctor.fromJson(doctor)).toList();
                }
              }
              print('DoctorListScreen: Loaded ${doctors.length} doctors');
              if (doctors.isEmpty) {
                return Center(child: Text('No doctors found', style: Theme.of(context).textTheme.bodyLarge));
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                itemCount: doctors.length,
                itemBuilder: (context, index) {
                  final doctor = doctors[index];
                  final currentDay = DateFormat('EEEE', 'ar').format(DateTime.now()).toString(); // استخدام اللغة العربية
                  final isAvailableToday = doctor.availableDays.any((day) => day.toLowerCase().contains(currentDay.toLowerCase()));
                  final statusFromAPI = doctor.status; // Use the status from API
                  final status = statusFromAPI == 'Open' ? 'مفتوح' : 'مقفول';
                  return Builder(
                    builder: (BuildContext context) {
                      print('DoctorListScreen: Building DoctorCard for doctor: ${doctor.firstName} ${doctor.lastName}');
                      return DoctorCard(
                        doctor: doctor,
                        status: status,
                        onTap: () {
                          print('DoctorListScreen: Tapped on doctor: ${doctor.id} - ${doctor.firstName} ${doctor.lastName}');
                          print('DoctorListScreen: Doctor details - Specialty: ${doctor.specialise}, Address: ${doctor.address}, Rating: ${doctor.rate}, Status: $status');
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
            backgroundColor: Theme.of(context).colorScheme.secondary,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to update favorites'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }
}

class DoctorCard extends StatefulWidget {
  final Doctor doctor;
  final String status;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const DoctorCard({
    super.key,
    required this.doctor,
    required this.status,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  _DoctorCardState createState() => _DoctorCardState();
}

class _DoctorCardState extends State<DoctorCard> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _starScaleAnimation;
  late Animation<Color?> _starColorAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _starScaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _starColorAnimation = ColorTween(
      begin: Theme.of(context).iconTheme.color,
      end: Theme.of(context).colorScheme.error,
    ).animate(
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
    print('DoctorListScreen: Building DoctorCard for doctor: ${widget.doctor.firstName} ${widget.doctor.lastName}');
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: GestureDetector(
          onTap: () {
            print('DoctorListScreen: GestureDetector onTap triggered for doctor: ${widget.doctor.firstName} ${widget.doctor.lastName}');
            widget.onTap();
          },
          child: Card(
            color: Theme.of(context).cardColor,
            margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
            elevation: 6,
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
              padding: EdgeInsets.all(16.r),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {
                      if (widget.doctor.avatar.isNotEmpty) {
                        _showFullImage(widget.doctor.avatar);
                      }
                    },
                    child: CircleAvatar(
                      radius: 28.r,
                      backgroundImage: widget.doctor.avatar.isNotEmpty
                          ? (widget.doctor.avatar.startsWith('http') ||
                                  widget.doctor.avatar.startsWith('https')
                              ? NetworkImage(widget.doctor.avatar)
                              : MemoryImage(base64Decode(widget.doctor.avatar
                                  .split(',')
                                  .last)))
                          : null,
                      backgroundColor: Theme.of(context)
                          .colorScheme
                          .secondary
                          .withOpacity(0.2),
                      onBackgroundImageError: (error, stackTrace) {
                        print('DoctorListScreen: Error loading doctor avatar: $error');
                      },
                      child: widget.doctor.avatar.isEmpty
                          ? Icon(
                              Icons.person,
                              size: 28.r,
                              color: Theme.of(context).colorScheme.secondary,
                            )
                          : null,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${widget.doctor.firstName} ${widget.doctor.lastName}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black87,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          truncateToMaxLength(widget.doctor.specialise, 15),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 14.sp,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 14.sp,
                              color: Theme.of(context).iconTheme.color?.withOpacity(0.7),
                            ),
                            SizedBox(width: 4.w),
                            Flexible(
                              child: Text(
                                truncateToMaxLength(
                                    '${widget.doctor.address} (${widget.doctor.rate.toStringAsFixed(1)})', 15),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      fontSize: 12.sp,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white60
                                          : Colors.black45,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () {
                      widget.onFavoriteToggle();
                      _animationController.forward(from: 0).whenComplete(() => _animationController.reverse());
                    },
                    child: ScaleTransition(
                      scale: _starScaleAnimation,
                      child: Icon(
                        widget.doctor.isFavorite ? Icons.star : Icons.star_border,
                        color: widget.doctor.isFavorite
                            ? _starColorAnimation.value
                            : Theme.of(context).iconTheme.color,
                        size: 26.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: widget.status == 'مفتوح'
                          ? const Color.fromARGB(255, 70, 206, 74).withOpacity(0.9)
                          : Colors.red.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(10.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      widget.status,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12.sp,
                            color: Colors.white,
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

  void _showFullImage(String avatarUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: avatarUrl.startsWith('http') || avatarUrl.startsWith('https')
              ? Image.network(
                  avatarUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                )
              : Image.memory(
                  base64Decode(avatarUrl.split(',').last),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.error);
                  },
                ),
        ),
      ),
    );
  }
}