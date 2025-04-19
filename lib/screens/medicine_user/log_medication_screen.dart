import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/medication_cubit.dart';
import 'package:segma/models/medication_model.dart';
import 'package:intl/intl.dart';

class LogMedicationScreen extends StatefulWidget {
  final Medication? existingMedication;
  final int? index;
  final String childId;

  const LogMedicationScreen({
    super.key,
    this.existingMedication,
    this.index,
    required this.childId,
  });

  @override
  _LogMedicationScreenState createState() => _LogMedicationScreenState();
}

class _LogMedicationScreenState extends State<LogMedicationScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late List<String> selectedDays;
  late List<DateTime> times;
  late int selectedTimes;
  bool _isLoading = false;
  String? _childIdError;
  String? _formError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descriptionController = TextEditingController();
    selectedDays = [];
    times = [];
    selectedTimes = 0;

    if (widget.childId.isEmpty) {
      _childIdError = 'No child selected. Please select a child first.';
    }

    if (widget.existingMedication != null) {
      _nameController.text = widget.existingMedication!.name;
      _descriptionController.text = widget.existingMedication!.description;
      selectedDays = List.from(widget.existingMedication!.days);
      times = List.from(widget.existingMedication!.times);
      selectedTimes = times.length;
    }
  }

  void _handleDaySelection(String day, bool selected) {
    setState(() {
      if (selected) {
        selectedDays.add(day);
      } else {
        selectedDays.remove(day);
      }
    });
  }

  Future<void> _selectTime(int index) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      final selectedTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      setState(() {
        if (index < times.length) {
          times[index] = selectedTime;
        } else {
          times.add(selectedTime);
        }
      });
    }
  }

  Future<void> _saveMedication() async {
    if (_nameController.text.isEmpty) {
      setState(() {
        _formError = 'Please enter the medication name.';
      });
      return;
    }
    if (selectedDays.isEmpty) {
      setState(() {
        _formError = 'Please select at least one day.';
      });
      return;
    }
    if (times.isEmpty) {
      setState(() {
        _formError = 'Please select at least one time.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _formError = null;
    });

    final medication = Medication(
      id: widget.existingMedication?.id ?? '',
      name: _nameController.text,
      description: _descriptionController.text,
      days: selectedDays,
      times: times,
      date: DateTime.now(),
    );

    final medicationCubit = context.read<MedicationCubit>();

    if (widget.existingMedication == null) {
      await medicationCubit.addMedication(
        medication,
        childId: widget.childId,
      );
    } else {
      await medicationCubit.updateMedication(
        widget.index!,
        medication,
        childId: widget.childId,
      );
    }

    setState(() => _isLoading = false);

    if (medicationCubit.error == null) {
      await medicationCubit.fetchMedications(widget.childId);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingMedication == null
                ? 'Medication added successfully'
                : 'Medication updated successfully',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      if (medicationCubit.error!.toLowerCase().contains('token') ||
          medicationCubit.error!.toLowerCase().contains('unauthorized')) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      setState(() {
        _formError = medicationCubit.error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_childIdError != null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            'Log Medication',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Theme.of(context).primaryColor,
                ),
          ),
          backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _childIdError!,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.error,
                    ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  'Go Back',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Log Medication',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_formError != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: Text(
                    _formError!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              _buildNameField(),
              SizedBox(height: 20.h),
              _buildDescriptionField(),
              SizedBox(height: 20.h),
              _buildDaysSelection(),
              SizedBox(height: 20.h),
              _buildTimesPerDay(),
              SizedBox(height: 20.h),
              _buildTimeInputs(),
              SizedBox(height: 20.h),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNameField() {
    return TextField(
      controller: _nameController,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
      decoration: InputDecoration(
        labelText: 'Medication Name',
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return TextField(
      controller: _descriptionController,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).primaryColor,
          ),
      maxLines: 3,
      decoration: InputDecoration(
        labelText: 'Description',
        labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).primaryColor,
            ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
        ),
      ),
    );
  }

  Widget _buildDaysSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Days:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
        ),
        Wrap(
          spacing: 8.w,
          children: [
            'Saturday',
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday'
          ]
              .map((day) => FilterChip(
                    label: Text(
                      day,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                    ),
                    selected: selectedDays.contains(day),
                    selectedColor: Theme.of(context).primaryColor,
                    checkmarkColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).disabledColor,
                    onSelected: (selected) => _handleDaySelection(day, selected),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildTimesPerDay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Times per Day:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
        ),
        DropdownButton<int>(
          value: selectedTimes,
          items: List.generate(5, (index) => index)
              .map((count) => DropdownMenuItem(
                    value: count,
                    child: Text(
                      count == 0 ? 'Select' : '$count time${count > 1 ? 's' : ''}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).primaryColor,
                          ),
                    ),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              selectedTimes = value!;
              times = List.generate(selectedTimes, (index) => times.length > index ? times[index] : DateTime.now());
            });
          },
        ),
      ],
    );
  }

  Widget _buildTimeInputs() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Times:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
              ),
        ),
        ...List.generate(selectedTimes, (index) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 5.h),
            child: GestureDetector(
              onTap: () => _selectTime(index),
              child: Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text(
                  times.length > index ? DateFormat.jm().format(times[index]) : 'Select Time',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).primaryColor,
                      ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).disabledColor,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveMedication,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              padding: EdgeInsets.symmetric(vertical: 15.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Theme.of(context).colorScheme.onPrimary)
                : Text(
                    'Save',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}