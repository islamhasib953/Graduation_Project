import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/models/history_model.dart';
import 'package:intl/intl.dart';

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
  final notesImageController = TextEditingController();
  final doctorNameController = TextEditingController(text: 'Dr. Islam Hasib');
  DateTime selectedDate = DateTime.now();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _selectDate(BuildContext context) async {
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
      notesImage: notesImageController.text,
      date: selectedDate,
      time: timeController.text,
      doctorName: doctorNameController.text,
    );

    await context.read<HistoryCubit>().addHistory(newHistory, widget.childId);

    final error = context.read<HistoryCubit>().error;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('History record added successfully', style: Theme.of(context).textTheme.bodyMedium),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error', style: Theme.of(context).textTheme.bodyMedium),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Widget _buildInputField(String label, TextEditingController controller, {bool isRequired = true}) {
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
        validator: isRequired ? (value) => value!.isEmpty ? 'Required' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              _buildInputField('Diagnosis', diagnosisController),
              _buildInputField('Disease', diseaseController),
              _buildInputField('Treatment', treatmentController),
              _buildInputField('Notes', notesController),
              _buildInputField('Time (e.g., 10:00 AM)', timeController),
              _buildInputField('Doctor Name', doctorNameController),
              _buildInputField('Notes Image URL (optional)', notesImageController, isRequired: false),
              GestureDetector(
                onTap: () => _selectDate(context),
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
    );
  }

  @override
  void dispose() {
    diagnosisController.dispose();
    diseaseController.dispose();
    treatmentController.dispose();
    notesController.dispose();
    timeController.dispose();
    notesImageController.dispose();
    doctorNameController.dispose();
    super.dispose();
  }
}