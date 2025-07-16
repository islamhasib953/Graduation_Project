import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/cubits/history_state.dart';
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

class _HistoryScreenState extends State<HistoryScreen> with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final childId = context.read<SelectedChildCubit>().state;
      if (childId != null && childId.isNotEmpty) {
        context.read<HistoryCubit>().initialize(childId: childId);
      }
    });

    context.read<SelectedChildCubit>().stream.listen((childId) {
      if (childId != null && childId.isNotEmpty) {
        context.read<HistoryCubit>().initialize(childId: childId);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  String truncateToTwoWords(String text) {
    final List<String> words = text.split(' ');
    if (words.length <= 2) {
      return text;
    }
    return '${words[0]} ${words[1]}...';
  }

  void _showDetailsOverlay(BuildContext context, History history) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        contentPadding: EdgeInsets.all(16.w),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMM d, yyyy').format(history.date), style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                  IconButton(icon: Icon(Icons.close, color: Theme.of(context).iconTheme.color, size: 24.sp), onPressed: () => Navigator.pop(context)),
                ],
              ),
              SizedBox(height: 10.h),
              Text('Diagnosis', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              Text(history.diagnosis, style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10.h),
              Text('Disease', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              Text(history.disease, style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10.h),
              Text('Treatment', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              Text(history.treatment, style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 10.h),
              Text('Notes', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              Text(history.notes, style: Theme.of(context).textTheme.bodyLarge),
              if (history.notesImage.isNotEmpty)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes Image', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
                      SizedBox(height: 5.h),
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: 150.h,
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            history.notesImage,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return Text('Failed to load image', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error));
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 10.h),
              Text('Doctor Name', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
              Text(history.doctorName ?? 'Dr. Islam Hasib', style: Theme.of(context).textTheme.bodyLarge),
              SizedBox(height: 20.h),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        title: Text('Confirm Delete', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold)),
        content: Text('Are you sure you want to delete this history record?', style: Theme.of(context).textTheme.bodyLarge),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
          ),
          TextButton(
            onPressed: () {
              context.read<HistoryCubit>().deleteHistory(index, childId);
              Navigator.pop(context);
            },
            child: Text('Delete', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.error)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SelectedChildCubit, String?>(
      listener: (context, childId) {
        if (childId != null && childId.isNotEmpty) {
          context.read<HistoryCubit>().initialize(childId: childId);
        }
      },
      child: BlocBuilder<HistoryCubit, HistoryState>(
        builder: (context, state) {
          final childId = context.read<SelectedChildCubit>().state;
          if (childId == null || childId.isEmpty) {
            return Scaffold(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              appBar: AppBar(
                backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
                elevation: 0,
                title: Text('History', style: Theme.of(context).textTheme.titleLarge),
              ),
              body: Center(
                child: Text('Please select a child to view history.', style: Theme.of(context).textTheme.bodyLarge),
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
                    if (childId.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryFilterScreen(childId: childId),
                        ),
                      ).then((_) {
                        context.read<HistoryCubit>().fetchHistory(childId);
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please select a child first.')),
                      );
                    }
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
                        Text('Add History', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).primaryColor)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            body: BlocBuilder<HistoryCubit, HistoryState>(
              builder: (context, state) {
                print('Building with state: $state');
                if (state is HistoryLoading) return const Center(child: CircularProgressIndicator());
                if (state is HistoryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(state.error ?? 'An error occurred', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
                        SizedBox(height: 16.h),
                        ElevatedButton(
                          onPressed: () {
                            if (childId.isNotEmpty) {
                              context.read<HistoryCubit>().fetchHistory(childId);
                            }
                          },
                          child: Text('Retry', style: Theme.of(context).textTheme.bodyMedium),
                        ),
                      ],
                    ),
                  );
                }

                List<History> histories = [];
                if (state is HistoryLoaded) {
                  histories = state.histories;
                  print('Loaded histories: $histories');
                } else if (state is HistoryUpdated) {
                  histories = state.histories;
                  print('Updated histories: $histories');
                } else if (state is HistoryViewUpdated) {
                  histories = state.histories;
                  print('View updated histories: $histories');
                }

                if (histories.isEmpty && state is! HistoryLoading) {
                  print('No histories found for childId: $childId');
                  return Center(child: Text('No history records available.', style: Theme.of(context).textTheme.bodyLarge));
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                  physics: const BouncingScrollPhysics(),
                  itemCount: histories.length,
                  itemBuilder: (context, index) {
                    final history = histories[index];
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                          margin: EdgeInsets.symmetric(vertical: 4.h),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Theme.of(context).cardColor, Theme.of(context).brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade200],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            padding: EdgeInsets.all(12.r),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(children: [Icon(Icons.local_hospital, size: 14.sp, color: Theme.of(context).primaryColor), SizedBox(width: 4.w), Text('Diagnosis', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))]),
                                      SizedBox(height: 2.h),
                                      Text(truncateToTwoWords(history.diagnosis), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 4.h),
                                      Row(children: [Icon(Icons.bug_report, size: 14.sp, color: Theme.of(context).primaryColor), SizedBox(width: 4.w), Text('Disease', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))]),
                                      SizedBox(height: 2.h),
                                      Text(truncateToTwoWords(history.disease), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                      SizedBox(height: 4.h),
                                      Row(children: [Icon(Icons.calendar_today, size: 14.sp, color: Theme.of(context).primaryColor), SizedBox(width: 4.w), Text('Date', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold))]),
                                      SizedBox(height: 2.h),
                                      Text(DateFormat('MMM d, yyyy').format(history.date), style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).brightness == Brightness.dark ? Colors.white70 : Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(children: [
                                      Tooltip(message: 'View Details', child: CircleAvatar(radius: 16.r, backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1), child: IconButton(icon: Icon(Icons.visibility, color: Theme.of(context).primaryColor, size: 18.sp), padding: EdgeInsets.zero, onPressed: () { context.read<HistoryCubit>().setHistoryToView(history); _showDetailsOverlay(context, history); }))),
                                      SizedBox(width: 4.w),
                                      Tooltip(message: 'Edit', child: CircleAvatar(radius: 16.r, backgroundColor: Colors.green.withOpacity(0.1), child: IconButton(icon: Icon(Icons.edit, color: Colors.green, size: 18.sp), padding: EdgeInsets.zero, onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => EditHistoryScreen(history: history, childId: childId))); }))),
                                      SizedBox(width: 4.w),
                                      Tooltip(message: 'Delete', child: CircleAvatar(radius: 16.r, backgroundColor: Theme.of(context).colorScheme.error.withOpacity(0.1), child: IconButton(icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error, size: 18.sp), padding: EdgeInsets.zero, onPressed: () { _confirmDelete(context, index, childId); }))),
                                    ]),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
