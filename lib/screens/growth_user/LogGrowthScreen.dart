import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/growth_cubit.dart';

class LogGrowthScreen extends StatefulWidget {
  final String childId;

  const LogGrowthScreen({Key? key, required this.childId}) : super(key: key);

  @override
  _LogGrowthScreenState createState() => _LogGrowthScreenState();
}

class _LogGrowthScreenState extends State<LogGrowthScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _headCircumferenceController = TextEditingController();
  final _notesController = TextEditingController();
  String _notesImage = '';
  bool _isLoading = false;

  DateTime _selectedDate = DateTime.now(); // Store selected date
  TimeOfDay _selectedTime = TimeOfDay.now(); // Store selected time

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headCircumferenceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  // Show Date Picker
  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Show Time Picker
  Future<void> _pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveGrowthRecord() async {
    setState(() {
      _isLoading = true;
    });

    // Combine selected date and time into a single DateTime object
    final DateTime combinedDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final data = {
      'weight': double.tryParse(_weightController.text) ?? 0.0,
      'height': double.tryParse(_heightController.text) ?? 0.0,
      'headCircumference': double.tryParse(_headCircumferenceController.text) ?? 0.0,
      'date': combinedDateTime.toIso8601String(),
      'time': DateFormat('HH:mm').format(combinedDateTime),
      'notes': _notesController.text,
      'notesImage': _notesImage,
    };

    try {
      await context.read<GrowthCubit>().addGrowthRecord(data);
      setState(() {
        _isLoading = false;
      });

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Icon(Icons.check_circle, color: Colors.blue, size: 50),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Growth Activity Added', style: TextStyle(fontSize: 18.sp)),
                SizedBox(height: 8.h),
                Text('Your growth activity added', style: TextStyle(fontSize: 14.sp)),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                child: Text('Back to Home', style: TextStyle(fontSize: 14.sp, color: Colors.blue)),
              ),
            ],
          );
        },
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add growth record: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Growth', style: TextStyle(fontSize: 18.sp)),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Date', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _pickDate(context),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  DateFormat('dd-MMM-yyyy').format(_selectedDate),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('Time', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _pickTime(context),
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  _selectedTime.format(context),
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text('Weight', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: _weightController,
              decoration: InputDecoration(
                hintText: 'Enter weight in kg',
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            Text('Height', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(
                hintText: 'Enter height in cm',
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            Text('Head Circumference', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: _headCircumferenceController,
              decoration: InputDecoration(
                hintText: 'Enter head circumference in cm',
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            Text('Note', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Add Note Here',
                filled: true,
                fillColor: Colors.grey.shade800,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16.h),
            Text('Add a photo', style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () {
                setState(() {
                  _notesImage = '';
                });
              },
              child: Container(
                padding: EdgeInsets.all(12.r),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _notesImage.isEmpty ? 'Add a photo' : 'Photo Added',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    Icon(Icons.add_circle, color: Colors.blue),
                  ],
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Center(
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _saveGrowthRecord,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                        backgroundColor: Colors.blue,
                      ),
                      child: Text('Save', style: TextStyle(fontSize: 16.sp)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}