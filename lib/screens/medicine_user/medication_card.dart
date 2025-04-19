import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/medication_cubit.dart';
import 'package:segma/models/medication_model.dart';
import 'package:segma/screens/medicine_user/log_medication_screen.dart';
import 'package:intl/intl.dart';

class MedicationCard extends StatelessWidget {
  final Medication medication;
  final int index;
  final String childId;

  const MedicationCard({
    super.key,
    required this.medication,
    required this.index,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  medication.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: Theme.of(context).primaryColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LogMedicationScreen(
                              existingMedication: medication,
                              index: index,
                              childId: childId,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.error,
                      ),
                      onPressed: () {
                        context.read<MedicationCubit>().deleteMedication(index, childId: childId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              'Days: ${medication.days.join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 5.h),
            Text(
              'Times: ${medication.times.map((time) => DateFormat.jm().format(time)).join(', ')}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}