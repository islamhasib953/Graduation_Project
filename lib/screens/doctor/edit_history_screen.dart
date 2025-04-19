import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/utils/colors.dart';

class EditHistoryScreen extends StatefulWidget {
  final History history;
  final String childId;

  const EditHistoryScreen({super.key, required this.history, required this.childId});

  @override
  State<EditHistoryScreen> createState() => _EditHistoryScreenState();
}

class _EditHistoryScreenState extends State<EditHistoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController diagnosisController;
  late final TextEditingController diseaseController;
  late final TextEditingController treatmentController;
  late final TextEditingController notesController;
  late final TextEditingController timeController;
  late final TextEditingController notesImageController;
  late final TextEditingController doctorNameController;
  late DateTime selectedDate;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isButtonPressed = false;

  @override
  void initState() {
    super.initState();
    diagnosisController = TextEditingController(text: widget.history.diagnosis);
    diseaseController = TextEditingController(text: widget.history.disease);
    treatmentController = TextEditingController(text: widget.history.treatment);
    notesController = TextEditingController(text: widget.history.notes);
    timeController = TextEditingController(text: widget.history.time);
    notesImageController = TextEditingController(text: widget.history.notesImage);
    doctorNameController = TextEditingController(text: widget.history.doctorName);
    selectedDate = widget.history.date;
  }

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

  Future<void> _updateHistory() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final updatedHistory = widget.history.copyWith(
      diagnosis: diagnosisController.text,
      disease: diseaseController.text,
      treatment: treatmentController.text,
      notes: notesController.text,
      notesImage: notesImageController.text,
      date: selectedDate,
      time: timeController.text,
      doctorName: doctorNameController.text,
    );

    await context.read<HistoryCubit>().updateHistory(updatedHistory, widget.childId);

    final error = context.read<HistoryCubit>().error;
    setState(() {
      _isLoading = false;
      _errorMessage = error;
    });

    if (error == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('History updated successfully'),
            backgroundColor: AppColors.statusUpcoming,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $error'),
            backgroundColor: AppColors.statusOverdue,
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
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).dividerColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).primaryColor),
          ),
        ),
        validator: isRequired ? (value) => value!.isEmpty ? 'This field is required' : null : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Record',
          style: Theme.of(context).textTheme.titleLarge,
        ),
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
              _buildInputField('Time', timeController),
              _buildInputField('Doctor Name', doctorNameController),
              _buildInputField('Notes Image URL', notesImageController, isRequired: false),
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
                        'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.statusOverdue,
                        ),
                  ),
                ),
              _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(context).primaryColor,
                      ),
                    )
                  : GestureDetector(
                      onTapDown: (_) => setState(() => _isButtonPressed = true),
                      onTapUp: (_) => setState(() => _isButtonPressed = false),
                      onTapCancel: () => setState(() => _isButtonPressed = false),
                      child: AnimatedScale(
                        scale: _isButtonPressed ? 0.95 : 1.0,
                        duration: const Duration(milliseconds: 100),
                        child: ElevatedButton(
                          onPressed: _updateHistory,
                          child: Text('Update Record'),
                        ),
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