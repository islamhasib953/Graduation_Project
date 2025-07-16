// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:segma/cubits/history_cubit.dart';
// import 'package:segma/cubits/history_state.dart';
// import 'package:segma/models/history_model.dart';
// import 'package:segma/utils/colors.dart';

// class EditHistoryScreen extends StatefulWidget {
//   final History history;
//   final String childId;

//   const EditHistoryScreen({super.key, required this.history, required this.childId});

//   @override
//   State<EditHistoryScreen> createState() => _EditHistoryScreenState();
// }

// class _EditHistoryScreenState extends State<EditHistoryScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController diagnosisController;
//   late final TextEditingController diseaseController;
//   late final TextEditingController treatmentController;
//   late final TextEditingController notesController;
//   late final TextEditingController timeController;
//   late final TextEditingController notesImageController;
//   late final TextEditingController doctorNameController;
//   late DateTime selectedDate;
//   bool _isLoading = false;
//   String? _errorMessage;
//   bool _isButtonPressed = false;
//   File? _notesImage; // إضافة متغير لتخزين الصورة المختارة

//   @override
//   void initState() {
//     super.initState();
//     diagnosisController = TextEditingController(text: widget.history.diagnosis);
//     diseaseController = TextEditingController(text: widget.history.disease);
//     treatmentController = TextEditingController(text: widget.history.treatment);
//     notesController = TextEditingController(text: widget.history.notes);
//     timeController = TextEditingController(text: widget.history.time);
//     notesImageController = TextEditingController(text: widget.history.notesImage);
//     // doctorNameController = TextEditingController(text: widget.history.doctorName);
//     selectedDate = widget.history.date;
//     _notesImage = widget.history.notesImage.isNotEmpty ? null : null; // تهيئة الصورة إذا كانت موجودة
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _notesImage = File(pickedFile.path);
//         notesImageController.text = ''; // مسح URL الصورة القديمة إذا تم اختيار صورة جديدة
//       });
//     }
//   }

//   Future<void> _clearImage() async {
//     setState(() {
//       _notesImage = null;
//       notesImageController.text = ''; // مسح الصورة إذا تم اختيار الحذف
//     });
//   }


// Future<void> _updateHistory() async {
//   if (!_formKey.currentState!.validate()) return;

//   setState(() {
//     _isLoading = true;
//     _errorMessage = null;
//   });

//   final updatedHistory = widget.history.copyWith(
//     diagnosis: diagnosisController.text,
//     disease: diseaseController.text,
//     treatment: treatmentController.text,
//     notes: notesController.text,
//     notesImage: _notesImage != null ? _notesImage!.path : (notesImageController.text.isEmpty ? '' : notesImageController.text),
//     date: selectedDate,
//     time: timeController.text,
//     doctorName: doctorNameController.text,
//   );

//   await context.read<HistoryCubit>().updateHistory(updatedHistory, widget.childId); // إزالة _notesImage

// }

// // ... (الكود اللاحق بدون تغيير)

