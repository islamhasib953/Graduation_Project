import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:intl/intl.dart';

class HistoryFilterScreen extends StatefulWidget {
  final String childId;

  const HistoryFilterScreen({super.key, required this.childId});

  @override
  State<HistoryFilterScreen> createState() => _HistoryFilterScreenState();
}

class _HistoryFilterScreenState extends State<HistoryFilterScreen> {
  final _diagnosisController = TextEditingController();
  DateTime? _fromDate;
  DateTime? _toDate;
  String _sortBy = 'latest';

  Future<void> _selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _fromDate = picked;
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _toDate = picked;
      });
    }
  }

  void _applyFilter() {
    context.read<HistoryCubit>().filterHistory(
          childId: widget.childId,
          diagnosis: _diagnosisController.text,
          fromDate: _fromDate,
          toDate: _toDate,
          sortBy: _sortBy,
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
        title: Text(
          'Search by Disease',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _diagnosisController,
              style: Theme.of(context).textTheme.bodyLarge,
              decoration: InputDecoration(
                labelText: 'Search by Disease',
                labelStyle: Theme.of(context).textTheme.bodyMedium,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Theme.of(context).primaryColor),
                ),
                suffixIcon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () => _selectFromDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            _fromDate != null
                                ? DateFormat('MMM d, yyyy').format(_fromDate!)
                                : 'Select Date',
                            style: Theme.of(context).textTheme.bodyLarge,
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
                      Text(
                        'To',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 10.h),
                      GestureDetector(
                        onTap: () => _selectToDate(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Theme.of(context).dividerColor),
                            borderRadius: BorderRadius.circular(5.r),
                          ),
                          child: Text(
                            _toDate != null
                                ? DateFormat('MMM d, yyyy').format(_toDate!)
                                : 'Select Date',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20.h),
            Text(
              'Sorted by',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            SizedBox(height: 10.h),
            Row(
              children: [
                ChoiceChip(
                  label: Text('Date (Latest First)', style: Theme.of(context).textTheme.bodyMedium),
                  selected: _sortBy == 'latest',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _sortBy = 'latest';
                      });
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                ),
                SizedBox(width: 10.w),
                ChoiceChip(
                  label: Text('Date (Oldest First)', style: Theme.of(context).textTheme.bodyMedium),
                  selected: _sortBy == 'oldest',
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _sortBy = 'oldest';
                      });
                    }
                  },
                  selectedColor: Theme.of(context).primaryColor,
                  backgroundColor: Theme.of(context).cardColor,
                ),
              ],
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _applyFilter,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 15.h),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                  ),
                  child: Text(
                    'Apply',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
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

  @override
  void dispose() {
    _diagnosisController.dispose();
    super.dispose();
  }
}