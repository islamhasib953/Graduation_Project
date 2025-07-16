import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/appointments_cubit.dart';
import 'package:segma/cubits/doctor_details_cubit.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/services/notification_service.dart';
import 'package:segma/services/auth_service.dart';
import 'package:segma/utils/colors.dart';

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

class _DoctorDetailsScreenState extends State<DoctorDetailsScreen>
    with TickerProviderStateMixin {
  late ScrollController _dateScrollController;
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
      CurvedAnimation(
          parent: _heartAnimationController, curve: Curves.easeInOut),
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
      final isFavorite =
          await DoctorService.isDoctorFavorite(childId, widget.doctorId);
      setState(() {
        _isFavorite = isFavorite;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking favorite status: $e')),
        );
      }
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
        _heartAnimationController
            .forward(from: 0)
            .whenComplete(() => _heartAnimationController.reverse());
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(_isFavorite
                    ? 'Added to favorites'
                    : 'Removed from favorites')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to update favorite status')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _showSuccessMessage(String date, String time, String visitType) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'تم الحجز بنجاح',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: $date',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'Time: $time',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 8.h),
            Text(
              'Visit Type: $visitType',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              final childId = context.read<SelectedChildCubit>().state;
              if (childId != null) {
                context.read<AppointmentsCubit>().fetchAppointments(childId);
              }
            },
            child: Text(
              'OK',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DoctorDetailsCubit(),
      child: Builder(
        builder: (context) {
          final isDarkMode = Theme.of(context).brightness == Brightness.dark;
          return Scaffold(
            backgroundColor: isDarkMode
                ? AppColors.darkBackground
                : AppColors.lightBackground,
            appBar: AppBar(
              backgroundColor: isDarkMode
                  ? AppColors.darkNavBarBackground
                  : AppColors.lightNavBarBackground,
              title: Text(
                'Doctor Details',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: isDarkMode
                          ? AppColors.darkTextPrimary
                          : AppColors.lightTextPrimary,
                    ),
              ),
              leading: IconButton(
                icon: Icon(
                  Icons.arrow_back,
                  color: isDarkMode ? AppColors.darkIcon : AppColors.lightIcon,
                ),
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
                          color: _isFavorite
                              ? AppColors.statusOverdue
                              : (isDarkMode
                                  ? AppColors.darkNavBarInactive
                                  : AppColors.lightNavBarInactive),
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
                      return Center(
                        child: Text(
                          'Please select a child',
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                        ),
                      );
                    }
                    return FutureBuilder<Map<String, dynamic>>(
                      future: DoctorService.getDoctorDetails(
                          childId, widget.doctorId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError ||
                            !snapshot.hasData ||
                            snapshot.data!['status'] != 'success') {
                          print(
                              'DoctorDetailsScreen: Error or no data - Error: ${snapshot.error}, Data: ${snapshot.data}');
                          return Center(
                            child: Text(
                              'Error loading doctor details: ${snapshot.error ?? snapshot.data?['message'] ?? 'Unknown error'}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.copyWith(
                                    color: isDarkMode
                                        ? AppColors.darkTextPrimary
                                        : AppColors.lightTextPrimary,
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          );
                        }
                        final data = snapshot.data!['data']['doctor'];
                        final doctor = Doctor.fromJson(data);
                        final firstName = doctor.firstName ?? '';
                        final lastName = doctor.lastName ?? '';
                        final fullName = '$firstName $lastName'.trim();
                        print('DoctorDetailsScreen: Doctor name - firstName: $firstName, lastName: $lastName, fullName: $fullName');

                        final dates = List.generate(
                            30,
                            (index) =>
                                DateTime.now().add(Duration(days: index)));
                        final bookedAppointments =
                            doctor.bookedAppointments ?? [];
                        return BlocBuilder<DoctorDetailsCubit,
                            DoctorDetailsState>(
                          builder: (context, state) {
                            return ListView(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 16.w, vertical: 20.h),
                              children: [
                                if (widget.appointmentId != null) ...[
                                  Text(
                                    'Previous Appointment: ${widget.previousDate} at ${widget.previousTime}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: isDarkMode
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
                                        ),
                                  ),
                                  SizedBox(height: 12.h),
                                ],
                                Card(
                                  elevation: 6,
                                  color: isDarkMode
                                      ? AppColors.darkCardBackground
                                      : AppColors.lightCardBackground,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(16.r)),
                                  child: Padding(
                                    padding: EdgeInsets.all(16.r),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CircleAvatar(
                                          radius: 40.r,
                                          backgroundColor:
                                              AppColors.featureDoctor,
                                          child: Icon(
                                            Icons.person,
                                            size: 40.r,
                                            color: Colors.white,
                                          ),
                                        ),
                                        SizedBox(width: 16.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      fullName.isEmpty ? 'Unknown Doctor' : fullName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleLarge
                                                          ?.copyWith(
                                                            color: isDarkMode
                                                                ? AppColors
                                                                    .darkTextPrimary
                                                                : AppColors
                                                                    .lightTextPrimary,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () =>
                                                        _toggleFavorite(
                                                            childId),
                                                    child: ScaleTransition(
                                                      scale:
                                                          _heartScaleAnimation,
                                                      // child: Icon(
                                                      //   _isFavorite
                                                      //       ? Icons.favorite
                                                      //       : Icons
                                                      //           .favorite_border,
                                                      //   color: _isFavorite
                                                      //       ? AppColors
                                                      //           .statusOverdue
                                                      //       : (isDarkMode
                                                      //           ? AppColors
                                                      //               .darkNavBarInactive
                                                      //           : AppColors
                                                      //               .lightNavBarInactive),
                                                      //   size: 24.sp,
                                                      // ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 6.h),
                                              Text(
                                                doctor.specialise ??
                                                    'Unknown Specialty',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: isDarkMode
                                                          ? AppColors
                                                              .darkTextSecondary
                                                          : AppColors
                                                              .lightTextSecondary,
                                                    ),
                                              ),
                                              SizedBox(height: 6.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.location_on,
                                                    size: 14.sp,
                                                    color: isDarkMode
                                                        ? AppColors.darkIcon
                                                        : AppColors.lightIcon,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Expanded(
                                                    child: Text(
                                                      doctor.address ??
                                                          'Unknown Address',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: isDarkMode
                                                                ? AppColors
                                                                    .darkTextSecondary
                                                                : AppColors
                                                                    .lightTextSecondary,
                                                          ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: 6.h),
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.star,
                                                    size: 14.sp,
                                                    color:
                                                        AppColors.featureGrowth,
                                                  ),
                                                  SizedBox(width: 4.w),
                                                  Text(
                                                    doctor.rate
                                                        .toStringAsFixed(1),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: isDarkMode
                                                              ? AppColors
                                                                  .darkTextSecondary
                                                              : AppColors
                                                                  .lightTextSecondary,
                                                        ),
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
                                SizedBox(height: 20.h),
                                Text(
                                  'About the Doctor',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                Text(
                                  doctor.about,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkTextSecondary
                                            : AppColors.lightTextSecondary,
                                      ),
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  'Select Date',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                SizedBox(
                                  height: 70.h,
                                  child: ListView.builder(
                                    controller: _dateScrollController,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: dates.length,
                                    itemBuilder: (context, index) {
                                      final date = dates[index];
                                      final formattedDate =
                                          DateFormat('yyyy-MM-dd')
                                              .format(date);
                                      final dayName = DateFormat('EEEE')
                                          .format(date);
                                      final isSelected =
                                          state.selectedDate == formattedDate;
                                      final isAvailable = doctor.availableDays
                                          .any((day) => day.contains(dayName));
                                      return Padding(
                                        padding: EdgeInsets.only(right: 2.w),
                                        child: GestureDetector(
                                          onTap: isAvailable
                                              ? () => context
                                                  .read<DoctorDetailsCubit>()
                                                  .selectDate(formattedDate)
                                              : null,
                                          child: Card(
                                            elevation: isSelected ? 6 : 2,
                                            color: isAvailable
                                                ? (isSelected
                                                    ? (isDarkMode
                                                        ? AppColors
                                                            .darkButtonPrimary
                                                        : AppColors
                                                            .lightButtonPrimary)
                                                    : (isDarkMode
                                                        ? AppColors
                                                            .darkCardBackground
                                                        : AppColors
                                                            .lightCardBackground))
                                                : (isDarkMode
                                                    ? AppColors
                                                        .darkNavBarInactive
                                                    : AppColors
                                                        .lightNavBarInactive),
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        12.r)),
                                            child: SizedBox(
                                              width: 40.w,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    DateFormat('E')
                                                        .format(date),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: isSelected
                                                              ? Colors.white
                                                              : (isDarkMode
                                                                  ? AppColors
                                                                      .darkTextSecondary
                                                                  : AppColors
                                                                      .lightTextSecondary),
                                                        ),
                                                  ),
                                                  SizedBox(height: 4.h),
                                                  Text(
                                                    DateFormat('dd')
                                                        .format(date),
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.copyWith(
                                                          color: isSelected
                                                              ? Colors.white
                                                              : (isDarkMode
                                                                  ? AppColors
                                                                      .darkTextSecondary
                                                                  : AppColors
                                                                      .lightTextSecondary),
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  'Select Time',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                doctor.availableTimes.isNotEmpty
                                    ? GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 10.w,
                                          mainAxisSpacing: 10.h,
                                          childAspectRatio: 2.0,
                                        ),
                                        itemCount: doctor.availableTimes.length,
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 8.w, vertical: 4.h),
                                        itemBuilder: (context, index) {
                                          final time =
                                              doctor.availableTimes[index];
                                          final isBooked = bookedAppointments.any(
                                              (appt) {
                                            final apptDate = DateFormat(
                                                    'yyyy-MM-dd')
                                                .format(DateTime.parse(
                                                    appt.date));
                                            return apptDate ==
                                                    state.selectedDate &&
                                                appt.time == time;
                                          });
                                          final isSelected =
                                              state.selectedTime == time;

                                          return GestureDetector(
                                            onTap: isBooked
                                                ? null
                                                : () => context
                                                    .read<DoctorDetailsCubit>()
                                                    .selectTime(time),
                                            child: AnimatedContainer(
                                              duration: const Duration(
                                                  milliseconds: 200),
                                              decoration: BoxDecoration(
                                                color: isBooked
                                                    ? (isDarkMode
                                                        ? AppColors
                                                            .darkNavBarInactive
                                                        : AppColors
                                                            .lightNavBarInactive)
                                                    : isSelected
                                                        ? (isDarkMode
                                                            ? AppColors
                                                                .darkButtonPrimary
                                                            : AppColors
                                                                .lightButtonPrimary)
                                                        : (isDarkMode
                                                            ? AppColors
                                                                .darkCardBackground
                                                            : AppColors
                                                                .lightCardBackground),
                                                borderRadius:
                                                    BorderRadius.circular(12.r),
                                                border: isSelected
                                                    ? Border.all(
                                                        color: Colors.white,
                                                        width: 2.w)
                                                    : null,
                                                boxShadow: isSelected
                                                    ? [
                                                        BoxShadow(
                                                          color: Colors.black26,
                                                          blurRadius: 6,
                                                          offset: Offset(0, 2),
                                                        ),
                                                      ]
                                                    : null,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  time,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: isBooked ||
                                                                isSelected
                                                            ? Colors.white
                                                            : (isDarkMode
                                                                ? AppColors
                                                                    .darkTextSecondary
                                                                : AppColors
                                                                    .lightTextSecondary),
                                                        fontWeight: isSelected
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                      ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    : Text(
                                        'No Available Times',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: isDarkMode
                                                  ? AppColors.darkTextSecondary
                                                  : AppColors
                                                      .lightTextSecondary,
                                            ),
                                      ),
                                SizedBox(height: 20.h),
                                Text(
                                  'Visit Type',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: isDarkMode
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                SizedBox(height: 8.h),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(
                                      child: ChoiceChip(
                                        label: Text(
                                          'In Clinic',
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: state.visitType ==
                                                            'On Clinic'
                                                        ? Colors.white
                                                        : (isDarkMode
                                                            ? AppColors
                                                                .darkTextSecondary
                                                            : AppColors
                                                                .lightTextSecondary),
                                                  ),
                                        ),
                                        selected:
                                            state.visitType == 'On Clinic',
                                        selectedColor: isDarkMode
                                            ? AppColors.darkButtonPrimary
                                            : AppColors.lightButtonPrimary,
                                        backgroundColor: isDarkMode
                                            ? AppColors.darkCardBackground
                                            : AppColors.lightCardBackground,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 8.h),
                                        onSelected: (selected) {
                                          if (selected)
                                            context
                                                .read<DoctorDetailsCubit>()
                                                .selectVisitType('On Clinic');
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: ChoiceChip(
                                        label: Text(
                                          'At Home',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: state.visitType ==
                                                        'On Home'
                                                    ? Colors.white
                                                    : (isDarkMode
                                                        ? AppColors
                                                            .darkTextSecondary
                                                        : AppColors
                                                            .lightTextSecondary),
                                              ),
                                        ),
                                        selected: state.visitType == 'On Home',
                                        selectedColor: isDarkMode
                                            ? AppColors.darkButtonPrimary
                                            : AppColors.lightButtonPrimary,
                                        backgroundColor: isDarkMode
                                            ? AppColors.darkCardBackground
                                            : AppColors.lightCardBackground,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 8.h),
                                        onSelected: (selected) {
                                          if (selected)
                                            context
                                                .read<DoctorDetailsCubit>()
                                                .selectVisitType('On Home');
                                        },
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      child: ChoiceChip(
                                        label: Text(
                                          'Video Call',
                                          style:
                                              Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium
                                                  ?.copyWith(
                                                    color: state.visitType ==
                                                            'Join Call'
                                                        ? Colors.white
                                                        : (isDarkMode
                                                            ? AppColors
                                                                .darkTextSecondary
                                                            : AppColors
                                                                .lightTextSecondary),
                                                  ),
                                        ),
                                        selected:
                                            state.visitType == 'Join Call',
                                        selectedColor: isDarkMode
                                            ? AppColors.darkButtonPrimary
                                            : AppColors.lightButtonPrimary,
                                        backgroundColor: isDarkMode
                                            ? AppColors.darkCardBackground
                                            : AppColors.lightCardBackground,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.r)),
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12.w, vertical: 8.h),
                                        onSelected: (selected) {
                                          if (selected)
                                            context
                                                .read<DoctorDetailsCubit>()
                                                .selectVisitType('Join Call');
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20.h),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: state.selectedDate == null ||
                                            state.selectedTime == null
                                        ? null
                                        : () async {
                                            final data = {
                                              'date': state.selectedDate,
                                              'time': state.selectedTime,
                                              'visitType': state.visitType,
                                            };
                                            try {
                                              if (widget.appointmentId !=
                                                  null) {
                                                final response =
                                                    await DoctorService
                                                        .rescheduleAppointment(
                                                  childId,
                                                  widget.appointmentId!,
                                                  data,
                                                );
                                                if (response['status'] ==
                                                    'success') {
                                                  final userId =
                                                      await AuthService
                                                          .getUserId();
                                                  await NotificationService
                                                      .sendAppointmentNotification(
                                                    childId: childId,
                                                    doctorId: widget.doctorId,
                                                    appointmentId:
                                                        widget.appointmentId!,
                                                    userId: userId ?? '',
                                                    date: state.selectedDate!,
                                                    time: state.selectedTime!,
                                                    doctorName: fullName,
                                                    isReschedule: true,
                                                  );
                                                  _showSuccessMessage(
                                                    state.selectedDate!,
                                                    state.selectedTime!,
                                                    state.visitType!,
                                                  );
                                                } else {
                                                  String errorMessage =
                                                      response['message'] ??
                                                          'Failed to reschedule';
                                                  if (errorMessage.contains(
                                                      'already booked')) {
                                                    errorMessage =
                                                        'This date and time are already booked. Please choose another slot.';
                                                  }
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              errorMessage)),
                                                    );
                                                  }
                                                }
                                              } else {
                                                final response =
                                                    await DoctorService
                                                        .bookAppointment(
                                                  childId,
                                                  widget.doctorId,
                                                  data,
                                                );
                                                if (response['status'] ==
                                                    'success') {
                                                  final userId =
                                                      await AuthService
                                                          .getUserId();
                                                  await NotificationService
                                                      .sendAppointmentNotification(
                                                    childId: childId,
                                                    doctorId: widget.doctorId,
                                                    appointmentId: response[
                                                                'data']
                                                            ['appointmentId'] ??
                                                        '',
                                                    userId: userId ?? '',
                                                    date: state.selectedDate!,
                                                    time: state.selectedTime!,
                                                    doctorName: fullName,
                                                    isReschedule: false,
                                                  );
                                                  _showSuccessMessage(
                                                    state.selectedDate!,
                                                    state.selectedTime!,
                                                    state.visitType!,
                                                  );
                                                } else {
                                                  String errorMessage =
                                                      response['message'] ??
                                                          'Failed to book';
                                                  if (errorMessage.contains(
                                                      'already booked')) {
                                                    errorMessage =
                                                        'This date and time are already booked. Please choose another slot.';
                                                  }
                                                  if (context.mounted) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                          content: Text(
                                                              errorMessage)),
                                                    );
                                                  }
                                                }
                                              }
                                            } catch (e) {
                                              if (context.mounted) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                      content:
                                                          Text('Error: $e')),
                                                );
                                              }
                                            }
                                          },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isDarkMode
                                          ? AppColors.darkButtonPrimary
                                          : AppColors.lightButtonPrimary,
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                          vertical: 12.h, horizontal: 24.w),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12.r)),
                                      elevation: 4,
                                    ),
                                    child: Text(
                                      widget.appointmentId != null
                                          ? 'Reschedule Appointment'
                                          : 'Book Appointment',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyLarge
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 40.h),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
                BlocBuilder<DoctorDetailsCubit, DoctorDetailsState>(
                  builder: (context, state) {
                    if (state.showSuccessAnimation) {
                      return Container(
                        color: Colors.black54,
                        child: Center(
                          child: FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Card(
                                elevation: 10,
                                color: isDarkMode
                                    ? AppColors.darkCardBackground
                                    : AppColors.lightCardBackground,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16.r)),
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                      vertical: 16.h, horizontal: 24.w),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.check_circle,
                                        color: isDarkMode
                                            ? AppColors.darkButtonPrimary
                                            : AppColors.lightButtonPrimary,
                                        size: 28.sp,
                                      ),
                                      SizedBox(width: 12.w),
                                      Text(
                                        'تم الحجز بنجاح',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium
                                            ?.copyWith(
                                              color: isDarkMode
                                                  ? AppColors.darkTextPrimary
                                                  : AppColors.lightTextPrimary,
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
