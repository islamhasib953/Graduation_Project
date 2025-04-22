import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/models/growth_model.dart';

class GrowthDetailsDoctorScreen extends StatelessWidget {
  final GrowthRecord growthRecord;
  final String childId;

  const GrowthDetailsDoctorScreen({
    Key? key,
    required this.growthRecord,
    required this.childId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          'Growth Details',
          style: TextStyle(
            fontSize: 18.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow(context, 'Date', DateFormat('dd-MM-yyyy').format(growthRecord.date)),
              _buildDetailRow(context, 'Time', growthRecord.time),
              _buildDetailRow(context, 'Weight', '${growthRecord.weight} kg'),
              _buildDetailRow(context, 'Height', '${growthRecord.height} cm'),
              _buildDetailRow(context, 'Head Circumference', '${growthRecord.headCircumference} cm'),
              _buildDetailRow(context, 'Age', '${growthRecord.ageInMonths} months'),
              _buildDetailRow(context, 'Notes', growthRecord.notes.isEmpty ? 'N/A' : growthRecord.notes),
              if (growthRecord.notesImage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Image.network(
                    growthRecord.notesImage,
                    height: 100.h,
                    width: 100.w,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}