// import 'dart:io';
// import 'package:cached_network_image/cached_network_image.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:intl/intl.dart';
// import 'package:segma/cubits/memory_cubit.dart';
// import 'package:segma/models/memory_model.dart';
// import 'package:universal_io/io.dart' as io;
// import 'package:flutter/foundation.dart';

// class AddEditMemoryScreen extends StatefulWidget {
//   final Memory? memory;
//   final String childId;

//   const AddEditMemoryScreen({Key? key, this.memory, required this.childId}) : super(key: key);

//   @override
//   _AddEditMemoryScreenState createState() => _AddEditMemoryScreenState();
// }

// class _AddEditMemoryScreenState extends State<AddEditMemoryScreen> with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   final _descriptionController = TextEditingController();
//   DateTime? _selectedDate;
//   TimeOfDay? _selectedTime;
//   dynamic _selectedImage; // File أو Uint8List
//   final ImagePicker _picker = ImagePicker();
//   bool _isLoading = false;
//   String? _errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );
//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
//     );
//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
//     );
//     _animationController.forward();

//     if (widget.memory != null) {
//       _descriptionController.text = widget.memory!.description;
//       _selectedDate = widget.memory!.date;
//       _selectedTime = TimeOfDay(
//         hour: int.parse(widget.memory!.time.split(':')[0]),
//         minute: int.parse(widget.memory!.time.split(':')[1]),
//       );
//     } else {
//       _selectedDate = DateTime.now();
//       _selectedTime = TimeOfDay.now();
//     }
//     // print('InitState: Memory=${widget.memory?.id}, SelectedDate=$_selectedDate, SelectedTime=$_selectedTime');
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//     print('Disposed: Cleaned up controllers and animation');
//   }

//   Future<void> _pickImage() async {
//     print('Picking Image: Starting image selection process');
//     try {
//       final pickedFile = await showDialog<XFile?>(
//         context: context,
//         builder: (context) => AlertDialog(
//           title: Text('Choose Image', style: Theme.of(context).textTheme.titleLarge),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ListTile(
//                 leading: Icon(Icons.photo_library),
//                 title: Text('Gallery'),
//                 onTap: () async {
//                   Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
//                   print('Gallery selected');
//                 },
//               ),
//               ListTile(
//                 leading: Icon(Icons.camera_alt),
//                 title: Text('Camera'),
//                 onTap: () async {
//                   Navigator.pop(context, await _picker.pickImage(source: ImageSource.camera));
//                   print('Camera selected');
//                 },
//               ),
//             ],
//           ),
//         ),
//       );
//       if (pickedFile != null) {
//         print('Picked File: Path=${pickedFile.path}, Name=${pickedFile.name}');
//         if (io.Platform.isAndroid || io.Platform.isIOS) {
//           setState(() {
//             _selectedImage = io.File(pickedFile.path);
//             print('Set Image: File path=${pickedFile.path}');
//           });
//         } else if (kIsWeb) {
//           final bytes = await pickedFile.readAsBytes();
//           setState(() {
//             _selectedImage = bytes;
//             print('Set Image: Web bytes length=${bytes.length}');
//           });
//         }
//       } else {
//         print('No image picked');
//       }
//     } catch (e) {
//       print('Error picking image: $e');
//       setState(() {
//         _errorMessage = 'Failed to pick image: $e';
//       });
//     }
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     // print('Selecting Date: Current=$_selectedDate');
//     final picked = await showDatePicker(
//       context: context,
//       initialDate: _selectedDate ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() => _selectedDate = picked);
//       print('Selected Date: $picked');
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     // print('Selecting Time: Current=$_selectedTime');
//     final picked = await showTimePicker(
//       context: context,
//       initialTime: _selectedTime ?? TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() => _selectedTime = picked);
//       print('Selected Time: $picked');
//     }
//   }

// void _saveMemory() {
//   // print('Saving Memory: Description=${_descriptionController.text}, Date=$_selectedDate, Time=$_selectedTime, Image=$_selectedImage');
//   if (_descriptionController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
//     setState(() => _errorMessage = 'Please fill all fields');
//     print('Save Failed: Missing required fields');
//     return;
//   }

//   final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
//   final memory = Memory(
//     id: widget.memory?.id ?? '',
//     image: widget.memory?.image ?? '',
//     description: _descriptionController.text,
//     date: _selectedDate!,
//     time: timeString,
//     isFavorite: widget.memory?.isFavorite ?? false,
//   );

