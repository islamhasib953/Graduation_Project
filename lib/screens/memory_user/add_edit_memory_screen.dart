import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segma/cubits/memory_cubit.dart';
import 'package:segma/models/memory_model.dart';
import 'package:intl/intl.dart';

class AddEditMemoryScreen extends StatefulWidget {
  final Memory? memory;
  final String childId;

  const AddEditMemoryScreen({Key? key, this.memory, required this.childId}) : super(key: key);

  @override
  _AddEditMemoryScreenState createState() => _AddEditMemoryScreenState();
}

class _AddEditMemoryScreenState extends State<AddEditMemoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final _descriptionController = TextEditingController();
  File? _image;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _animationController.forward();

    if (widget.memory != null) {
      _descriptionController.text = widget.memory!.description;
      _selectedDate = widget.memory!.date;
      _selectedTime = TimeOfDay(
        hour: int.parse(widget.memory!.time.split(':')[0]),
        minute: int.parse(widget.memory!.time.split(':')[1]),
      );
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveMemory() {
    print('Attempting to save memory...');
    if (_descriptionController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      print('Validation failed: Some fields are empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    print('Validation passed. Saving memory...');
    final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';

    if (widget.memory == null) {
      final newMemory = Memory(
        id: '',
        image: _image != null ? _image!.path : 'uploads/placeholder.jpg',
        description: _descriptionController.text,
        date: _selectedDate!,
        time: timeString,
        isFavorite: false,
      );
      print('Adding new memory: ${newMemory.description}');
      context.read<MemoryCubit>().addMemory(widget.childId, newMemory);
    } else {
      final updates = {
        'description': _descriptionController.text,
        'isFavorite': widget.memory!.isFavorite.toString(),
      };
      print('Updating memory: ${widget.memory!.id}');
      context.read<MemoryCubit>().updateMemory(widget.childId, widget.memory!.id, updates);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemoryCubit, MemoryState>(
      listener: (context, state) {
        if (state is MemorySuccess) {
          print('Memory operation successful: ${state.message}');
          showDialog(
            context: context,
            builder: (context) => ScaleTransition(
              scale: _scaleAnimation,
              child: AlertDialog(
                title: const Text('Success'),
                content: const Text('Memory Added Successfully!'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context); // Close the dialog
                      Navigator.pop(context); // Navigate back to MemoriesScreen
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
            ),
          );
        } else if (state is MemoryError) {
          print('Memory operation failed: ${state.message}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.memory == null ? 'Add Memory' : 'Edit Memory'),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    width: double.infinity,
                    height: 200.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: _image != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.r),
                            child: Image.file(
                              _image!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 200.h,
                            ),
                          )
                        : widget.memory != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: CachedNetworkImage(
                                  imageUrl: widget.memory!.image,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: 200.h,
                                  placeholder: (context, url) => Container(
                                    width: double.infinity,
                                    height: 200.h,
                                    color: Colors.grey[300],
                                    child: const Center(child: CircularProgressIndicator()),
                                  ),
                                  errorWidget: (context, url, error) => const Center(
                                    child: Icon(Icons.broken_image, size: 50),
                                  ),
                                ),
                              )
                            : Center(
                                child: Icon(
                                  Icons.add_a_photo,
                                  size: 50,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Date',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () => _selectDate(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                DateFormat('dd MMM yyyy').format(_selectedDate!),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Time',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                          ),
                          SizedBox(height: 8.h),
                          GestureDetector(
                            onTap: () => _selectTime(context),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              decoration: BoxDecoration(
                                border: Border.all(color: Theme.of(context).colorScheme.primary),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Text(
                                _selectedTime!.format(context),
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Add Note Here',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Save'),
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