//   Widget _buildInputField(String label, TextEditingController controller, {bool isRequired = true}) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8.h),
//       child: TextFormField(
//         controller: controller,
//         style: Theme.of(context).textTheme.bodyLarge,
//         decoration: InputDecoration(
//           labelText: label,
//           enabledBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).dividerColor),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderSide: BorderSide(color: Theme.of(context).primaryColor),
//           ),
//         ),
//         validator: isRequired ? (value) => value!.isEmpty ? 'This field is required' : null : null,
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return BlocListener<HistoryCubit, HistoryState>(
//       listener: (context, state) {
//         if (state is HistoryLoading) {
//           setState(() {
//             _isLoading = true;
//             _errorMessage = null;
//           });
//         } else if (state is HistoryError) {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = state.error;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: ${_errorMessage ?? state.error}'),
//               backgroundColor: AppColors.statusOverdue,
//             ),
//           );
//         } else if (state is HistoryUpdated) {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = null;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: const Text('History updated successfully'),
//               backgroundColor: AppColors.statusUpcoming,
//             ),
//           );
//           Navigator.pop(context);
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             'Edit Record',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 _buildInputField('Diagnosis', diagnosisController),
//                 _buildInputField('Disease', diseaseController),
//                 _buildInputField('Treatment', treatmentController),
//                 _buildInputField('Notes', notesController),
//                 _buildInputField('Time', timeController),
//                 _buildInputField('Doctor Name', doctorNameController),
//                 _buildInputField('Notes Image URL', notesImageController, isRequired: false),
//                 GestureDetector(
//                   onTap: () => _selectDate(context),
//                   child: Container(
//                     margin: EdgeInsets.symmetric(vertical: 8.h),
//                     padding: EdgeInsets.all(12.w),
//                     decoration: BoxDecoration(
//                       border: Border.all(color: Theme.of(context).dividerColor),
//                       borderRadius: BorderRadius.circular(10.r),
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                         const Icon(Icons.calendar_today),
//                       ],
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: EdgeInsets.symmetric(vertical: 8.h),
//                   child: Row(
//                     children: [
//                       Expanded(
//                         child: TextFormField(
//                           controller: notesImageController,
//                           enabled: false, // جعل الحقل غير قابل للتعديل يدويًا
//                           decoration: InputDecoration(
//                             labelText: 'Notes Image URL',
//                             enabledBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).dividerColor),
//                             ),
//                             focusedBorder: OutlineInputBorder(
//                               borderSide: BorderSide(color: Theme.of(context).primaryColor),
//                             ),
//                           ),
//                         ),
//                       ),
//                       IconButton(
//                         icon: Icon(Icons.image),
//                         onPressed: _pickImage, // زر لاختيار صورة جديدة
//                       ),
//                       if (notesImageController.text.isNotEmpty || _notesImage != null)
//                         IconButton(
//                           icon: Icon(Icons.delete),
//                           onPressed: _clearImage, // زر لحذف الصورة
//                         ),
//                     ],
//                   ),
//                 ),
//                 if (_errorMessage != null)
//                   Padding(
//                     padding: EdgeInsets.symmetric(vertical: 10.h),
//                     child: Text(
//                       _errorMessage!,
//                       style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                             color: AppColors.statusOverdue,
//                           ),
//                     ),
//                   ),
//                 _isLoading
//                     ? Center(
//                         child: CircularProgressIndicator(
//                           color: Theme.of(context).primaryColor,
//                         ),
//                       )
//                     : GestureDetector(
//                         onTapDown: (_) => setState(() => _isButtonPressed = true),
//                         onTapUp: (_) => setState(() => _isButtonPressed = false),
//                         onTapCancel: () => setState(() => _isButtonPressed = false),
//                         child: AnimatedScale(
//                           scale: _isButtonPressed ? 0.95 : 1.0,
//                           duration: const Duration(milliseconds: 100),
//                           child: ElevatedButton(
//                             onPressed: _updateHistory,
//                             child: const Text('Update Record'),
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     diagnosisController.dispose();
//     diseaseController.dispose();
//     treatmentController.dispose();
//     notesController.dispose();
//     timeController.dispose();
//     notesImageController.dispose();
//     doctorNameController.dispose();
//     super.dispose();
//   }
// }


import 'dart:convert';
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
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isButtonPressed = false;
  Uint8List? _webImageBytes; // لتخزين الصورة كـ Uint8List في الـ Web
  File? _notesImage; // لتخزين الصورة كـ File في الـ Mobile

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    diagnosisController = TextEditingController(text: widget.history.diagnosis);
    diseaseController = TextEditingController(text: widget.history.disease);
    treatmentController = TextEditingController(text: widget.history.treatment);
    notesController = TextEditingController(text: widget.history.notes);
    timeController = TextEditingController(text: widget.history.time);
    selectedDate = widget.history.date;
    selectedTime = TimeOfDay.fromDateTime(DateFormat("hh:mm a").parse(widget.history.time));
    if (kIsWeb && widget.history.notesImage.isNotEmpty) {
      _loadImageAsBytes(widget.history.notesImage);
    }
  }

  Future<void> _loadImageAsBytes(String imageUrl) async {
    try {
      final response = await http.get(Uri.parse(imageUrl)).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        setState(() {
          _webImageBytes = response.bodyBytes;
        });
      } else {
        print('Failed to load image, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading image: $e');
    }
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

  Future<void> _selectTime(BuildContext context) async {
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
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _webImageBytes = bytes;
          _notesImage = null;
        });
      } else {
        setState(() {
          _notesImage = File(pickedFile.path);
          _webImageBytes = null;
        });
      }
    }
  }

  Future<void> _showFullImage() async {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (_notesImage != null || _webImageBytes != null)
                ? Image(
                    image: _notesImage != null
                        ? FileImage(_notesImage!) as ImageProvider
                        : MemoryImage(_webImageBytes!),
                    fit: BoxFit.contain,
                  )
                : Image.network(
                    widget.history.notesImage,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(child: Text('Error loading image')),
                  ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
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
      notesImage: _notesImage?.path ?? (kIsWeb && _webImageBytes != null ? 'data:image/png;base64,${base64Encode(_webImageBytes!)}' : widget.history.notesImage),
      date: selectedDate,
      time: timeController.text,
    );

    try {
      final result = await context.read<HistoryCubit>().updateHistory(updatedHistory, widget.childId, _notesImage);
      if (result['status'] == 'success') {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('History updated successfully'),
            backgroundColor: AppColors.statusUpcoming,
          ),
        );
        if (mounted) {
          Navigator.of(context, rootNavigator: true).pop(context); // استخدام rootNavigator وتحقق من mounted
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['message'] ?? 'Failed to update history';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Technical error: $e';
      });
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

  Widget _buildImageCard(String label, String imageUrl) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: Theme.of(context).cardColor,
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: Stack(
                children: [
                  SizedBox(
                    height: 150.h,
                    width: double.infinity,
                    child: (_notesImage != null || _webImageBytes != null)
                        ? GestureDetector(
                            onTap: _showFullImage,
                            child: Image(
                              image: _notesImage != null
                                  ? FileImage(_notesImage!) as ImageProvider
                                  : MemoryImage(_webImageBytes!),
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Theme.of(context).dividerColor,
                                child: const Center(child: Text('Error loading image')),
                              ),
                            ),
                          )
                        : GestureDetector(
                            onTap: _showFullImage,
                            child: Image.network(
                              imageUrl,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Theme.of(context).dividerColor,
                                child: const Center(child: Text('Error loading image')),
                              ),
                            ),
                          ),
                  ),
                  if (_notesImage != null || _webImageBytes != null || imageUrl.isNotEmpty)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: _pickImage,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
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
            _errorMessage = state.error;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${_errorMessage ?? state.error}'),
              backgroundColor: AppColors.statusOverdue,
            ),
          );
        } else if (state is HistoryUpdated) {
          setState(() {
            _isLoading = false;
            _errorMessage = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('History updated successfully'),
              backgroundColor: AppColors.statusUpcoming,
            ),
          );
          // if (mounted) {
          //   Future.delayed(const Duration(milliseconds: 500), () {
          //     Navigator.of(context, rootNavigator: true).pop(context); // تأخير مع تحقق من mounted
          //   });
          // }
        }
      },
      child: Scaffold(
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
                GestureDetector(
                  onTap: () => _selectTime(context),
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
                        Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
                      ],
                    ),
                  ),
                ),
                if (widget.history.notesImage.isNotEmpty || _notesImage != null || _webImageBytes != null)
                  _buildImageCard('Notes Image', widget.history.notesImage),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    border: Border.all(color: Theme.of(context).dividerColor),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Doctor Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      Text(widget.history.doctorName ?? 'Dr. Islam Hasib', style: Theme.of(context).textTheme.bodyLarge),
                    ],
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
                            child: const Text('Update Record'),
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