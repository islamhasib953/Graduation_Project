// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:segma/cubits/history_cubit.dart';
// import 'package:segma/models/history_model.dart';
// import 'package:segma/services/doctor_service.dart';
// import 'package:segma/utils/colors.dart';

// class LogDiagnosisScreen extends StatefulWidget {
//   final String childId;
//   final History? history;

//   const LogDiagnosisScreen({Key? key, required this.childId, this.history})
//       : super(key: key);

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
//   bool _isPickImagePressed = false;
//   bool _isSubmitPressed = false;

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
//         return day.isBefore(DateTime.now().add(const Duration(days: 1)));
//       },
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor,
//               onPrimary: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
//               surface: Theme.of(context).scaffoldBackgroundColor,
//               onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
//             ),
//           ),
//           child: child!,
//         );
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
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: ColorScheme.light(
//               primary: Theme.of(context).primaryColor,
//               onPrimary: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white,
//               surface: Theme.of(context).scaffoldBackgroundColor,
//               onSurface: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   Future<void> _submitDiagnosis() async {
//     if (!_formKey.currentState!.validate()) return;
//     if (_selectedDate == null || _selectedTime == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please select date and time'),
//           backgroundColor: AppColors.statusOverdue,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     final history = History(
//       id: widget.history?.id ?? '',
//       diagnosis: _diagnosisController.text,
//       disease: _diseaseController.text,
//       treatment: _treatmentController.text,
//       notes: _notesController.text,
//       notesImage: _notesImage?.path ?? widget.history?.notesImage ?? '',
//       date: _selectedDate!,
//       time: DateFormat('HH:mm').format(DateTime(
//         _selectedDate!.year,
//         _selectedDate!.month,
//         _selectedDate!.day,
//         _selectedTime!.hour,
//         _selectedTime!.minute,
//       )),
//       doctorName: _doctorName ?? 'Dr. Unknown',
//     );

//     try {
//       if (widget.history == null) {
//         await context.read<HistoryCubit>().addHistory(history, widget.childId);
//       } else {
//         await context.read<HistoryCubit>().updateHistory(history, widget.childId);
//       }
//       if (context.read<HistoryCubit>().error == null) {
//         Navigator.pop(context);
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(widget.history == null ? 'Diagnosis added' : 'Diagnosis updated'),
//             backgroundColor: AppColors.statusUpcoming,
//           ),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: ${context.read<HistoryCubit>().error}'),
//             backgroundColor: AppColors.statusOverdue,
//           ),
//         );
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Error: $e'),
//           backgroundColor: AppColors.statusOverdue,
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   void dispose() {
//     _diagnosisController.dispose();
//     _diseaseController.dispose();
//     _treatmentController.dispose();
//     _notesController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           widget.history == null ? 'Add Diagnosis' : 'Update Diagnosis',
//           style: Theme.of(context).textTheme.titleLarge,
//         ),
//         backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
//         elevation: 0,
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.r),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               _buildTextField('Diagnosis', _diagnosisController, 'Enter diagnosis'),
//               _buildTextField('Disease', _diseaseController, 'Enter disease'),
//               _buildTextField('Treatment', _treatmentController, 'Enter treatment'),
//               _buildTextField('Notes', _notesController, 'Enter notes', maxLines: 4),
//               SizedBox(height: 16.h),
//               _buildDateTimeField('Date', _selectedDate, () => _selectDate(context)),
//               _buildDateTimeField('Time', _selectedTime, () => _selectTime(context)),
//               SizedBox(height: 16.h),
//               Card(
//                 elevation: 2,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.r),
//                 ),
//                 color: Theme.of(context).cardColor,
//                 child: Padding(
//                   padding: EdgeInsets.all(12.r),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Notes Image',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       SizedBox(height: 8.h),
//                       _notesImage != null
//                           ? ClipRRect(
//                               borderRadius: BorderRadius.circular(8.r),
//                               child: Image.file(
//                                 _notesImage!,
//                                 height: 150.h,
//                                 width: double.infinity,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                           : widget.history?.notesImage.isNotEmpty ?? false
//                               ? ClipRRect(
//                                   borderRadius: BorderRadius.circular(8.r),
//                                   child: Image.network(
//                                     widget.history!.notesImage,
//                                     height: 150.h,
//                                     width: double.infinity,
//                                     fit: BoxFit.cover,
//                                     errorBuilder: (context, error, stackTrace) => Container(
//                                       height: 150.h,
//                                       color: Theme.of(context).dividerColor,
//                                       child: Center(
//                                         child: Text(
//                                           'Error loading image',
//                                           style: Theme.of(context).textTheme.bodyMedium,
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 )
//                               : Container(
//                                   height: 150.h,
//                                   width: double.infinity,
//                                   color: Theme.of(context).dividerColor,
//                                   child: Center(
//                                     child: Text(
//                                       'No image selected',
//                                       style: Theme.of(context).textTheme.bodyMedium,
//                                     ),
//                                   ),
//                                 ),
//                       SizedBox(height: 8.h),
//                       Center(
//                         child: StatefulBuilder(
//                           builder: (context, setState) {
//                             return GestureDetector(
//                               onTapDown: (_) => setState(() => _isPickImagePressed = true),
//                               onTapUp: (_) {
//                                 setState(() => _isPickImagePressed = false);
//                                 _pickImage();
//                               },
//                               onTapCancel: () => setState(() => _isPickImagePressed = false),
//                               child: AnimatedScale(
//                                 scale: _isPickImagePressed ? 0.95 : 1.0,
//                                 duration: const Duration(milliseconds: 100),
//                                 child: ElevatedButton(
//                                   onPressed: _pickImage,
//                                   style: ElevatedButton.styleFrom(
//                                     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
//                                     backgroundColor: Theme.of(context).primaryColor,
//                                   ),
//                                   child: Text(
//                                     'Pick Image',
//                                     style: Theme.of(context).textTheme.bodyLarge,
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               _isLoading
//                   ? CircularProgressIndicator(
//                       color: Theme.of(context).primaryColor,
//                     )
//                   : StatefulBuilder(
//                       builder: (context, setState) {
//                         return GestureDetector(
//                           onTapDown: (_) => setState(() => _isSubmitPressed = true),
//                           onTapUp: (_) {
//                             setState(() => _isSubmitPressed = false);
//                             _submitDiagnosis();
//                           },
//                           onTapCancel: () => setState(() => _isSubmitPressed = false),
//                           child: AnimatedScale(
//                             scale: _isSubmitPressed ? 0.95 : 1.0,
//                             duration: const Duration(milliseconds: 100),
//                             child: ElevatedButton(
//                               onPressed: _submitDiagnosis,
//                               style: ElevatedButton.styleFrom(
//                                 padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
//                                 minimumSize: Size(double.infinity, 48.h),
//                                 backgroundColor: Theme.of(context).primaryColor,
//                               ),
//                               child: Text(
//                                 widget.history == null ? 'Add Diagnosis' : 'Update Diagnosis',
//                                 style: Theme.of(context).textTheme.bodyLarge,
//                               ),
//                             ),
//                           ),
//                         );
//                       },
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: TextFormField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: label,
//           hintText: hint,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8.r),
//           ),
//           filled: true,
//           fillColor: Theme.of(context).dividerColor,
//           contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//         ),
//         style: Theme.of(context).textTheme.bodyLarge,
//         maxLines: maxLines,
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return 'Error: $label is required';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildDateTimeField(String label, dynamic value, VoidCallback onTap) {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 8.h),
//       child: InkWell(
//         onTap: onTap,
//         child: InputDecorator(
//           decoration: InputDecoration(
//             labelText: label,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(8.r),
//             ),
//             filled: true,
//             fillColor: Theme.of(context).dividerColor,
//             contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//           ),
//           child: Text(
//             value == null
//                 ? 'Select $label'
//                 : label == 'Date'
//                     ? DateFormat('dd MMM, yyyy').format(value as DateTime)
//                     : (value as TimeOfDay).format(context),
//             style: Theme.of(context).textTheme.bodyLarge,
//           ),
//         ),
//       ),
//     );
//   }
// }