//   setState(() => _isLoading = true);
//   // print('Saving to Cubit: ChildId=${widget.childId}, Memory=$memory, Image=$_selectedImage');
//   if (widget.memory == null) {
//     context.read<MemoryCubit>().addMemory(widget.childId, memory, _selectedImage, context);
//   } else {
//     final updates = {
//       'description': _descriptionController.text,
//       'isFavorite': widget.memory!.isFavorite.toString(),
//       'image': widget.memory!.image,
//     };
//     context.read<MemoryCubit>().updateMemory(widget.childId, widget.memory!.id, updates, _selectedImage);
//   }
// }

//   // دالة لتحويل Uint8List إلى XFile مؤقتًا
//   XFile? _convertToXFile(dynamic image) {
//     if (image == null) return null;
//     if (image is io.File) {
//       print('Converting File to XFile: Path=${image.path}');
//       return XFile(image.path);
//     } else if (image is Uint8List) {
//       print('Converting Uint8List to XFile: Length=${image.length}');
//       // إنشاء ملف مؤقت لـ XFile على الـ web
//       final tempFile = XFile.fromData(image, name: 'temp_image.jpg', mimeType: 'image/jpeg');
//       return tempFile;
//     }
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     // print('Building Screen: IsLoading=$_isLoading, ErrorMessage=$_errorMessage, SelectedImage=$_selectedImage');
//     return BlocListener<MemoryCubit, MemoryState>(
//       listener: (context, state) {
//         print('BlocListener: State=$state');
//         if (state is MemoryLoading) {
//           setState(() => _isLoading = true);
//         } else if (state is MemorySuccess) {
//           setState(() => _isLoading = false);
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
//           Navigator.pop(context);
//         } else if (state is MemoryError) {
//           setState(() {
//             _isLoading = false;
//             _errorMessage = state.message;
//           });
//           ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
//         }
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           title: Text(widget.memory == null ? 'Add Memory' : 'Edit Memory'),
//         ),
//         body: SingleChildScrollView(
//           padding: EdgeInsets.all(16.w),
//           child: FadeTransition(
//             opacity: _fadeAnimation,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 GestureDetector(
//                   onTap: _pickImage,
//                   child: Container(
//                     width: double.infinity,
//                     height: 200.h,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(12.r),
//                     ),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(12.r),
//                       child: _selectedImage != null
//                           ? (kIsWeb || _selectedImage is Uint8List
//                               ? Image.memory(_selectedImage as Uint8List, fit: BoxFit.contain, width: double.infinity, height: 200.h,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     print('Image Memory Error: $error');
//                                     return const Center(child: Icon(Icons.error));
//                                   })
//                               : Image.file(_selectedImage as io.File, fit: BoxFit.contain, width: double.infinity, height: 200.h,
//                                   errorBuilder: (context, error, stackTrace) {
//                                     print('Image File Error: $error');
//                                     return const Center(child: Icon(Icons.error));
//                                   }))
//                           : widget.memory != null && widget.memory!.image.isNotEmpty
//                               ? CachedNetworkImage(
//                                   imageUrl: widget.memory!.image,
//                                   fit: BoxFit.contain,
//                                   width: double.infinity,
//                                   height: 200.h,
//                                   placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
//                                   errorWidget: (context, url, error) {
//                                     print('CachedImage Error: $error');
//                                     return const Center(child: Icon(Icons.broken_image));
//                                   },
//                                 )
//                               : const Center(child: Icon(Icons.add_a_photo)),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 16.h),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Date', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp)),
//                           SizedBox(height: 8.h),
//                           GestureDetector(
//                             onTap: () => _selectDate(context),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Theme.of(context).colorScheme.primary),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Text(
//                                 DateFormat('dd MMM yyyy').format(_selectedDate!),
//                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     SizedBox(width: 16.w),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text('Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp)),
//                           SizedBox(height: 8.h),
//                           GestureDetector(
//                             onTap: () => _selectTime(context),
//                             child: Container(
//                               padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//                               decoration: BoxDecoration(
//                                 border: Border.all(color: Theme.of(context).colorScheme.primary),
//                                 borderRadius: BorderRadius.circular(8.r),
//                               ),
//                               child: Text(
//                                 _selectedTime!.format(context),
//                                 style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16.h),
//                 Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp)),
//                 SizedBox(height: 8.h),
//                 TextField(
//                   controller: _descriptionController,
//                   maxLines: 5,
//                   decoration: InputDecoration(
//                     hintText: 'Add Note Here',
//                     border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
//                   ),
//                 ),
//                 if (_errorMessage != null) ...[
//                   SizedBox(height: 10.h),
//                   Text(_errorMessage!, style: TextStyle(color: Colors.red)),
//                 ],
//                 SizedBox(height: 24.h),
//                 Center(
//                   child: _isLoading
//                       ? const CircularProgressIndicator()
//                       : ElevatedButton(
//                           onPressed: _saveMemory,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Theme.of(context).colorScheme.primary,
//                             padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
//                             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
//                           ),
//                           child: const Text('Save'),
//                         ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/memory_cubit.dart';
import 'package:segma/models/memory_model.dart';
import 'package:universal_io/io.dart' as io;
import 'package:flutter/foundation.dart';

