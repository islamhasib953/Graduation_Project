// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:segma/services/doctor_service.dart';
// import 'package:segma/utils/colors.dart';

// class DoctorAvailabilityScreen extends StatefulWidget {
//   const DoctorAvailabilityScreen({Key? key}) : super(key: key);

//   @override
//   _DoctorAvailabilityScreenState createState() => _DoctorAvailabilityScreenState();
// }

// class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
//   // List of available days
//   final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
//   List<String> selectedDays = [];
  
//   // List of available times
//   List<String> availableTimes = [];
  
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchCurrentAvailability();
//   }

//   // Fetch current availability
//   Future<void> _fetchCurrentAvailability() async {
//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await DoctorService.getDoctorProfile();
//       if (response['status'] == 'success') {
//         final data = response['data'];
//         setState(() {
//           selectedDays = List<String>.from(data['availableDays'] ?? []);
//           availableTimes = List<String>.from(data['availableTimes'] ?? []);
//         });
//       } else {
//         throw Exception(response['message'] ?? 'Error');
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: AppColors.statusOverdue,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   // Add new time
//   Future<void> _addTime() async {
//     TimeOfDay? pickedTime = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
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

//     if (pickedTime != null) {
//       final now = DateTime.now();
//       final dateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
//       final formattedTime = DateFormat('h:mm a').format(dateTime);

//       setState(() {
//         if (!availableTimes.contains(formattedTime)) {
//           availableTimes.add(formattedTime);
//         }
//       });
//     }
//   }

