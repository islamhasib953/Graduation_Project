// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/cubits/vaccination_cubit.dart';
// import 'package:segma/models/vaccination_model.dart';
// import 'package:segma/services/vaccination_service.dart';
// import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';

// class LogVaccinationScreen extends StatefulWidget {
//   final Vaccination vaccination;
//   final String childId;

//   const LogVaccinationScreen({
//     super.key,
//     required this.vaccination,
//     required this.childId,
//   });

//   @override
//   State<LogVaccinationScreen> createState() => _LogVaccinationScreenState();
// }

// class _LogVaccinationScreenState extends State<LogVaccinationScreen> {
//   bool _isTaken = true;
//   DateTime _selectedDate = DateTime.now();
//   TimeOfDay _selectedTime = TimeOfDay.now();
//   String _notes = '';
//   String? _imageUrl;

//   // متغيرات لحفظ القيم الأصلية من الـ Backend
//   bool? _initialIsTaken;
//   DateTime? _initialDate;
//   TimeOfDay? _initialTime;
//   String? _initialNotes;
//   String? _initialImageUrl;

//   @override
//   void initState() {
//     super.initState();
//     _loadVaccinationData();
//   }

//   Future<void> _loadVaccinationData() async {
//     // جلب بيانات التطعيم المحدد باستخدام الـ API المخصص
//     final result = await VaccinationService.getVaccinationById(widget.childId, widget.vaccination.userVaccinationId);
//     print('Vaccination Data Response: $result'); // طباعة البيانات في الـ Terminal

//     if (result['status'] == 'success') {
//       final Vaccination vaccination = result['data'];

//       setState(() {
//         // تهيئة الحقول بالقيم من الـ Backend
//         _isTaken = vaccination.status == 'Taken';
//         _initialIsTaken = _isTaken;

//         if (vaccination.actualDate != null) {
//           _selectedDate = vaccination.actualDate!;
//           _selectedTime = TimeOfDay.fromDateTime(vaccination.actualDate!);
//           _initialDate = _selectedDate;
//           _initialTime = _selectedTime;
//         } else {
//           _initialDate = null;
//           _initialTime = null;
//         }

//         _notes = vaccination.notes ?? '';
//         _initialNotes = _notes;

//         _imageUrl = vaccination.image;
//         _initialImageUrl = _imageUrl;
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
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
//       initialTime: _selectedTime,
//     );
//     if (picked != null && picked != _selectedTime) {
//       setState(() {
//         _selectedTime = picked;
//       });
//     }
//   }

//   Future<void> _pickImage() async {
//     try {
//       final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
//       if (pickedFile != null) {
//         setState(() {
//           _imageUrl = 'https://example.com/path-to-image.jpg'; // رابط افتراضي
//         });
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error picking image: $e')),
//       );
//     }
//   }

