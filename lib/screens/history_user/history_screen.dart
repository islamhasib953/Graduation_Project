import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/screens/history_user/add_history_screen.dart';
import 'package:segma/screens/doctor/edit_history_screen.dart';
import 'package:segma/screens/history_user/history_filter_screen.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    final childId = context.read<SelectedChildCubit>().state ?? '';
    if (childId.isNotEmpty) {
      context.read<HistoryCubit>().fetchHistory(childId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectedChildCubit, String?>(
      listener: (context, childId) {
        if (childId != null && childId.isNotEmpty) {
          context.read<HistoryCubit>().fetchHistory(childId);
        }
      },
      child: BlocBuilder<SelectedChildCubit, String?>(
        builder: (context, childId) {
          if (childId == null || childId.isEmpty) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
                title: Text('History', style: Theme.of(context).textTheme.titleLarge),
              ),
              body: Center(
                child: Text(
                  'Please select a child to view history.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              elevation: 0,
              title: Text('History', style: Theme.of(context).textTheme.titleLarge),
              actions: [
                IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryFilterScreen(childId: childId),
                      ),
                    );
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddHistoryScreen(childId: childId),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add, color: Theme.of(context).primaryColor),
                        SizedBox(width: 5.w),
                        Text(
                          'Add History',
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
            body: BlocBuilder<HistoryCubit, List<History>>(
              builder: (context, histories) {
                if (histories.isEmpty) {
                  return Center(
                    child: Text(
                      'No history records found.',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  );
                }

                return Column(
                  children: [
                    Container(
                      color: Theme.of(context).cardColor,
                      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Diagnosis',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Disease',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Date',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Doctor',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'Actions',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: histories.length,
                        itemBuilder: (context, index) {
                          final history = histories[index];
                          return Container(
                            color: Theme.of(context).cardColor,
                            margin: EdgeInsets.symmetric(vertical: 2.h),
                            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 16.w),
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    history.diagnosis,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    history.disease,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    DateFormat('MMM d, yyyy').format(history.date),
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    history.doctorName,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          context.read<HistoryCubit>().setHistoryToView(history);
                                          _showDetailsOverlay(context, history);
                                        },
                                        child: Text(
                                          'Details',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Theme.of(context).primaryColor,
                                              ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit, color: Colors.green),
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => EditHistoryScreen(
                                                history: history,
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
                                          _confirmDelete(context, index, childId);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  void _showDetailsOverlay(BuildContext context, History history) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        contentPadding: EdgeInsets.zero,
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      DateFormat('MMM d, yyyy').format(history.date),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      'By ${history.doctorName}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color),
                      onPressed: () {
                        Navigator.pop(context);
                        context.read<HistoryCubit>().setHistoryToView(null);
                      },
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Diagnosis',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      history.diagnosis,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Disease',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      history.disease,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Treatment',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      history.treatment,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    SizedBox(height: 5.h),
                    Text(
                      history.notes,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              if (history.notesImage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes Image',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      SizedBox(height: 5.h),
                      Image.network(
                        history.notesImage,
                        height: 100.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Text(
                          'Failed to load image',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Theme.of(context).colorScheme.error,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String childId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        title: Text(
          'Confirm Delete',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Are you sure you want to delete this history record?',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().deleteHistory(index, childId);
              Navigator.pop(context);
            },
            child: Text(
              'Delete',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.error,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}