//   // Update availability via API
//   Future<void> _updateAvailability() async {
//     if (selectedDays.isEmpty || availableTimes.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(
//           content: Text('Please select at least one day and one time'),
//           backgroundColor: AppColors.statusOverdue,
//         ),
//       );
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final response = await DoctorService.updateDoctorAvailability({
//         'availableDays': selectedDays,
//         'availableTimes': availableTimes,
//       });

//       if (response['status'] == 'success' && context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Availability updated successfully'),
//             backgroundColor: AppColors.statusUpcoming,
//           ),
//         );
//       } else {
//         throw Exception(response['message'] ?? 'Error updating availability');
//       }
//     } catch (e) {
//       if (context.mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Error: $e'),
//             backgroundColor: AppColors.statusOverdue,
//           ),
//         );
//       }
//     } finally {
//       setState(() {
//         isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         color: Theme.of(context).scaffoldBackgroundColor,
//         child: SafeArea(
//           child: Padding(
//             padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
//             child: isLoading
//                 ? Center(
//                     child: CircularProgressIndicator(
//                       color: Theme.of(context).primaryColor,
//                     ),
//                   )
//                 : Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Title
//                       Row(
//                         children: [
//                           StatefulBuilder(
//                             builder: (context, setState) {
//                               bool _isBackPressed = false;
//                               return GestureDetector(
//                                 onTapDown: (_) => setState(() => _isBackPressed = true),
//                                 onTapUp: (_) {
//                                   setState(() => _isBackPressed = false);
//                                   Navigator.pop(context);
//                                 },
//                                 onTapCancel: () => setState(() => _isBackPressed = false),
//                                 child: AnimatedScale(
//                                   scale: _isBackPressed ? 0.95 : 1.0,
//                                   duration: const Duration(milliseconds: 100),
//                                   child: IconButton(
//                                     icon: Icon(
//                                       Icons.arrow_back,
//                                       size: 24.sp,
//                                     ),
//                                     onPressed: () => Navigator.pop(context),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                           Expanded(
//                             child: Text(
//                               'Set Your Availability',
//                               style: Theme.of(context).textTheme.titleLarge,
//                               textAlign: TextAlign.center,
//                             ),
//                           ),
//                           SizedBox(width: 48.w),
//                         ],
//                       ),
//                       SizedBox(height: 24.h),
//                       // Days Section
//                       Text(
//                         'Select Available Days',
//                         style: Theme.of(context).textTheme.titleMedium,
//                       ),
//                       SizedBox(height: 12.h),
//                       Card(
//                         elevation: 4,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12.r),
//                         ),
//                         color: Theme.of(context).cardColor,
//                         child: Padding(
//                           padding: EdgeInsets.all(16.w),
//                           child: GridView.builder(
//                             shrinkWrap: true,
//                             physics: const NeverScrollableScrollPhysics(),
//                             gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                               crossAxisCount: 4,
//                               crossAxisSpacing: 8.w,
//                               mainAxisSpacing: 8.h,
//                               childAspectRatio: 1,
//                             ),
//                             itemCount: daysOfWeek.length,
//                             itemBuilder: (context, index) {
//                               final day = daysOfWeek[index];
//                               final isSelected = selectedDays.contains(day);
//                               return StatefulBuilder(
//                                 builder: (context, setState) {
//                                   bool _isDayPressed = false;
//                                   return GestureDetector(
//                                     onTapDown: (_) => setState(() => _isDayPressed = true),
//                                     onTapUp: (_) {
//                                       setState(() {
//                                         _isDayPressed = false;
//                                         if (isSelected) {
//                                           selectedDays.remove(day);
//                                         } else {
//                                           selectedDays.add(day);
//                                         }
//                                       });
//                                     },
//                                     onTapCancel: () => setState(() => _isDayPressed = false),
//                                     child: AnimatedScale(
//                                       scale: _isDayPressed ? 0.95 : 1.0,
//                                       duration: const Duration(milliseconds: 100),
//                                       child: Container(
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: isSelected
//                                               ? Theme.of(context).primaryColor
//                                               : Theme.of(context).dividerColor,
//                                         ),
//                                         child: Center(
//                                           child: Text(
//                                             day.substring(0, 3),
//                                             style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                                                   fontWeight: FontWeight.bold,
//                                                   color: isSelected
//                                                       ? Theme.of(context).elevatedButtonTheme.style?.foregroundColor?.resolve({})
//                                                       : Theme.of(context).textTheme.bodyMedium?.color,
//                                                 ),
//                                           ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               );
//                             },
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 24.h),
//                       // Times Section
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Available Times',
//                             style: Theme.of(context).textTheme.titleMedium,
//                           ),
//                           StatefulBuilder(
//                             builder: (context, setState) {
//                               bool _isFabPressed = false;
//                               return GestureDetector(
//                                 onTapDown: (_) => setState(() => _isFabPressed = true),
//                                 onTapUp: (_) {
//                                   setState(() => _isFabPressed = false);
//                                   _addTime();
//                                 },
//                                 onTapCancel: () => setState(() => _isFabPressed = false),
//                                 child: AnimatedScale(
//                                   scale: _isFabPressed ? 0.95 : 1.0,
//                                   duration: const Duration(milliseconds: 100),
//                                   child: FloatingActionButton(
//                                     onPressed: _addTime,
//                                     mini: true,
//                                     backgroundColor: Theme.of(context).primaryColor,
//                                     child: Icon(Icons.add, size: 24.sp),
//                                   ),
//                                 ),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       SizedBox(height: 12.h),
//                       Expanded(
//                         child: Card(
//                           elevation: 4,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12.r),
//                           ),
//                           color: Theme.of(context).cardColor,
//                           child: Padding(
//                             padding: EdgeInsets.symmetric(vertical: 8.h),
//                             child: availableTimes.isEmpty
//                                 ? Center(
//                                     child: Text(
//                                       'No times added',
//                                       style: Theme.of(context).textTheme.bodyMedium,
//                                     ),
//                                   )
//                                 : ListView.builder(
//                                     itemCount: availableTimes.length,
//                                     itemBuilder: (context, index) {
//                                       final time = availableTimes[index];
//                                       return ListTile(
//                                         leading: Icon(
//                                           Icons.access_time,
//                                           color: Theme.of(context).primaryColor,
//                                           size: 24.sp,
//                                         ),
//                                         title: Text(
//                                           time,
//                                           style: Theme.of(context).textTheme.bodyLarge,
//                                         ),
//                                         trailing: StatefulBuilder(
//                                           builder: (context, setState) {
//                                             bool _isDeletePressed = false;
//                                             return GestureDetector(
//                                               onTapDown: (_) => setState(() => _isDeletePressed = true),
//                                               onTapUp: (_) {
//                                                 setState(() {
//                                                   _isDeletePressed = false;
//                                                   availableTimes.removeAt(index);
//                                                 });
//                                               },
//                                               onTapCancel: () => setState(() => _isDeletePressed = false),
//                                               child: AnimatedScale(
//                                                 scale: _isDeletePressed ? 0.95 : 1.0,
//                                                 duration: const Duration(milliseconds: 100),
//                                                 child: IconButton(
//                                                   icon: Icon(
//                                                     Icons.delete,
//                                                     color: AppColors.statusOverdue,
//                                                     size: 24.sp,
//                                                   ),
//                                                   onPressed: () {
//                                                     setState(() {
//                                                       availableTimes.removeAt(index);
//                                                     });
//                                                   },
//                                                 ),
//                                               ),
//                                             );
//                                           },
//                                         ),
//                                       );
//                                     },
//                                   ),
//                           ),
//                         ),
//                       ),
//                       SizedBox(height: 24.h),
//                       // Save Button
//                       Center(
//                         child: isLoading
//                             ? CircularProgressIndicator(
//                                 color: Theme.of(context).primaryColor,
//                               )
//                             : StatefulBuilder(
//                                 builder: (context, setState) {
//                                   bool _isSavePressed = false;
//                                   return GestureDetector(
//                                     onTapDown: (_) => setState(() => _isSavePressed = true),
//                                     onTapUp: (_) {
//                                       setState(() => _isSavePressed = false);
//                                       _updateAvailability();
//                                     },
//                                     onTapCancel: () => setState(() => _isSavePressed = false),
//                                     child: AnimatedScale(
//                                       scale: _isSavePressed ? 0.95 : 1.0,
//                                       duration: const Duration(milliseconds: 100),
//                                       child: ElevatedButton(
//                                         onPressed: _updateAvailability,
//                                         style: ElevatedButton.styleFrom(
//                                           padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(12.r),
//                                           ),
//                                           elevation: 5,
//                                         ),
//                                         child: Text(
//                                           'Save Availability',
//                                           style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                                                 fontWeight: FontWeight.bold,
//                                               ),
//                                         ),
//                                       ),
//                                     ),
//                                   );
//                                 },
//                               ),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:intl/intl.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({Key? key}) : super(key: key);

  @override
  _DoctorAvailabilityScreenState createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  // قائمة الأيام المتاحة
  final List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  List<String> selectedDays = [];
  
  // قائمة الأوقات المتاحة
  List<String> availableTimes = [];
  
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchCurrentAvailability();
  }

  // دالة لجلب المواعيد الحالية
  Future<void> _fetchCurrentAvailability() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await DoctorService.getDoctorProfile();
      if (response['status'] == 'success') {
        final data = response['data'];
        setState(() {
          selectedDays = List<String>.from(data['availableDays'] ?? []);
          availableTimes = List<String>.from(data['availableTimes'] ?? []);
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load current availability');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading availability: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // دالة لإضافة وقت جديد
  Future<void> _addTime() async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blueAccent,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // تحويل الوقت إلى صيغة 12 ساعة (مثل 2:00 PM)
      final now = DateTime.now();
      final dateTime = DateTime(now.year, now.month, now.day, pickedTime.hour, pickedTime.minute);
      final formattedTime = DateFormat('h:mm a').format(dateTime);

      setState(() {
        if (!availableTimes.contains(formattedTime)) {
          availableTimes.add(formattedTime);
        }
      });
    }
  }

  // دالة لتحديث المواعيد عبر الـ API
  Future<void> _updateAvailability() async {
    if (selectedDays.isEmpty || availableTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select at least one day and one time.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await DoctorService.updateDoctorAvailability({
        'availableDays': selectedDays,
        'availableTimes': availableTimes,
      });

      if (response['status'] == 'success' && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Availability updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Failed to update availability');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade300, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // العنوان
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              'Set Your Availability',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(width: 48.w),
                        ],
                      ),
                      SizedBox(height: 24.h),
                      // قسم الأيام
                      Text(
                        'Select Available Days',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              crossAxisSpacing: 8.w,
                              mainAxisSpacing: 8.h,
                              childAspectRatio: 1,
                            ),
                            itemCount: daysOfWeek.length,
                            itemBuilder: (context, index) {
                              final day = daysOfWeek[index];
                              final isSelected = selectedDays.contains(day);
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (isSelected) {
                                      selectedDays.remove(day);
                                    } else {
                                      selectedDays.add(day);
                                    }
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? Colors.blueAccent : Colors.grey.shade200,
                                  ),
                                  child: Center(
                                    child: Text(
                                      day.substring(0, 3),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: isSelected ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // قسم الأوقات
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Available Times',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          FloatingActionButton(
                            onPressed: _addTime,
                            mini: true,
                            backgroundColor: Colors.blueAccent,
                            child: Icon(Icons.add, size: 24.sp),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: availableTimes.isEmpty
                                ? Center(
                                    child: Text(
                                      'No times added yet',
                                      style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: availableTimes.length,
                                    itemBuilder: (context, index) {
                                      final time = availableTimes[index];
                                      return ListTile(
                                        leading: Icon(Icons.access_time, color: Colors.blueAccent, size: 24.sp),
                                        title: Text(
                                          time,
                                          style: TextStyle(fontSize: 16.sp, color: Colors.black87),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(Icons.delete, color: Colors.red, size: 24.sp),
                                          onPressed: () {
                                            setState(() {
                                              availableTimes.removeAt(index);
                                            });
                                          },
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
                      // زر التأكيد
                      Center(
                        child: isLoading
                            ? const CircularProgressIndicator(color: Colors.blueAccent)
                            : ElevatedButton(
                                onPressed: _updateAvailability,
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  elevation: 5,
                                  backgroundColor: Colors.transparent,
                                ).copyWith(
                                  foregroundColor: MaterialStateProperty.all(Colors.white),
                                  backgroundColor: MaterialStateProperty.all(Colors.transparent),
                                  overlayColor: MaterialStateProperty.all(Colors.white24),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Colors.blueAccent, Colors.blue.shade700],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 12.h),
                                  child: Text(
                                    'Save Availability',
                                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                                  ),
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
}