//   void _resetFields() {
//     setState(() {
//       // إعادة الحقول للقيم الأصلية
//       _isTaken = _initialIsTaken ?? true;
//       _selectedDate = _initialDate ?? DateTime.now();
//       _selectedTime = _initialTime ?? TimeOfDay.now();
//       _notes = _initialNotes ?? '';
//       _imageUrl = _initialImageUrl;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         backgroundColor: Colors.black,
//         elevation: 0,
//         title: const Text(
//           'Log Vaccination',
//           style: TextStyle(color: Colors.white, fontSize: 20),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               widget.vaccination.disease,
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18.sp,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             Text(
//               widget.vaccination.description,
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14.sp,
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               'STATUS',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14.sp,
//               ),
//             ),
//             Row(
//               children: [
//                 Checkbox(
//                   value: _isTaken,
//                   onChanged: (value) {
//                     setState(() {
//                       _isTaken = true;
//                     });
//                   },
//                   activeColor: Colors.blue,
//                 ),
//                 Text(
//                   'Taken',
//                   style: TextStyle(color: Colors.white, fontSize: 16.sp),
//                 ),
//                 SizedBox(width: 20.w),
//                 Checkbox(
//                   value: !_isTaken,
//                   onChanged: (value) {
//                     setState(() {
//                       _isTaken = false;
//                     });
//                   },
//                   activeColor: Colors.blue,
//                 ),
//                 Text(
//                   'Missed',
//                   style: TextStyle(color: Colors.white, fontSize: 16.sp),
//                 ),
//               ],
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               'Date',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14.sp,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             GestureDetector(
//               onTap: () => _selectDate(context),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       DateFormat('d-MMM-yyyy').format(_selectedDate),
//                       style: TextStyle(color: Colors.white, fontSize: 16.sp),
//                     ),
//                     const Icon(Icons.calendar_today, color: Colors.white),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               'Time',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14.sp,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             GestureDetector(
//               onTap: () => _selectTime(context),
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       _selectedTime.format(context),
//                       style: TextStyle(color: Colors.white, fontSize: 16.sp),
//                     ),
//                     const Icon(Icons.access_time, color: Colors.white),
//                   ],
//                 ),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             Text(
//               'Add Note Here',
//               style: TextStyle(
//                 color: Colors.grey,
//                 fontSize: 14.sp,
//               ),
//             ),
//             SizedBox(height: 8.h),
//             TextField(
//               onChanged: (value) {
//                 _notes = value;
//               },
//               controller: TextEditingController(text: _notes),
//               style: const TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Enter your notes here',
//                 hintStyle: const TextStyle(color: Colors.grey),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                   borderSide: const BorderSide(color: Colors.grey),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(8.r),
//                   borderSide: const BorderSide(color: Colors.blue),
//                 ),
//               ),
//               maxLines: 3,
//             ),
//             SizedBox(height: 20.h),
//             GestureDetector(
//               onTap: _pickImage,
//               child: Container(
//                 padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.grey),
//                   borderRadius: BorderRadius.circular(8.r),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       _imageUrl == null ? 'Add a photo' : 'Photo Added',
//                       style: TextStyle(
//                         color: _imageUrl == null ? Colors.grey : Colors.white,
//                         fontSize: 16.sp,
//                       ),
//                     ),
//                     Icon(
//                       Icons.add_circle,
//                       color: Colors.blue,
//                       size: 24.sp,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             if (_imageUrl != null) ...[
//               SizedBox(height: 10.h),
//               Text(
//                 'Selected Image URL: $_imageUrl',
//                 style: TextStyle(color: Colors.white, fontSize: 14.sp),
//               ),
//             ],
//             SizedBox(height: 30.h),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 ElevatedButton(
//                   onPressed: () {
//                     final actualDate = DateTime(
//                       _selectedDate.year,
//                       _selectedDate.month,
//                       _selectedDate.day,
//                       _selectedTime.hour,
//                       _selectedTime.minute,
//                     );

//                     context.read<VaccinationCubit>().logVaccination(
//                           childId: widget.childId,
//                           userVaccinationId: widget.vaccination.userVaccinationId,
//                           status: _isTaken ? 'Taken' : 'Missed',
//                           actualDate: actualDate,
//                           notes: _notes,
//                           image: _imageUrl,
//                         );

//                     Navigator.pop(context);
//                   },
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.blue,
//                     padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                   ),
//                   child: Text(
//                     'Confirm',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                     ),
//                   ),
//                 ),
//                 SizedBox(width: 20.w),
//                 ElevatedButton(
//                   onPressed: _resetFields,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.grey,
//                     padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.r),
//                     ),
//                   ),
//                   child: Text(
//                     'Reset',
//                     style: TextStyle(
//                       color: Colors.white,
//                       fontSize: 16.sp,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/vaccination_cubit.dart';
import 'package:segma/models/vaccination_model.dart';
import 'package:segma/services/vaccination_service.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class LogVaccinationScreen extends StatefulWidget {
  final Vaccination vaccination;
  final String childId;

  const LogVaccinationScreen({
    super.key,
    required this.vaccination,
    required this.childId,
  });

  @override
  State<LogVaccinationScreen> createState() => _LogVaccinationScreenState();
}

class _LogVaccinationScreenState extends State<LogVaccinationScreen> {
  bool _isTaken = true;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _notes = '';
  String? _imageUrl;

  @override
  void initState() {
    super.initState();
    _loadVaccinationData();
  }

  Future<void> _loadVaccinationData() async {
    // جلب بيانات التطعيم المحدد باستخدام الـ API المخصص
    final result = await VaccinationService.getVaccinationById(widget.childId, widget.vaccination.userVaccinationId);
    print('Vaccination Data Response: $result'); // طباعة البيانات في الـ Terminal

    if (result['status'] == 'success') {
      final Vaccination vaccination = result['data'];

      setState(() {
        // تهيئة الحقول بالقيم من الـ Backend
        _isTaken = vaccination.status == 'Taken';

        if (vaccination.actualDate != null) {
          _selectedDate = vaccination.actualDate!;
          _selectedTime = TimeOfDay.fromDateTime(vaccination.actualDate!);
        }

        _notes = vaccination.notes ?? '';
        _imageUrl = vaccination.image;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
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

  Future<void> _selectTime(BuildContext context) async {
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

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageUrl = 'https://example.com/path-to-image.jpg'; // رابط افتراضي
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: const Text(
          'Log Vaccination',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.vaccination.disease,
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              widget.vaccination.description,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'STATUS',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
            Row(
              children: [
                Checkbox(
                  value: _isTaken,
                  onChanged: (value) {
                    setState(() {
                      _isTaken = true;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                Text(
                  'Taken',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
                SizedBox(width: 20.w),
                Checkbox(
                  value: !_isTaken,
                  onChanged: (value) {
                    setState(() {
                      _isTaken = false;
                    });
                  },
                  activeColor: Colors.blue,
                ),
                Text(
                  'Missed',
                  style: TextStyle(color: Colors.white, fontSize: 16.sp),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              'Date',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('d-MMM-yyyy').format(_selectedDate),
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.white),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Time',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            GestureDetector(
              onTap: () => _selectTime(context),
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    const Icon(Icons.access_time, color: Colors.white),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Add Note Here',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14.sp,
              ),
            ),
            SizedBox(height: 8.h),
            TextField(
              onChanged: (value) {
                _notes = value;
              },
              controller: TextEditingController(text: _notes),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Enter your notes here',
                hintStyle: const TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
              ),
              maxLines: 3,
            ),
            SizedBox(height: 20.h),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _imageUrl == null ? 'Add a photo' : 'Photo Added',
                      style: TextStyle(
                        color: _imageUrl == null ? Colors.grey : Colors.white,
                        fontSize: 16.sp,
                      ),
                    ),
                    Icon(
                      Icons.add_circle,
                      color: Colors.blue,
                      size: 24.sp,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    final actualDate = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );

                    context.read<VaccinationCubit>().logVaccination(
                          childId: widget.childId,
                          userVaccinationId: widget.vaccination.userVaccinationId,
                          status: _isTaken ? 'Taken' : 'Missed',
                          actualDate: actualDate,
                          notes: _notes,
                          image: _imageUrl,
                        );

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}