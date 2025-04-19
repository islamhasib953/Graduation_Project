import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/medication_cubit.dart';
import 'package:segma/models/medication_model.dart';
import 'package:segma/screens/medicine_user/log_medication_screen.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:intl/intl.dart';

class MedicineScreen extends StatefulWidget {
  const MedicineScreen({super.key});

  @override
  State<MedicineScreen> createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  @override
  void initState() {
    super.initState();
    final childId = context.read<SelectedChildCubit>().state ?? '';
    if (childId.isNotEmpty) {
      context.read<MedicationCubit>().fetchMedications(childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final childId = context.read<SelectedChildCubit>().state ?? '';

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Medications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GestureDetector(
              onTap: () {
                context.read<MedicationCubit>().setMedicationToEdit(null);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LogMedicationScreen(
                      childId: childId,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(Icons.add, color: Theme.of(context).primaryColor),
                  SizedBox(width: 5.w),
                  Text(
                    'Add New Medic',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).primaryColor,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: BlocBuilder<MedicationCubit, List<Medication>>(
        builder: (context, medications) {
          if (medications.isEmpty) {
            return Center(
              child: Text(
                'No medications added yet.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            );
          }

          final groupedMedications = <String, List<Medication>>{};
          for (var medication in medications) {
            final monthYear = DateFormat('MMMM yyyy').format(medication.date);
            if (!groupedMedications.containsKey(monthYear)) {
              groupedMedications[monthYear] = [];
            }
            groupedMedications[monthYear]!.add(medication);
          }

          final sortedKeys = groupedMedications.keys.toList()
            ..sort((a, b) {
              final dateA = DateFormat('MMMM yyyy').parse(a);
              final dateB = DateFormat('MMMM yyyy').parse(b);
              return dateB.compareTo(dateA);
            });

          return ListView.builder(
            padding: EdgeInsets.all(16.w),
            itemCount: sortedKeys.length,
            itemBuilder: (context, index) {
              final monthYear = sortedKeys[index];
              final meds = groupedMedications[monthYear]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      'Your Medications for $monthYear',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  ...meds.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final medication = entry.value;
                    return MedicationCardDisplay(
                      medication: medication,
                      index: idx,
                      childId: childId,
                    );
                  }).toList(),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class MedicationCardDisplay extends StatelessWidget {
  final Medication medication;
  final int index;
  final String childId;

  const MedicationCardDisplay({
    super.key,
    required this.medication,
    required this.index,
    required this.childId,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        medication.name,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        medication.description.isEmpty ? 'No description provided' : medication.description,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 10.h),
                      Wrap(
                        spacing: 8.w,
                        children: [
                          'Saturday',
                          'Sunday',
                          'Monday',
                          'Tuesday',
                          'Wednesday',
                          'Thursday',
                        ].map((day) {
                          final isSelected = medication.days.contains(day);
                          return Text(
                            day,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.error
                                      : Theme.of(context).textTheme.bodyMedium?.color,
                                ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Time',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 5.h),
                    ...medication.times.map((time) {
                      return Padding(
                        padding: EdgeInsets.only(bottom: 5.h),
                        child: Container(
                          width: 60.w,
                          height: 30.h,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).colorScheme.error),
                          ),
                          child: Center(
                            child: Text(
                              DateFormat.jm().format(time),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                )
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.read<MedicationCubit>().setMedicationToEdit(medication);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogMedicationScreen(
                          existingMedication: medication,
                          index: index,
                          childId: childId,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'UPDATE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    context.read<MedicationCubit>().deleteMedication(index, childId: childId);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Medication deleted successfully',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.error,
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'CANCEL',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onError,
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