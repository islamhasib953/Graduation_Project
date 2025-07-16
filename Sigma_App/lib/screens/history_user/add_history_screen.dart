import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/cubits/history_state.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/utils/colors.dart';
import 'package:universal_io/io.dart' as io;
import 'package:flutter/foundation.dart';

class AddHistoryScreen extends StatefulWidget {
  final String childId;

  const AddHistoryScreen({super.key, required this.childId});

  @override
  State<AddHistoryScreen> createState() => _AddHistoryScreenState();
}

class _AddHistoryScreenState extends State<AddHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final diagnosisController = TextEditingController();
  final diseaseController = TextEditingController();
  final treatmentController = TextEditingController();
  final notesController = TextEditingController();
  final timeController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool _isLoading = false;
  String? _errorMessage;
  dynamic _selectedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    timeController.text = DateFormat('hh:mm a').format(DateTime.now());
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
        timeController.text = DateFormat('hh:mm a').format(DateTime(2023, 1, 1, picked.hour, picked.minute));
      });
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Choose Image', style: Theme.of(context).textTheme.titleLarge),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo, color: Theme.of(context).iconTheme.color),
              title: Text('Gallery', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () async {
                Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
              },
            ),
            ListTile(
              leading: Icon(Icons.camera_alt, color: Theme.of(context).iconTheme.color),
              title: Text('Camera', style: Theme.of(context).textTheme.bodyLarge),
              onTap: () async {
                Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
              },
            ),
          ],
        ),
      ),
    );
    if (pickedFile != null) {
      if (io.Platform.isAndroid || io.Platform.isIOS) {
        setState(() {
          _selectedImage = io.File(pickedFile.path);
        });
      } else if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });
      }
    }
  }

  Future<void> _saveHistory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final newHistory = History(
      id: '',
      diagnosis: diagnosisController.text,
      disease: diseaseController.text,
      treatment: treatmentController.text,
      notes: notesController.text,
      notesImage: '',
      date: selectedDate,
      time: timeController.text.trim(),
      doctorName: 'Dr. Islam Hasib', // قيمة افتراضية لحد ما الـ Backend يرجع الاسم
    );

    try {
      await context.read<HistoryCubit>().addHistory(newHistory, widget.childId, _selectedImage, context);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to add history';
      });
    }
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isRequired = true}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        validator: (value) {
          if (isRequired && (value == null || value.isEmpty)) {
            return 'Required';
          }
          return null;
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistoryCubit, HistoryState>(
      listener: (context, state) {
        if (state is HistoryLoading) {
          setState(() {
            _isLoading = true;
            _errorMessage = null;
          });
        } else if (state is HistoryError) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Failed to add history';
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: Failed to add history',
                  style: Theme.of(context).textTheme.bodyMedium),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is HistoryLoaded) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('History record added successfully',
                  style: Theme.of(context).textTheme.bodyMedium),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Add New Record',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.all(16.w),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50.r,
                    backgroundImage: _selectedImage != null
                        ? (kIsWeb || _selectedImage is Uint8List
                            ? MemoryImage(_selectedImage as Uint8List)
                            : FileImage(_selectedImage as io.File))
                        : null,
                    child: _selectedImage == null
                        ? Icon(Icons.add_a_photo, size: 40.sp, color: Theme.of(context).iconTheme.color)
                        : null,
                  ),
                ),
                SizedBox(height: 20.h),
                _buildInputField('Diagnosis', diagnosisController),
                _buildInputField('Disease', diseaseController),
                _buildInputField('Treatment', treatmentController),
                _buildInputField('Notes', notesController, isRequired: false),
                GestureDetector(
                  onTap: _selectTime,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          timeController.text.isEmpty ? 'Select Time' : timeController.text,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Icon(Icons.access_time, color: Theme.of(context).iconTheme.color),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).dividerColor),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
                      ],
                    ),
                  ),
                ),
                if (_errorMessage != null)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                    child: Text(
                      _errorMessage!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.error,
                          ),
                    ),
                  ),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                        ),
                        onPressed: _saveHistory,
                        child: Text(
                          'Save',
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    diagnosisController.dispose();
    diseaseController.dispose();
    treatmentController.dispose();
    notesController.dispose();
    timeController.dispose();
    super.dispose();
  }
}