class AddEditMemoryScreen extends StatefulWidget {
  final Memory? memory;
  final String childId;

  const AddEditMemoryScreen({super.key, this.memory, required this.childId});

  @override
  _AddEditMemoryScreenState createState() => _AddEditMemoryScreenState();
}

class _AddEditMemoryScreenState extends State<AddEditMemoryScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  final _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  dynamic _selectedImage; // File أو Uint8List
  final ImagePicker _picker = ImagePicker();
  String? _errorMessage;

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
    print('Picking Image: Starting image selection process');
    try {
      final pickedFile = await showDialog<XFile?>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Choose Image', style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Gallery'),
                onTap: () async {
                  Navigator.pop(context, await _picker.pickImage(source: ImageSource.gallery));
                },
              ),
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
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
          setState(() => _selectedImage = io.File(pickedFile.path));
        } else if (kIsWeb) {
          final bytes = await pickedFile.readAsBytes();
          setState(() => _selectedImage = bytes);
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      setState(() => _errorMessage = 'Failed to pick image: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _saveMemory() {
    if (_descriptionController.text.isEmpty || _selectedDate == null || _selectedTime == null) {
      setState(() => _errorMessage = 'Please fill all fields');
      return;
    }

    final timeString = '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    final memory = Memory(
      id: widget.memory?.id ?? '',
      image: widget.memory?.image ?? '',
      description: _descriptionController.text,
      date: _selectedDate!,
      time: timeString,
      isFavorite: widget.memory?.isFavorite ?? false,
    );

    // بدل الـ _isLoading، نركز على تحديث فوري
    if (widget.memory == null) {
      context.read<MemoryCubit>().addMemory(widget.childId, memory, _selectedImage, context);
    } else {
      final updates = {
        'description': _descriptionController.text,
        'isFavorite': widget.memory!.isFavorite.toString(),
        'image': widget.memory!.image,
      };
      context.read<MemoryCubit>().updateMemory(widget.childId, widget.memory!.id, updates, _selectedImage);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<MemoryCubit, MemoryState>(
      listener: (context, state) {
        if (state is MemorySuccess) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          Navigator.pop(context);
        } else if (state is MemoryError) {
          setState(() => _errorMessage = state.message);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: _selectedImage != null
                          ? (kIsWeb || _selectedImage is Uint8List
                              ? Image.memory(_selectedImage as Uint8List, fit: BoxFit.contain, width: double.infinity, height: 200.h)
                              : Image.file(_selectedImage as io.File, fit: BoxFit.contain, width: double.infinity, height: 200.h))
                          : widget.memory != null && widget.memory!.image.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: widget.memory!.image,
                                  fit: BoxFit.contain,
                                  width: double.infinity,
                                  height: 200.h,
                                  placeholder: (context, url) => Container(color: Colors.grey[300], child: const Center(child: CircularProgressIndicator())),
                                  errorWidget: (context, url, error) => const Center(child: Icon(Icons.broken_image)),
                                )
                              : const Center(child: Icon(Icons.add_a_photo)),
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
                          Text('Date', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp)),
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
                          Text('Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp)),
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
                Text('Description', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 14.sp)),
                SizedBox(height: 8.h),
                TextField(
                  controller: _descriptionController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: 'Add Note Here',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                  ),
                ),
                if (_errorMessage != null) ...[
                  SizedBox(height: 10.h),
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ],
                SizedBox(height: 24.h),
                Center(
                  child: ElevatedButton(
                    onPressed: _saveMemory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
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