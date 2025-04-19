import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/appointment_model.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/utils/themes.dart';

class DoctorDetailsScreen extends StatefulWidget {
  final String doctorId;
  final String? appointmentId;
  final String? previousDate;
  final String? previousTime;

  const DoctorDetailsScreen({
    super.key,
    required this.doctorId,
    this.appointmentId,
    this.previousDate,
    this.previousTime,
  });

  @override
  State<DoctorDetailsScreen> createState() => _DoctorDetailsScreenState();
}

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen> with SingleTickerProviderStateMixin {
  late ScrollController _dateScrollController;
  String? _selectedDate;
  String? _selectedTime;
  String _visitType = 'On Clinic';
  bool _showSuccessAnimation = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _dateScrollController = ScrollController();
    _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkIfFavorite();
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _heartScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _heartAnimationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _dateScrollController.dispose();
    _animationController.dispose();
    _heartAnimationController.dispose();
    super.dispose();
  }

  Future<void> _checkIfFavorite() async {
    final childId = context.read<SelectedChildCubit>().state;
    if (childId == null) return;
    try {
      final isFavorite = await DoctorService.isDoctorFavorite(childId, widget.doctorId);
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking favorite status: $e')),
      );
    }
  }

  Future<void> _toggleFavorite(String childId) async {
    try {
      final response = _isFavorite
          ? await DoctorService.removeFavorite(childId, widget.doctorId)
          : await DoctorService.toggleFavorite(childId, widget.doctorId);
      if (response['status'] == 'success') {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        _heartAnimationController.forward(from: 0).whenComplete(() => _heartAnimationController.reverse());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isFavorite ? 'Added to Favorites' : 'Removed from Favorites')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update favorites')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showSuccessMessage() {
    setState(() {
      _showSuccessAnimation = true;
    });
    _animationController.forward().then((_) {
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _showSuccessAnimation = false;
        });
        _animationController.reset();
        Navigator.pop(context);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('Doctor Details', style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          BlocBuilder<SelectedChildCubit, String?>(
            builder: (context, childId) {
              if (childId == null) return const SizedBox.shrink();
              return IconButton(
                icon: ScaleTransition(
                  scale: _heartScaleAnimation,
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: _isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).iconTheme.color, // Updated
                  ),
                ),
                onPressed: () => _toggleFavorite(childId),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          BlocBuilder<SelectedChildCubit, String?>(
            builder: (context, childId) {
              if (childId == null) {
                return Center(child: Text('Please select a child', style: Theme.of(context).textTheme.bodyLarge));
              }
              return FutureBuilder<Map<String, dynamic>>(
                future: DoctorService.getDoctorDetails(childId, widget.doctorId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
                    return Center(
                      child: Text(
                        'Error loading doctor details: ${snapshot.error ?? snapshot.data?['message'] ?? 'Unknown error'}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    );
                  }
                  final doctor = Doctor.fromJson(snapshot.data!['data']);
                  final dates = List.generate(30, (index) => DateTime.now().add(Duration(days: index)));
                  final bookedAppointments = doctor.bookedAppointments ?? [];
                  return ListView(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    children: [
                      if (widget.appointmentId != null) ...[
                        Text(
                          'Previous Appointment: ${widget.previousDate} at ${widget.previousTime}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 8.h),
                      ],
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                        child: Padding(
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 40.r,
                                backgroundImage: doctor.avatar.isNotEmpty ? NetworkImage(doctor.avatar) : null,
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                onBackgroundImageError: (error, stackTrace) {},
                                child: doctor.avatar.isEmpty
                                    ? Icon(Icons.person, size: 40.r)
                                    : null,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${doctor.firstName} ${doctor.lastName}',
                                            style: Theme.of(context).textTheme.titleLarge,
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () => _toggleFavorite(childId),
                                          child: ScaleTransition(
                                            scale: _heartScaleAnimation,
                                            child: Icon(
                                              _isFavorite ? Icons.favorite : Icons.favorite_border,
                                              color: _isFavorite ? Theme.of(context).colorScheme.error : Theme.of(context).iconTheme.color, // Updated
                                              size: 24.sp,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      doctor.specialise,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    SizedBox(height: 4.h),
                                    Row(
                                      children: [
                                        Icon(Icons.location_on, size: 14.sp, color: Theme.of(context).iconTheme.color),
                                        SizedBox(width: 4.w),
                                        Text(
                                          doctor.address,
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.star, size: 14.sp, color: Colors.yellow),
                                        SizedBox(width: 4.w),
                                        Text(
                                          doctor.rate.toStringAsFixed(1),
                                          style: Theme.of(context).textTheme.bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Text('About', style: Theme.of(context).textTheme.titleMedium),
                      SizedBox(height: 8.h),
                      Text(
                        doctor.about,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        height: 60.h,
                        child: ListView.builder(
                          controller: _dateScrollController,
                          scrollDirection: Axis.horizontal,
                          itemCount: dates.length,
                          itemBuilder: (context, index) {
                            final date = dates[index];
                            final formattedDate = DateFormat('yyyy-MM-dd').format(date);
                            final isSelected = _selectedDate == formattedDate;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedDate = formattedDate),
                              child: Card(
                                elevation: isSelected ? 4 : 0,
                                color: isSelected ? Theme.of(context).primaryColor : Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                child: SizedBox(
                                  width: 70.w,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat('E').format(date),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodySmall?.color,
                                            ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        DateFormat('dd').format(date),
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8.w,
                          mainAxisSpacing: 8.h,
                          childAspectRatio: 2.8,
                        ),
                        itemCount: doctor.availableTimes.length,
                        itemBuilder: (context, index) {
                          final time = doctor.availableTimes[index];
                          final isBooked = bookedAppointments.any((appt) {
                            final apptDate = DateFormat('yyyy-MM-dd').format(DateTime.parse(appt.date));
                            return apptDate == _selectedDate && appt.time == time;
                          });
                          final isSelected = _selectedTime == time;
                          return GestureDetector(
                            onTap: isBooked ? null : () => setState(() => _selectedTime = time),
                            child: Card(
                              elevation: isSelected ? 4 : 0,
                              color: isBooked
                                  ? Theme.of(context).disabledColor
                                  : isSelected
                                      ? Theme.of(context).primaryColor
                                      : Theme.of(context).cardColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                              child: Stack(
                                children: [
                                  Center(
                                    child: Text(
                                      time,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: isBooked || isSelected
                                                ? Colors.white
                                                : Theme.of(context).textTheme.bodySmall?.color,
                                          ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Positioned(
                                      right: 4.w,
                                      top: 4.h,
                                      child: Icon(Icons.check_circle, color: Colors.white, size: 16.sp),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ChoiceChip(
                            label: Text('On Clinic', style: Theme.of(context).textTheme.bodyMedium),
                            selected: _visitType == 'On Clinic',
                            selectedColor: Theme.of(context).primaryColor,
                            onSelected: (selected) {
                              if (selected) setState(() => _visitType = 'On Clinic');
                            },
                          ),
                          ChoiceChip(
                            label: Text('On Home', style: Theme.of(context).textTheme.bodyMedium),
                            selected: _visitType == 'On Home',
                            selectedColor: Theme.of(context).primaryColor,
                            onSelected: (selected) {
                              if (selected) setState(() => _visitType = 'On Home');
                            },
                          ),
                          ChoiceChip(
                            label: Text('Join Call', style: Theme.of(context).textTheme.bodyMedium),
                            selected: _visitType == 'Join Call',
                            selectedColor: Theme.of(context).primaryColor,
                            onSelected: (selected) {
                              if (selected) setState(() => _visitType = 'Join Call');
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton(
                        onPressed: _selectedDate == null || _selectedTime == null
                            ? null
                            : () async {
                                final data = {
                                  'date': _selectedDate,
                                  'time': _selectedTime,
                                  'visitType': _visitType,
                                };
                                try {
                                  if (widget.appointmentId != null) {
                                    await DoctorService.rescheduleAppointment(childId, widget.appointmentId!, data);
                                  } else {
                                    await DoctorService.bookAppointment(childId, widget.doctorId, data);
                                  }
                                  _showSuccessMessage();
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                        ),
                        child: Text(
                          widget.appointmentId != null ? 'Reschedule Appointment' : 'Book Appointment',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  );
                },
              );
            },
          ),
          if (_showSuccessAnimation)
            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    child: Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(
                        'Appointment Successful',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}