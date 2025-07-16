


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:intl/intl.dart';

import 'package:segma/utils/colors.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  _DoctorAvailabilityScreenState createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  // قائمة الأيام المتاحة
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> selectedDays = [];

  // قائمة الأوقات المتاحة
  List<String> availableTimes = [];

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentAvailability();
  }

  // دالة لجلب المواعيد الحالية
  Future<void> _fetchCurrentAvailability() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await DoctorService.getDoctorProfile();
      if (response['status'] == 'success') {
        final data = response['data'];
        setState(() {
          selectedDays = List<String>.from(data['availableDays'] ?? []);
          availableTimes = List<String>.from(data['availableTimes'] ?? []);
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load current availability');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading availability: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // دالة لإضافة وقت جديد
  Future<void> _addTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        final isLightTheme = Theme.of(context).brightness == Brightness.light;
        return Theme(
          data: isLightTheme
              ? ThemeData.light().copyWith(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.lightButtonPrimary,
                    onPrimary: Colors.white,
                    surface: AppColors.lightCardBackground,
                    onSurface: AppColors.lightTextPrimary,
                  ),
                )
              : ThemeData.dark().copyWith(
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.darkButtonPrimary,
                    onPrimary: Colors.white,
                    surface: AppColors.darkCardBackground,
                    onSurface: AppColors.darkTextPrimary,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // تحويل الوقت إلى صيغة 12 ساعة (مثل 2:00 PM)
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final formattedTime = DateFormat('h:mm a').format(dateTime);

      setState(() {
        if (!availableTimes.contains(formattedTime)) {
          availableTimes.add(formattedTime);
        }
      });
    }
  }

  // دالة لتحديث المواعيد عبر الـ API
  Future<void> _updateAvailability() async {
    if (selectedDays.isEmpty || availableTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day and one time.'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await DoctorService.updateDoctorAvailability({
        'availableDays': selectedDays,
        'availableTimes': availableTimes,
      });

      if (response['status'] == 'success' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Availability updated successfully'),
            backgroundColor: AppColors.statusUpcoming,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to update availability');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLightTheme = Theme.of(context).brightness == Brightness.light;
    final backgroundColor = isLightTheme ? AppColors.lightBackground : AppColors.darkBackground;
    final cardBackgroundColor = isLightTheme ? AppColors.lightCardBackground : AppColors.darkCardBackground;
    final textPrimaryColor = isLightTheme ? AppColors.lightTextPrimary : AppColors.darkTextPrimary;
    final textSecondaryColor = isLightTheme ? AppColors.lightTextSecondary : AppColors.darkTextSecondary;
    final buttonPrimaryColor = isLightTheme ? AppColors.lightButtonPrimary : AppColors.darkButtonPrimary;
    final iconColor = isLightTheme ? AppColors.lightIcon : AppColors.darkIcon;
    final searchBackgroundColor = isLightTheme ? AppColors.lightSearchBackground : AppColors.darkSearchBackground;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [backgroundColor, cardBackgroundColor],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: isLoading
                ? Center(child: CircularProgressIndicator(color: buttonPrimaryColor))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: iconColor, size: 24.sp),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Set Your Availability',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: textPrimaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48.w),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // قسم الأيام
                      Text(
                        'Select Available Days',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Card(
                        elevation: 4,
                        color: cardBackgroundColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8.w,
                              mainAxisSpacing: 8.h,
                              childAspectRatio: 1,
                            ),
                            itemCount: daysOfWeek.length,
                            itemBuilder: (context, index) {
                              final day = daysOfWeek[index];
                              final isSelected = selectedDays.contains(day);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedDays.remove(day);
                                    } else {
                                      selectedDays.add(day);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? buttonPrimaryColor : searchBackgroundColor,
                                  ),
                                  child: Center(
                                    child: Text(
                                      day.substring(0, 3),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: isSelected ? Colors.white : textPrimaryColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // قسم الأوقات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Times',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: textPrimaryColor,
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: _addTime,
                            mini: true,
                            backgroundColor: buttonPrimaryColor,
                            child: Icon(Icons.add, size: 24.sp, color: Colors.white),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          color: cardBackgroundColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: availableTimes.isEmpty
                                ? Center(
                                    child: Text(
                                      'No times added yet',
                                      style: TextStyle(fontSize: 16.sp, color: textSecondaryColor),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: availableTimes.length,
                                    itemBuilder: (context, index) {
                                      final time = availableTimes[index];
                                      return ListTile(
                                        leading: Icon(Icons.access_time, color: iconColor, size: 24.sp),
                                        title: Text(
                                          time,
                                          style: TextStyle(fontSize: 16.sp, color: textPrimaryColor),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete, color: AppColors.statusOverdue, size: 24.sp),
                                          onPressed: () {
                                            setState(() {
                                              availableTimes.removeAt(index);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // زر التأكيد
                          Center(
                            child: isLoading
                                ? CircularProgressIndicator(color: buttonPrimaryColor)
                                : ElevatedButton(
                                    onPressed: _updateAvailability,
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      elevation: 0, // Removed elevation to eliminate shadow
                                      backgroundColor: Colors.transparent,
                                    ).copyWith(
                                      foregroundColor: WidgetStateProperty.all(Colors.white),
                                      backgroundColor: WidgetStateProperty.all(Colors.transparent),
                                      overlayColor: WidgetStateProperty.all(Colors.white24),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [buttonPrimaryColor, AppColors.statusUpcoming],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
                                      child: Text(
                                        'Save Availability',
                                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
