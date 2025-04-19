import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/services/child_service.dart';
import 'package:segma/utils/colors.dart';

class AddChildScreen extends StatefulWidget {
  const AddChildScreen({super.key});

  @override
  State<AddChildScreen> createState() => _AddChildScreenState();
}

class _AddChildScreenState extends State<AddChildScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _gender = 'Boy';
  DateTime _birthDate = DateTime.now();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String _bloodType = 'A+';
  bool _isLoading = false;
  String? _errorMessage;
  bool _isButtonPressed = false;

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final child = Child(
      id: '',
      name: _nameController.text,
      gender: _gender,
      birthDate: _birthDate,
      heightAtBirth: double.tryParse(_heightController.text) ?? 0,
      weightAtBirth: double.tryParse(_weightController.text) ?? 0,
      bloodType: _bloodType,
      photo: null,
    );

    final response = await ChildService.addChild(child, context); // تمرير context

    setState(() {
      _isLoading = false;
    });

    if (response['status'] == 'success') {
      // تحديث SelectedChildCubit بمعرف الطفل الجديد
      final childId = response['data']['child']['_id'];
      context.read<SelectedChildCubit>().selectChild(childId);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Child added successfully'),
          backgroundColor: AppColors.statusUpcoming,
        ),
      );
      Navigator.pop(context, true);
    } else {
      setState(() {
        _errorMessage = response['message'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Child',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Name
              TextFormField(
                controller: _nameController,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  labelText: 'Name',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter child name';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              // Gender
              DropdownButtonFormField<String>(
                value: _gender,
                onChanged: (value) => setState(() => _gender = value!),
                items: [
                  DropdownMenuItem(
                    value: 'Boy',
                    child: Text('Boy', style: Theme.of(context).textTheme.bodyLarge),
                  ),
                  DropdownMenuItem(
                    value: 'Girl',
                    child: Text('Girl', style: Theme.of(context).textTheme.bodyLarge),
                  ),
                ],
                decoration: InputDecoration(
                  labelText: 'Gender',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Birth Date
              GestureDetector(
                onTap: () => _selectDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: TextEditingController(
                      text: DateFormat('yyyy-MM-dd').format(_birthDate),
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    decoration: InputDecoration(
                      labelText: 'Birth Date',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor),
                      ),
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) {
                      if (_birthDate.isAfter(DateTime.now())) {
                        return 'Birth date cannot be in the future';
                      }
                      return null;
                    },
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Height at Birth
              TextFormField(
                controller: _heightController,
                style: Theme.of(context).textTheme.bodyLarge,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Height at Birth (cm)',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter height';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              // Weight at Birth
              TextFormField(
                controller: _weightController,
                style: Theme.of(context).textTheme.bodyLarge,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight at Birth (kg)',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              // Blood Type
              DropdownButtonFormField<String>(
                value: _bloodType,
                onChanged: (value) => setState(() => _bloodType = value!),
                items: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type, style: Theme.of(context).textTheme.bodyLarge),
                        ))
                    .toList(),
                decoration: InputDecoration(
                  labelText: 'Blood Type',
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).primaryColor),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select blood type';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              // Error Message
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16.h),
                  child: Text(
                    _errorMessage!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.statusOverdue,
                        ),
                  ),
                ),
              // Add Button
              GestureDetector(
                onTapDown: (_) => setState(() => _isButtonPressed = true),
                onTapUp: (_) => setState(() => _isButtonPressed = false),
                onTapCancel: () => setState(() => _isButtonPressed = false),
                child: AnimatedScale(
                  scale: _isButtonPressed ? 0.95 : 1.0,
                  duration: const Duration(milliseconds: 100),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _addChild,
                    child: _isLoading
                        ? CircularProgressIndicator(
                            color: Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({}),
                          )
                        : Text('Add Child'),
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
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}