import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/utils/colors.dart';

class LogDiagnosisScreen extends StatefulWidget {
  final String childId;
  final History? history;

  const LogDiagnosisScreen({Key? key, required this.childId, this.history}) : super(key: key);

  @override
  _LogDiagnosisScreenState createState() => _LogDiagnosisScreenState();
}

class _LogDiagnosisScreenState extends State<LogDiagnosisScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosisController = TextEditingController();
  final _diseaseController = TextEditingController();
  final _treatmentController = TextEditingController();
  final _notesController = TextEditingController();
  File? _notesImage;
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

  Future<void> _submitDiagnosis() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select a date and time')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final history = History(
      id: widget.history?.id ?? '',
      diagnosis: _diagnosisController.text,
      disease: _diseaseController.text,
      treatment: _treatmentController.text,
      notes: _notesController.text,
      notesImage: _notesImage?.path ?? widget.history?.notesImage ?? '',
      date: _selectedDate!,
      time: DateFormat('HH:mm').format(DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      )),
      doctorName: _doctorName ?? 'Dr. Unknown',
    );

    try {
      if (widget.history == null) {
        await context.read<HistoryCubit>().addHistory(history, widget.childId);
      } else {
        await context.read<HistoryCubit>().updateHistory(history, widget.childId);
      }
      if (context.read<HistoryCubit>().error == null) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.history == null ? 'Diagnosis added successfully' : 'Diagnosis updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${context.read<HistoryCubit>().error}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _diagnosisController.dispose();
    _diseaseController.dispose();
    _treatmentController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.history == null ? 'Add Diagnosis' : 'Update Diagnosis',
          style: TextStyle(fontSize: 18.sp),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField('Diagnosis', _diagnosisController, 'Enter diagnosis'),
              _buildTextField('Disease', _diseaseController, 'Enter disease'),
              _buildTextField('Treatment', _treatmentController, 'Enter treatment'),
              _buildTextField('Notes', _notesController, 'Enter notes', maxLines: 4),
              SizedBox(height: 16.h),
              _buildDateTimeField('Date', _selectedDate, () => _selectDate(context)),
              _buildDateTimeField('Time', _selectedTime, () => _selectTime(context)),
              SizedBox(height: 16.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                child: Padding(
                  padding: EdgeInsets.all(12.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes Image',
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8.h),
                      _notesImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8.r),
                              child: Image.file(
                                _notesImage!,
                                height: 150.h,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            )
                          : widget.history?.notesImage.isNotEmpty ?? false
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: Image.network(
                                    widget.history!.notesImage,
                                    height: 150.h,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      height: 150.h,
                                      color: AppColors.lightCardBackground,
                                      child: Center(child: Text('Error loading image', style: TextStyle(fontSize: 12.sp))),
                                    ),
                                  ),
                                )
                              : Container(
                                  height: 150.h,
                                  width: double.infinity,
                                  color: AppColors.lightCardBackground,
                                  child: Center(child: Text('No image selected', style: TextStyle(fontSize: 12.sp))),
                                ),
                      SizedBox(height: 8.h),
                      Center(
                        child: ElevatedButton(
                          onPressed: _pickImage,
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          ),
                          child: Text('Pick Image', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              _isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitDiagnosis,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                        minimumSize: Size(double.infinity, 48.h),
                      ),
                      child: Text(
                        widget.history == null ? 'Add Diagnosis' : 'Update Diagnosis',
                        style: TextStyle(fontSize: 16.sp),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, String hint, {int maxLines = 1}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          filled: true,
          fillColor: AppColors.lightSearchBackground,
          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        ),
        style: TextStyle(fontSize: 14.sp),
        maxLines: maxLines,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateTimeField(String label, dynamic value, VoidCallback onTap) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            fillColor: AppColors.lightSearchBackground,
            contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          ),
          child: Text(
            value == null
                ? 'Select $label'
                : label == 'Date'
                    ? DateFormat('dd MMM, yyyy').format(value as DateTime)
                    : (value as TimeOfDay).format(context),
            style: TextStyle(fontSize: 14.sp),
          ),
        ),
      ),
    );
  }
}