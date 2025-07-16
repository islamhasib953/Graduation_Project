// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:intl/intl.dart';
// import 'package:segma/models/child_model.dart';
// import 'package:segma/models/growth_model.dart';
// import 'package:segma/services/growth_service.dart';
// import 'package:pdf/pdf.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:printing/printing.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:segma/screens/childs/parent_info_screen.dart';
// import 'package:segma/utils/colors.dart';
// import 'package:http/http.dart' as http;

// class BabyCardScreen extends StatefulWidget {
//   final Child child;

//   const BabyCardScreen({
//     Key? key,
//     required this.child,
//   }) : super(key: key);

//   @override
//   _BabyCardScreenState createState() => _BabyCardScreenState();
// }

// class _BabyCardScreenState extends State<BabyCardScreen> {
//   GrowthRecord? latestGrowthRecord;
//   bool isLoading = true;
//   String? errorMessage;

//   @override
//   void initState() {
//     super.initState();
//     fetchLatestGrowthRecord();
//   }

//   Future<void> fetchLatestGrowthRecord() async {
//     setState(() {
//       isLoading = true;
//       errorMessage = null;
//     });

//     try {
//       final growthService = GrowthService();
//       final record = await growthService.getLastGrowthRecord(widget.child.id);
//       setState(() {
//         latestGrowthRecord = record;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         errorMessage = 'Failed to load latest growth data: $e';
//         isLoading = false;
//       });
//     }
//   }

//   // دالة لتصدير ملف PDF (الصندوق فقط)
//   Future<void> _exportToPDF(BuildContext context) async {
//     final pdf = pw.Document();

//     // تحميل الخط المخصص (مع تصحيح المسار)
//     late pw.Font ttf;
//     try {
//       final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
//       ttf = pw.Font.ttf(fontData);
//     } catch (e) {
//       print('Error loading font: $e');
//       // استخدام خط مدمج كبديل في حالة الفشل
//       ttf = pw.Font.times();
//     }

//     // تحميل الصورة إذا كانت موجودة
//     pw.MemoryImage? childImage;
//     if (widget.child.photo != null) {
//       try {
//         final response = await http.get(Uri.parse(widget.child.photo!));
//         if (response.statusCode == 200) {
//           childImage = pw.MemoryImage(response.bodyBytes);
//         } else {
//           print('Failed to load image: HTTP ${response.statusCode}');
//           childImage = null;
//         }
//       } catch (e) {
//         print('Error loading image: $e');
//         childImage = null;
//       }
//     }

//     // القيم اللي هتتعرض في الـ PDF (إما من آخر سجل نمو أو القيم الأولية)
//     final double displayHeight = latestGrowthRecord?.height ?? widget.child.heightAtBirth;
//     final double displayWeight = latestGrowthRecord?.weight ?? widget.child.weightAtBirth;
//     final double displayHeadCircumference = latestGrowthRecord?.headCircumference ?? widget.child.headCircumferenceAtBirth;

