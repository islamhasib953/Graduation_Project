import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/vaccination_cubit.dart';
import 'package:segma/models/vaccination_model.dart';
import 'package:segma/screens/vaccination_user/vaccination_screen.dart';
import 'package:segma/services/vaccination_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segma/utils/colors.dart';

class LogVaccinationScreen extends StatefulWidget {
  final Vaccination vaccination;
  final String childId;

  const LogVaccinationScreen({
    super.key,
    required this.vaccination,
    required this.childId,
  });

  @override
  State<LogVaccinationScreen> createState() => _LogVaccinationScreenState();
}

class _LogVaccinationScreenState extends State<LogVaccinationScreen>
    with SingleTickerProviderStateMixin {
  bool _isTaken = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _notes = '';
  String? _imageUrl;

  bool _isSubmitting = false;
  bool _showSuccessDialog = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    _loadVaccinationData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVaccinationData() async {
    final result = await VaccinationService.getVaccinationById(widget.childId, widget.vaccination.userVaccinationId);
    print('Vaccination Data Response: $result');
    if (result['status'] == 'success' && mounted) {
      final Vaccination vaccination = result['data'];
      if (mounted) {
        setState(() {
          _isTaken = vaccination.status == 'Taken';
          _selectedDate = vaccination.actualDate ?? DateTime.now();
          _selectedTime = vaccination.actualDate != null
              ? TimeOfDay.fromDateTime(vaccination.actualDate!)
              : TimeOfDay.now();
          _notes = vaccination.notes ?? '';
          _imageUrl = vaccination.image;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate && mounted) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime && mounted) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null && mounted) {
        setState(() => _imageUrl = 'https://example.com/path-to-image.jpg');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e'), backgroundColor: AppColors.statusOverdue),
        );
      }
    }
  }

  void _resetFields() {
    if (mounted) {
      setState(() {
        _isTaken = false; // إعادة تعيين لقيمة افتراضية
        _selectedDate = DateTime.now();
        _selectedTime = TimeOfDay.now();
        _notes = '';
        _imageUrl = null;
      });
    }
  }
