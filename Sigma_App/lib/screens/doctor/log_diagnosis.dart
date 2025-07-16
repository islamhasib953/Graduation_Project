// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:segma/cubits/history_cubit.dart' as historyCubit; // Use alias for cubit
// import 'package:segma/cubits/history_state.dart'; // Use the state file directly
// import 'package:segma/models/history_model.dart';
// import 'package:segma/services/doctor_service.dart';
// import 'package:segma/utils/colors.dart';

// class LogDiagnosisScreen extends StatefulWidget {
//   final String childId;
//   final History? history;

//   const LogDiagnosisScreen({Key? key, required this.childId, this.history}) : super(key: key);

//   @override
//   _LogDiagnosisScreenState createState() => _LogDiagnosisScreenState();
// }

// class _LogDiagnosisScreenState extends State<LogDiagnosisScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _diagnosisController = TextEditingController();
//   final _diseaseController = TextEditingController();
//   final _treatmentController = TextEditingController();
//   final _notesController = TextEditingController();
//   File? _notesImage;
//   bool _isLoading = false;
//   String? _doctorName;
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;

//   @override
//   void initState() {
//     super.initState();
//     if (widget.history != null) {
//       _diagnosisController.text = widget.history!.diagnosis;
//       _diseaseController.text = widget.history!.disease;
//       _treatmentController.text = widget.history!.treatment;
//       _notesController.text = widget.history!.notes;
//       _selectedDate = widget.history!.date;
//       _selectedTime = _parseTime(widget.history!.time);
//     } else {
//       _selectedDate = DateTime.now();
//       _selectedTime = TimeOfDay.now();
//     }
//     _fetchDoctorName();
//   }

//   Future<void> _fetchDoctorName() async {
//     try {
//       final response = await DoctorService.getDoctorProfile();
//       if (response['status'] == 'success') {
//         setState(() {
//           final firstName = response['data']['firstName'] ?? '';
//           final lastName = response['data']['lastName'] ?? '';
//           _doctorName = 'Dr. $firstName $lastName'.trim();
//           if (_doctorName!.isEmpty) _doctorName = 'Dr. Unknown';
//         });
//       }
//     } catch (e) {
//       setState(() {
//         _doctorName = 'Dr. Unknown';
//       });
//     }
//   }

//   TimeOfDay? _parseTime(String time) {
//     try {
//       final parts = time.split(':');
//       final hour = int.parse(parts[0]);
//       final minute = int.parse(parts[1]);
//       return TimeOfDay(hour: hour, minute: minute);
//     } catch (e) {
//       return null;
//     }
//   }