//     pdf.addPage(
//       pw.Page(
//         build: (pw.Context context) {
//           return pw.Center(
//             child: pw.Container(
//               padding: pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
//               decoration: pw.BoxDecoration(
//                 color: PdfColors.white,
//                 borderRadius: pw.BorderRadius.circular(16),
//                 boxShadow: [
//                   pw.BoxShadow(
//                     color: PdfColors.grey300,
//                     blurRadius: 5,
//                     offset: PdfPoint(0, 3),
//                   ),
//                 ],
//               ),
//               child: pw.Column(
//                 children: [
//                   // Child Image or Placeholder
//                   childImage != null
//                       ? pw.ClipOval(
//                           child: pw.Image(
//                             childImage,
//                             width: 100,
//                             height: 100,
//                             fit: pw.BoxFit.cover,
//                           ),
//                         )
//                       : pw.Container(
//                           width: 100,
//                           height: 100,
//                           decoration: pw.BoxDecoration(
//                             shape: pw.BoxShape.circle,
//                             color: PdfColors.purple100,
//                           ),
//                           child: pw.Center(
//                             child: pw.Text(
//                               '👤',
//                               style: pw.TextStyle(
//                                 fontSize: 50,
//                                 color: PdfColors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                   pw.SizedBox(height: 12),
//                   // Child Name
//                   pw.Text(
//                     widget.child.name,
//                     style: pw.TextStyle(
//                       fontSize: 18,
//                       fontWeight: pw.FontWeight.bold,
//                       font: ttf,
//                     ),
//                   ),
//                   pw.SizedBox(height: 16),
//                   // Details List
//                   _buildPdfDetailRow(
//                     widget.child.gender == 'male' ? '♂' : '♀',
//                     widget.child.gender == 'male' ? PdfColors.blue : PdfColors.pink,
//                     'Gender',
//                     widget.child.gender == 'male' ? 'Boy' : 'Girl',
//                     ttf,
//                     PdfColors.white,
//                   ),
//                   _buildPdfDetailRow(
//                     '🎂',
//                     PdfColors.grey,
//                     'Birth Date',
//                     DateFormat('dd MMM').format(widget.child.birthDate),
//                     ttf,
//                     PdfColors.blue50,
//                   ),
//                   _buildPdfDetailRow(
//                     '↕',
//                     PdfColors.grey,
//                     'Height',
//                     '$displayHeight cm', // استخدام القيمة المحدثة
//                     ttf,
//                     PdfColors.white,
//                   ),
//                   _buildPdfDetailRow(
//                     '🏋️',
//                     PdfColors.grey,
//                     'Weight',
//                     '$displayWeight kg', // استخدام القيمة المحدثة
//                     ttf,
//                     PdfColors.blue50,
//                   ),
//                   _buildPdfDetailRow(
//                     '⭕', // إضافة رمز لمحيط الرأس
//                     PdfColors.grey,
//                     'Head Circumference',
//                     '$displayHeadCircumference cm', // استخدام القيمة المحدثة
//                     ttf,
//                     PdfColors.white,
//                   ),
//                   _buildPdfDetailRow(
//                     '🩺',
//                     PdfColors.red,
//                     'Blood Type',
//                     widget.child.bloodType,
//                     ttf,
//                     PdfColors.blue50,
//                   ),
//                   _buildPdfDetailRow(
//                     '📞',
//                     PdfColors.grey,
//                     'Parent Phone',
//                     widget.child.parentPhone ?? 'Not available',
//                     ttf,
//                     PdfColors.white,
//                   ),
//                   _buildPdfDetailRow(
//                     '🪪',
//                     PdfColors.grey,
//                     'ID',
//                     widget.child.id,
//                     ttf,
//                     PdfColors.blue50,
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );

//     // عرض خيار حفظ أو مشاركة ملف PDF
//     await Printing.sharePdf(
//       bytes: await pdf.save(),
//       filename: '${widget.child.name}_baby_card.pdf',
//     );
//   }

//   // دالة لبناء صف التفاصيل في ملف PDF مع الأيقونات
//   pw.Widget _buildPdfDetailRow(
//     String icon,
//     PdfColor iconColor,
//     String label,
//     String value,
//     pw.Font font,
//     PdfColor backgroundColor,
//   ) {
//     return pw.Container(
//       color: backgroundColor,
//       padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
//       child: pw.Row(
//         mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
//         children: [
//           pw.Row(
//             children: [
//               pw.Text(
//                 icon,
//                 style: pw.TextStyle(
//                   fontSize: 20,
//                   color: iconColor,
//                 ),
//               ),
//               pw.SizedBox(width: 12),
//               pw.Text(
//                 label,
//                 style: pw.TextStyle(
//                   fontSize: 14,
//                   font: font,
//                 ),
//               ),
//             ],
//           ),
//           pw.Text(
//             value,
//             style: pw.TextStyle(
//               fontSize: 14,
//               font: font,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final formattedBirthDate = DateFormat('dd MMM').format(widget.child.birthDate);