Future<void> _submitVaccination() async {
  if (_isSubmitting) return;

  setState(() => _isSubmitting = true);
  final actualDate = DateTime(
    _selectedDate.year,
    _selectedDate.month,
    _selectedDate.day,
    _selectedTime.hour,
    _selectedTime.minute,
  );

  final cubit = context.read<VaccinationCubit>();
  final response = await cubit.logVaccination(
    childId: widget.childId,
    userVaccinationId: widget.vaccination.userVaccinationId,
    status: _isTaken ? 'Taken' : 'Missed',
    actualDate: actualDate,
    notes: _notes,
    image: _imageUrl,
  );

  setState(() => _isSubmitting = false);
  if (mounted) {
    if (response['status'] == 'success') {
      // Navigate directly to VaccinationScreen after success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const VaccinationScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update vaccination: ${response['message']}')),
      );
    }
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.light
          ? AppColors.lightBackground
          : AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: Theme.of(context).brightness == Brightness.light
            ? AppColors.lightBackground
            : AppColors.darkBackground,
        elevation: 0,
        title: Text(
          'Log Vaccination',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightTextPrimary
                    : AppColors.darkTextPrimary,
                fontSize: 20.sp,
              ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.vaccination.disease,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      widget.vaccination.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'STATUS',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _isTaken,
                          onChanged: (value) {
                            if (mounted) setState(() => _isTaken = true);
                          },
                          activeColor: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightButtonPrimary
                              : AppColors.darkButtonPrimary,
                          checkColor: Colors.white,
                        ),
                        Text(
                          'Taken',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16.sp,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                        ),
                        SizedBox(width: 20.w),
                        Checkbox(
                          value: !_isTaken,
                          onChanged: (value) {
                            if (mounted) setState(() => _isTaken = false);
                          },
                          activeColor: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightButtonPrimary
                              : AppColors.darkButtonPrimary,
                          checkColor: Colors.white,
                        ),
                        Text(
                          'Missed',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontSize: 16.sp,
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.lightTextPrimary
                                    : AppColors.darkTextPrimary,
                              ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Date',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightCardBackground
                              : AppColors.darkCardBackground,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('d-MMM-yyyy').format(_selectedDate),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16.sp,
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? AppColors.lightTextPrimary
                                        : AppColors.darkTextPrimary,
                                  ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightIcon
                                  : AppColors.darkIcon,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    GestureDetector(
                      onTap: () => _selectTime(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightCardBackground
                              : AppColors.darkCardBackground,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedTime.format(context),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16.sp,
                                    color: Theme.of(context).brightness == Brightness.light
                                        ? AppColors.lightTextPrimary
                                        : AppColors.darkTextPrimary,
                                  ),
                            ),
                            Icon(
                              Icons.access_time,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightIcon
                                  : AppColors.darkIcon,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Add Note Here',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    TextField(
                      onChanged: (value) {
                        if (mounted) setState(() => _notes = value);
                      },
                      controller: TextEditingController(text: _notes),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextPrimary
                                : AppColors.darkTextPrimary,
                          ),
                      decoration: InputDecoration(
                        hintText: 'Enter your notes here',
                        hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                            ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.r),
                          borderSide: BorderSide(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightButtonPrimary
                                : AppColors.darkButtonPrimary,
                          ),
                        ),
                      ),
                      maxLines: 3,
                    ),
                    SizedBox(height: 20.h),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightTextSecondary
                                : AppColors.darkTextSecondary,
                          ),
                          borderRadius: BorderRadius.circular(8.r),
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightCardBackground
                              : AppColors.darkCardBackground,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _imageUrl == null ? 'Add a photo' : 'Photo Added',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 16.sp,
                                    color: _imageUrl == null
                                        ? (Theme.of(context).brightness == Brightness.light
                                            ? AppColors.lightTextSecondary
                                            : AppColors.darkTextSecondary)
                                        : (Theme.of(context).brightness == Brightness.light
                                            ? AppColors.lightTextPrimary
                                            : AppColors.darkTextPrimary),
                                  ),
                            ),
                            Icon(
                              Icons.add_circle,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightButtonPrimary
                                  : AppColors.darkButtonPrimary,
                              size: 24.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_imageUrl != null) ...[
                      SizedBox(height: 10.h),
                      Text(
                        'Selected Image URL: $_imageUrl',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              fontSize: 14.sp,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightTextPrimary
                                  : AppColors.darkTextPrimary,
                            ),
                      ),
                    ],
                    SizedBox(height: 30.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) async {
                            _animationController.reverse();
                            await _submitVaccination();
                          },
                          onTapCancel: () => _animationController.reverse(),
                          child: ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.lightButtonPrimary
                                    : AppColors.darkButtonPrimary,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _isSubmitting
                                  ? SizedBox(
                                      width: 20.w,
                                      height: 20.h,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      'Confirm',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: Colors.white,
                                            fontSize: 16.sp,
                                          ),
                                    ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20.w),
                        GestureDetector(
                          onTapDown: (_) => _animationController.forward(),
                          onTapUp: (_) {
                            _animationController.reverse();
                            _resetFields();
                          },
                          onTapCancel: () => _animationController.reverse(),
                          child: ScaleTransition(
                            scale: _buttonScaleAnimation,
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.light
                                    ? AppColors.lightTextSecondary
                                    : AppColors.darkTextSecondary,
                                borderRadius: BorderRadius.circular(8.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'Reset',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontSize: 16.sp,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (_showSuccessDialog)
                Center(
                  child: GestureDetector(
                    onTap: () {
                      if (mounted) setState(() => _showSuccessDialog = false);
                    },
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      margin: EdgeInsets.symmetric(horizontal: 20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 50.sp,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'Vaccination updated successfully!',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontSize: 18.sp,
                                  color: Theme.of(context).brightness == Brightness.light
                                      ? AppColors.lightTextPrimary
                                      : AppColors.darkTextPrimary,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 20.h),
                          ElevatedButton(
                            onPressed: () {
                              if (mounted) {
                                setState(() => _showSuccessDialog = false);
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VaccinationScreen(),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightButtonPrimary
                                  : AppColors.darkButtonPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            child: Text(
                              'Back to Vaccinations',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