//   Future<void> _pickImage() async {
//     final picker = ImagePicker();
//     final pickedFile = await picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       setState(() {
//         _notesImage = File(pickedFile.path);
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//       selectableDayPredicate: (DateTime day) {
//         return day.isBefore(DateTime.now().add(Duration(days: 1)));
//       },
//     );
//     if (picked != null && picked != _selectedDate) {
//       setState(() {
//         _selectedDate = picked;
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   Future<void> _saveOrUpdateHistory() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() {
//       _isLoading = true;
//     });

//     final String time = _selectedTime != null
//         ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
//         : DateFormat('HH:mm').format(DateTime.now());

//     // Placeholder for image URL (since uploadImage is not defined)
//     String notesImageUrl = widget.history?.notesImage ?? '';
//     if (_notesImage != null) {
//       // Placeholder: Assuming the image path is used directly (replace with actual upload logic)
//       notesImageUrl = _notesImage!.path;
//       // TODO: Implement actual image upload logic here and update notesImageUrl
//       // For example: notesImageUrl = await DoctorService.uploadImage(_notesImage!);
//     }

//     final newHistory = History(
//       id: widget.history?.id ?? '',
//       diagnosis: _diagnosisController.text,
//       disease: _diseaseController.text,
//       treatment: _treatmentController.text,
//       notes: _notesController.text,
//       notesImage: notesImageUrl,
//       date: _selectedDate ?? DateTime.now(),
//       time: time,
//       doctorName: _doctorName ?? 'Dr. Unknown',
//     );

//     try {
//       if (widget.history == null) {
//         await context.read<historyCubit.HistoryCubit>().addHistory(newHistory, widget.childId);
//       } else {
//         await context.read<historyCubit.HistoryCubit>().updateHistory(newHistory, widget.childId);
//       }
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   Widget _buildInputField(String label, TextEditingController controller, {bool isRequired = true}) {
//     return Container(
//       margin: EdgeInsets.symmetric(vertical: 8.h),
//       child: TextFormField(
//         controller: controller,
//         style: Theme.of(context).textTheme.bodyLarge,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: Theme.of(context).textTheme.bodyMedium,
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
//     return BlocListener<historyCubit.HistoryCubit, HistoryState>(
//       listener: (context, state) {
//         if (state is HistoryLoading) {
//           setState(() {
//             _isLoading = true;
//           });
//         } else if (state is HistoryError) {
//           setState(() {
//             _isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text('Error: ${state.error}', style: Theme.of(context).textTheme.bodyMedium),
//               backgroundColor: Theme.of(context).colorScheme.error,
//             ),
//           );
//         } else if (state is HistoryLoaded || state is HistoryUpdated) {
//           setState(() {
//             _isLoading = false;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//               content: Text(
//                 widget.history == null
//                     ? 'Diagnosis logged successfully'
//                     : 'Diagnosis updated successfully',
//                 style: Theme.of(context).textTheme.bodyMedium,
//               ),
//               backgroundColor: Colors.green,
//             ),
//           );
//           Navigator.pop(context);
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(
//             widget.history == null ? 'Log Diagnosis' : 'Edit Diagnosis',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//           elevation: 0,
//         ),
//         body: Padding(
//           padding: EdgeInsets.all(16.w),
//           child: Form(
//             key: _formKey,
//             child: ListView(
//               children: [
//                 _buildInputField('Diagnosis', _diagnosisController),
//                 _buildInputField('Disease', _diseaseController),
//                 _buildInputField('Treatment', _treatmentController),
//                 _buildInputField('Notes', _notesController),
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
//                           _selectedDate != null
//                               ? 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
//                               : 'Select Date',
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                         Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
//                       ],
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: () => _selectTime(context),
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
//                           _selectedTime != null
//                               ? 'Time: ${_selectedTime!.format(context)}'
//                               : 'Select Time',
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                         Icon(Icons.access_time, color: Theme.of(context).iconTheme.color),
//                       ],
//                     ),
//                   ),
//                 ),
//                 GestureDetector(
//                   onTap: _pickImage,
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
//                           _notesImage != null
//                               ? 'Image Selected'
//                               : widget.history?.notesImage.isNotEmpty ?? false
//                                   ? 'Image Uploaded'
//                                   : 'Upload Notes Image',
//                           style: Theme.of(context).textTheme.bodyLarge,
//                         ),
//                         Icon(Icons.image, color: Theme.of(context).iconTheme.color),
//                       ],
//                     ),
//                   ),
//                 ),
//                 _isLoading
//                     ? const Center(child: CircularProgressIndicator())
//                     : ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).primaryColor,
//                           padding: EdgeInsets.symmetric(vertical: 16.h),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10.r),
//                           ),
//                         ),
//                         onPressed: _saveOrUpdateHistory,
//                         child: Text(
//                           widget.history == null ? 'Log Diagnosis' : 'Update Diagnosis',
//                           style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
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
//     _diagnosisController.dispose();
//     _diseaseController.dispose();
//     _treatmentController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/history_cubit.dart' as historyCubit; // Use alias for cubit
import 'package:segma/cubits/history_state.dart'; // Use the state file directly
import 'package:segma/models/history_model.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/utils/colors.dart';

class LogDiagnosisScreen extends StatefulWidget {
  final String childId;
  final History? history;

  const LogDiagnosisScreen({super.key, required this.childId, this.history});

  @override
  _LogDiagnosisScreenState createState() => _LogDiagnosisScreenState();
}

class _LogDiagnosisScreenState extends State<LogDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  File? _notesImage; // إضافة متغير لتخزين الصورة المختارة
  bool _isLoading = false;
  String? _doctorName;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    if (widget.history != null) {
      _diagnosisController.text = widget.history!.diagnosis;
      _diseaseController.text = widget.history!.disease;
      _treatmentController.text = widget.history!.treatment;
      _notesController.text = widget.history!.notes;
      _selectedDate = widget.history!.date;
      _selectedTime = _parseTime(widget.history!.time);
    } else {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
    }
    _fetchDoctorName();
  }

  Future<void> _fetchDoctorName() async {
    try {
      final response = await DoctorService.getDoctorProfile();
      if (response['status'] == 'success') {
        setState(() {
          final firstName = response['data']['firstName'] ?? '';
          final lastName = response['data']['lastName'] ?? '';
          _doctorName = 'Dr. $firstName $lastName'.trim();
          if (_doctorName!.isEmpty) _doctorName = 'Dr. Unknown';
        });
      }
    } catch (e) {
      setState(() {
        _doctorName = 'Dr. Unknown';
      });
    }
  }

  TimeOfDay? _parseTime(String time) {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);
      return TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      return null;
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _notesImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      selectableDayPredicate: (DateTime day) {
        return day.isBefore(DateTime.now().add(Duration(days: 1)));
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // ... (الكود السابق بدون تغيير حتى _saveOrUpdateHistory)

Future<void> _saveOrUpdateHistory() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() {
    _isLoading = true;
  });

  final String time = _selectedTime != null
      ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
      : DateFormat('HH:mm').format(DateTime.now());

  final newHistory = History(
    id: widget.history?.id ?? '',
    diagnosis: _diagnosisController.text,
    disease: _diseaseController.text,
    treatment: _treatmentController.text,
    notes: _notesController.text,
    notesImage: widget.history?.notesImage ?? '', // يتم التعامل مع الصورة عبر HistoryService
    date: _selectedDate ?? DateTime.now(),
    time: time,
    doctorName: _doctorName ?? 'Dr. Unknown',
  );

  try {
    if (widget.history == null) {
      await context.read<historyCubit.HistoryCubit>().addHistory(newHistory, widget.childId); // إزالة _notesImage
    } else {
      await context.read<historyCubit.HistoryCubit>().updateHistory(newHistory, widget.childId); // إزالة _notesImage
    }
  } finally {
    setState(() {
      _isLoading = false;
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
          labelStyle: Theme.of(context).textTheme.bodyMedium,
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
    return BlocListener<historyCubit.HistoryCubit, HistoryState>(
      listener: (context, state) {
        if (state is HistoryLoading) {
          setState(() {
            _isLoading = true;
          });
        } else if (state is HistoryError) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${state.error}', style: Theme.of(context).textTheme.bodyMedium),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        } else if (state is HistoryLoaded || state is HistoryUpdated) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.history == null
                    ? 'Diagnosis logged successfully'
                    : 'Diagnosis updated successfully',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.history == null ? 'Log Diagnosis' : 'Edit Diagnosis',
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
                _buildInputField('Diagnosis', _diagnosisController),
                _buildInputField('Disease', _diseaseController),
                _buildInputField('Treatment', _treatmentController),
                _buildInputField('Notes', _notesController),
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
                          _selectedDate != null
                              ? 'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}'
                              : 'Select Date',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Icon(Icons.calendar_today, color: Theme.of(context).iconTheme.color),
                      ],
                    ),
                  ),
                ),
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
                          _selectedTime != null
                              ? 'Time: ${_selectedTime!.format(context)}'
                              : 'Select Time',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Icon(Icons.access_time, color: Theme.of(context).iconTheme.color),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: _pickImage, // زر لاختيار صورة
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
                          _notesImage != null
                              ? 'Image Selected'
                              : widget.history?.notesImage.isNotEmpty ?? false
                                  ? 'Image Uploaded'
                                  : 'Upload Notes Image',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Icon(Icons.image, color: Theme.of(context).iconTheme.color),
                      ],
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
                        onPressed: _saveOrUpdateHistory,
                        child: Text(
                          widget.history == null ? 'Log Diagnosis' : 'Update Diagnosis',
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
    _diagnosisController.dispose();
    _diseaseController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}