//     // القيم اللي هتتعرض (إما من آخر سجل نمو أو القيم الأولية)
//     final double displayHeight = latestGrowthRecord?.height ?? widget.child.heightAtBirth;
//     final double displayWeight = latestGrowthRecord?.weight ?? widget.child.weightAtBirth;
//     final double displayHeadCircumference = latestGrowthRecord?.headCircumference ?? widget.child.headCircumferenceAtBirth;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           'Baby Card',
//           style: TextStyle(
//             fontFamily: 'Roboto',
//           ),
//         ),
//         backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//         elevation: 0,
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : errorMessage != null
//               ? Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         errorMessage!,
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontFamily: 'Roboto',
//                           color: AppColors.statusOverdue,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                       SizedBox(height: 16.h),
//                       ElevatedButton(
//                         onPressed: fetchLatestGrowthRecord,
//                         child: Text(
//                           'Retry',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontFamily: 'Roboto',
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               : Padding(
//                   padding: EdgeInsets.all(16.w),
//                   child: Column(
//                     children: [
//                       // Details List inside a curved container
//                       Container(
//                         padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(16.r),
//                           boxShadow: [
//                             BoxShadow(
//                               color: Colors.grey.withOpacity(0.2),
//                               spreadRadius: 2,
//                               blurRadius: 5,
//                               offset: Offset(0, 3),
//                             ),
//                           ],
//                         ),
//                         child: Column(
//                           children: [
//                             // Child Image or Placeholder
//                             widget.child.photo != null
//                                 ? ClipOval(
//                                     child: Image.network(
//                                       widget.child.photo!,
//                                       width: 100.r,
//                                       height: 100.r,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) => Container(
//                                         width: 100.r,
//                                         height: 100.r,
//                                         decoration: BoxDecoration(
//                                           shape: BoxShape.circle,
//                                           color: Colors.purple.shade100,
//                                         ),
//                                         child: Icon(
//                                           Icons.person,
//                                           size: 50.sp,
//                                           color: Colors.white,
//                                         ),
//                                       ),
//                                     ),
//                                   )
//                                 : Container(
//                                     width: 100.r,
//                                     height: 100.r,
//                                     decoration: BoxDecoration(
//                                       shape: BoxShape.circle,
//                                       color: Colors.purple.shade100,
//                                     ),
//                                     child: Icon(
//                                       Icons.person,
//                                       size: 50.sp,
//                                       color: Colors.white,
//                                     ),
//                                   ),
//                             SizedBox(height: 12.h),
//                             // Child Name
//                             Text(
//                               widget.child.name,
//                               style: Theme.of(context).textTheme.titleLarge?.copyWith(
//                                     fontSize: 18.sp,
//                                     fontFamily: 'Roboto',
//                                   ),
//                             ),
//                             SizedBox(height: 16.h),
//                             // Details List
//                             _buildDetailRow(
//                               context,
//                               icon: widget.child.gender == 'male' ? Icons.male : Icons.female,
//                               iconColor: widget.child.gender == 'male' ? Colors.blue : Colors.pink,
//                               label: 'Gender',
//                               value: widget.child.gender == 'male' ? 'Boy' : 'Girl',
//                               backgroundColor: Colors.white,
//                             ),
//                             _buildDetailRow(
//                               context,
//                               icon: Icons.cake,
//                               iconColor: Theme.of(context).brightness == Brightness.light
//                                   ? AppColors.lightTextSecondary
//                                   : AppColors.darkTextSecondary,
//                               label: 'Birth Date',
//                               value: formattedBirthDate,
//                               backgroundColor: Colors.blue.shade50,
//                             ),
//                             _buildDetailRow(
//                               context,
//                               icon: Icons.height,
//                               iconColor: Theme.of(context).brightness == Brightness.light
//                                   ? AppColors.lightTextSecondary
//                                   : AppColors.darkTextSecondary,
//                               label: 'Height',
//                               value: '$displayHeight cm', // استخدام القيمة المحدثة
//                               backgroundColor: Colors.white,
//                             ),
//                             _buildDetailRow(
//                               context,
//                               icon: Icons.fitness_center,
//                               iconColor: Theme.of(context).brightness == Brightness.light
//                                   ? AppColors.lightTextSecondary
//                                   : AppColors.darkTextSecondary,
//                               label: 'Weight',
//                               value: '$displayWeight kg', // استخدام القيمة المحدثة
//                               backgroundColor: Colors.blue.shade50,
//                             ),
//                             _buildDetailRow(
//                               context,
//                               icon: Icons.circle,
//                               iconColor: Theme.of(context).brightness == Brightness.light
//                                   ? AppColors.lightTextSecondary
//                                   : AppColors.darkTextSecondary,
//                               label: 'Head Circumference',
//                               value: '$displayHeadCircumference cm', // استخدام القيمة المحدثة
//                               backgroundColor: Colors.white,
//                             ),
//                             _buildDetailRow(
//                               context,
//                               icon: Icons.bloodtype,
//                               iconColor: Colors.red,
//                               label: 'Blood Type',
//                               value: widget.child.bloodType,
//                               backgroundColor: Colors.blue.shade50,
//                             ),
//                             // Parent Phone Row with Navigation
//                             Builder(
//                               builder: (BuildContext navigationContext) {
//                                 return _buildDetailRow(
//                                   navigationContext,
//                                   icon: Icons.phone,
//                                   iconColor: Theme.of(context).brightness == Brightness.light
//                                       ? AppColors.lightTextSecondary
//                                       : AppColors.darkTextSecondary,
//                                   label: 'Parent Phone',
//                                   value: widget.child.parentPhone ?? 'Not available',
//                                   backgroundColor: Colors.white,
//                                   onTap: () {
//                                     print('InkWell tapped: Attempting to navigate to ParentInfoScreen');
//                                     try {
//                                       print('Child data: ${widget.child.toString()}');
//                                       Navigator.push(
//                                         navigationContext,
//                                         MaterialPageRoute(
//                                           builder: (context) => ParentInfoScreen(child: widget.child),
//                                         ),
//                                       ).then((_) {
//                                         print('Navigation to ParentInfoScreen successful');
//                                       }).catchError((error) {
//                                         print('Navigation failed: $error');
//                                       });
//                                     } catch (e) {
//                                       print('Exception during navigation: $e');
//                                     }
//                                   },
//                                 );
//                               },
//                             ),
//                             _buildDetailRow(
//                               context,
//                               icon: Icons.perm_identity,
//                               iconColor: Theme.of(context).brightness == Brightness.light
//                                   ? AppColors.lightTextSecondary
//                                   : AppColors.darkTextSecondary,
//                               label: 'ID',
//                               value: widget.child.id,
//                               backgroundColor: Colors.blue.shade50,
//                             ),
//                           ],
//                         ),
//                       ),
//                       SizedBox(height: 24.h),
//                       // Export as PDF Button
//                       ElevatedButton(
//                         onPressed: () => _exportToPDF(context),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
//                           padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
//                         ),
//                         child: Text(
//                           'Export as PDF',
//                           style: TextStyle(
//                             fontSize: 14.sp,
//                             fontFamily: 'Roboto',
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//     );
//   }

//   Widget _buildDetailRow(
//     BuildContext context, {
//     required IconData icon,
//     required Color iconColor,
//     required String label,
//     required String value,
//     required Color backgroundColor,
//     VoidCallback? onTap,
//   }) {
//     return Material(
//       color: backgroundColor,
//       borderRadius: BorderRadius.circular(8.r),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(8.r),
//         splashColor: Colors.blue.withOpacity(0.3), // إضافة تأثير تموج
//         highlightColor: Colors.blue.withOpacity(0.1), // إضافة لون عند الضغط
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Icon(
//                     icon,
//                     color: iconColor,
//                     size: 20.sp,
//                   ),
//                   SizedBox(width: 12.w),
//                   Text(
//                     label,
//                     style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                           fontSize: 14.sp,
//                           fontFamily: 'Roboto',
//                         ),
//                   ),
//                 ],
//               ),
//               Text(
//                 value,
//                 style: Theme.of(context).textTheme.bodyLarge?.copyWith(
//                       fontSize: 14.sp,
//                       fontFamily: 'Roboto',
//                     ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/models/growth_model.dart';
import 'package:segma/services/growth_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:segma/screens/childs/parent_info_screen.dart';
import 'package:segma/utils/colors.dart';
import 'package:http/http.dart' as http;

class BabyCardScreen extends StatefulWidget {
  final Child child;

  const BabyCardScreen({
    super.key,
    required this.child,
  });

  @override
  _BabyCardScreenState createState() => _BabyCardScreenState();
}

class _BabyCardScreenState extends State<BabyCardScreen> {
  GrowthRecord? latestGrowthRecord;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchLatestGrowthRecord();
  }

  Future<void> fetchLatestGrowthRecord() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final growthService = GrowthService();
      final record = await growthService.getLastGrowthRecord(widget.child.id);
      setState(() {
        latestGrowthRecord = record;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load latest growth data: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _exportToPDF(BuildContext context) async {
    final pdf = pw.Document();
    late pw.Font ttf;
    try {
      final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      ttf = pw.Font.ttf(fontData);
    } catch (e) {
      print('Error loading font: $e');
      ttf = pw.Font.times();
    }
    pw.MemoryImage? childImage;
    if (widget.child.photo != null) {
      try {
        final response = await http.get(Uri.parse(widget.child.photo!));
        if (response.statusCode == 200) {
          childImage = pw.MemoryImage(response.bodyBytes);
        } else {
          print('Failed to load image: HTTP ${response.statusCode}');
          childImage = null;
        }
      } catch (e) {
        print('Error loading image: $e');
        childImage = null;
      }
    }
    final double displayHeight = latestGrowthRecord?.height ?? widget.child.heightAtBirth;
    final double displayWeight = latestGrowthRecord?.weight ?? widget.child.weightAtBirth;
    final double displayHeadCircumference = latestGrowthRecord?.headCircumference ?? widget.child.headCircumferenceAtBirth;

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Center(
            child: pw.Container(
              padding: pw.EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              decoration: pw.BoxDecoration(
                color: PdfColors.white,
                borderRadius: pw.BorderRadius.circular(16),
                boxShadow: [pw.BoxShadow(color: PdfColors.grey300, blurRadius: 5, offset: PdfPoint(0, 3))],
              ),
              child: pw.Column(
                children: [
                  childImage != null
                      ? pw.ClipOval(
                          child: pw.Image(childImage, width: 100, height: 100, fit: pw.BoxFit.cover),
                        )
                      : pw.Container(
                          width: 100,
                          height: 100,
                          decoration: pw.BoxDecoration(shape: pw.BoxShape.circle, color: PdfColors.purple100),
                          child: pw.Center(
                            child: pw.Text('👤', style: pw.TextStyle(fontSize: 50, color: PdfColors.white)),
                          ),
                        ),
                  pw.SizedBox(height: 12),
                  pw.Text(widget.child.name, style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, font: ttf)),
                  pw.SizedBox(height: 16),
                  _buildPdfDetailRow(widget.child.gender == 'male' ? '♂' : '♀', widget.child.gender == 'male' ? PdfColors.blue : PdfColors.pink, 'Gender',
                      widget.child.gender == 'male' ? 'Boy' : 'Girl', ttf, PdfColors.white),
                  _buildPdfDetailRow('🎂', PdfColors.grey, 'Birth Date', DateFormat('dd MMM').format(widget.child.birthDate), ttf, PdfColors.blue50),
                  _buildPdfDetailRow('↕', PdfColors.grey, 'Height', '$displayHeight cm', ttf, PdfColors.white),
                  _buildPdfDetailRow('🏋️', PdfColors.grey, 'Weight', '$displayWeight kg', ttf, PdfColors.blue50),
                  _buildPdfDetailRow('⭕', PdfColors.grey, 'Head Circumference', '$displayHeadCircumference cm', ttf, PdfColors.white),
                  _buildPdfDetailRow('🩺', PdfColors.red, 'Blood Type', widget.child.bloodType, ttf, PdfColors.blue50),
                  _buildPdfDetailRow('📞', PdfColors.grey, 'Parent Phone', widget.child.parentPhone ?? 'Not available', ttf, PdfColors.white),
                  _buildPdfDetailRow('🪪', PdfColors.grey, 'ID', widget.child.id, ttf, PdfColors.blue50),
                ],
              ),
            ),
          );
        },
      ),
    );
    await Printing.sharePdf(bytes: await pdf.save(), filename: '${widget.child.name}_baby_card.pdf');
  }

  pw.Widget _buildPdfDetailRow(String icon, PdfColor iconColor, String label, String value, pw.Font font, PdfColor backgroundColor) {
    return pw.Container(
      color: backgroundColor,
      padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Row(
            children: [
              pw.Text(icon, style: pw.TextStyle(fontSize: 20, color: iconColor)),
              pw.SizedBox(width: 12),
              pw.Text(label, style: pw.TextStyle(fontSize: 14, font: font)),
            ],
          ),
          pw.Text(value, style: pw.TextStyle(fontSize: 14, font: font)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedBirthDate = DateFormat('dd MMM').format(widget.child.birthDate);
    final double displayHeight = latestGrowthRecord?.height ?? widget.child.heightAtBirth;
    final double displayWeight = latestGrowthRecord?.weight ?? widget.child.weightAtBirth;
    final double displayHeadCircumference = latestGrowthRecord?.headCircumference ?? widget.child.headCircumferenceAtBirth;

    return Scaffold(
      appBar: AppBar(
        title: Text('Baby Card', style: TextStyle(fontFamily: 'Roboto')),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(errorMessage!, style: TextStyle(fontSize: 16.sp, fontFamily: 'Roboto', color: AppColors.statusOverdue), textAlign: TextAlign.center),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: fetchLatestGrowthRecord,
                        child: Text('Retry', style: TextStyle(fontSize: 14.sp, fontFamily: 'Roboto')),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 16.w),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), spreadRadius: 2, blurRadius: 5, offset: Offset(0, 3))],
                        ),
                        child: Column(
                          children: [
                            ClipOval(
                              child: widget.child.photo != null
                                  ? Image.network(widget.child.photo!, width: 100.r, height: 100.r, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Container(
                                        width: 100.r,
                                        height: 100.r,
                                        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade100),
                                        child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                                      ))
                                  : Container(
                                      width: 100.r,
                                      height: 100.r,
                                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.shade100),
                                      child: Icon(Icons.person, size: 50.sp, color: Colors.white),
                                    ),
                            ),
                            SizedBox(height: 12.h),
                            Text(widget.child.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp, fontFamily: 'Roboto')),
                            SizedBox(height: 16.h),
                            _buildDetailRow(context,
                                icon: widget.child.gender == 'male' ? Icons.male : Icons.female,
                                iconColor: widget.child.gender == 'male' ? Colors.blue : Colors.pink,
                                label: 'Gender',
                                value: widget.child.gender == 'male' ? 'Boy' : 'Girl',
                                backgroundColor: Colors.white),
                            _buildDetailRow(context,
                                icon: Icons.cake,
                                iconColor: Theme.of(context).brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                                label: 'Birth Date',
                                value: formattedBirthDate,
                                backgroundColor: Colors.blue.shade50),
                            _buildDetailRow(context,
                                icon: Icons.height,
                                iconColor: Theme.of(context).brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                                label: 'Height',
                                value: '$displayHeight cm',
                                backgroundColor: Colors.white),
                            _buildDetailRow(context,
                                icon: Icons.fitness_center,
                                iconColor: Theme.of(context).brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                                label: 'Weight',
                                value: '$displayWeight kg',
                                backgroundColor: Colors.blue.shade50),
                            _buildDetailRow(context,
                                icon: Icons.circle,
                                iconColor: Theme.of(context).brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                                label: 'Head Circumference',
                                value: '$displayHeadCircumference cm',
                                backgroundColor: Colors.white),
                            _buildDetailRow(context,
                                icon: Icons.bloodtype,
                                iconColor: Colors.red,
                                label: 'Blood Type',
                                value: widget.child.bloodType,
                                backgroundColor: Colors.blue.shade50),
                            Builder(
                              builder: (BuildContext navigationContext) {
                                return _buildDetailRow(navigationContext,
                                    icon: Icons.phone,
                                    iconColor: Theme.of(context).brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                                    label: 'Parent Phone',
                                    value: widget.child.parentPhone ?? 'Not available',
                                    backgroundColor: Colors.white,
                                    onTap: () {
                                      print('InkWell tapped: Attempting to navigate to ParentInfoScreen');
                                      try {
                                        print('Child data: ${widget.child.toString()}');
                                        Navigator.push(navigationContext,
                                            MaterialPageRoute(builder: (context) => ParentInfoScreen(child: widget.child))).then((_) {
                                          print('Navigation to ParentInfoScreen successful');
                                        }).catchError((error) {
                                          print('Navigation failed: $error');
                                        });
                                      } catch (e) {
                                        print('Exception during navigation: $e');
                                      }
                                    });
                              },
                            ),
                            _buildDetailRow(context,
                                icon: Icons.perm_identity,
                                iconColor: Theme.of(context).brightness == Brightness.light ? AppColors.lightTextSecondary : AppColors.darkTextSecondary,
                                label: 'ID',
                                value: widget.child.id,
                                backgroundColor: Colors.blue.shade50),
                          ],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton(
                        onPressed: () => _exportToPDF(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).elevatedButtonTheme.style?.backgroundColor?.resolve({}),
                          padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                        ),
                        child: Text('Export as PDF', style: TextStyle(fontSize: 14.sp, fontFamily: 'Roboto')),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required Color backgroundColor,
    VoidCallback? onTap,
  }) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        splashColor: Colors.blue.withOpacity(0.3),
        highlightColor: Colors.blue.withOpacity(0.1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, color: iconColor, size: 20.sp),
                  SizedBox(width: 12.w),
                  Text(label, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14.sp, fontFamily: 'Roboto')),
                ],
              ),
              Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 14.sp, fontFamily: 'Roboto')),
            ],
          ),
        ),
      ),
    );
  }
}