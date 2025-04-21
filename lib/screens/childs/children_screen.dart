import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/screens/childs/add_child_screen.dart';
import 'package:segma/screens/childs/child_details_screen.dart';
import 'package:segma/services/child_service.dart';
import 'package:segma/utils/colors.dart';

class ChildrenScreen extends StatefulWidget {
  const ChildrenScreen({Key? key}) : super(key: key);

  @override
  State<ChildrenScreen> createState() => _ChildrenScreenState();
}

class _ChildrenScreenState extends State<ChildrenScreen> {
  late Future<Map<String, dynamic>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = ChildService.getChildren();
  }

  void _refreshChildren() {
    if (mounted) {
      setState(() {
        _childrenFuture = ChildService.getChildren();
      });
    }
  }

  void _showDeleteConfirmationDialog(Child child) {
    // Save a reference to the context before the async operation
    final BuildContext dialogContext = context;

    showDialog(
      context: dialogContext,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Child',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Roboto',
              ),
        ),
        content: Text(
          'Are you sure you want to delete ${child.name}?',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Roboto',
              ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Cancel
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context); // Close the confirmation dialog
              final response = await ChildService.deleteChild(child.id, dialogContext);
              // Check if the widget is still mounted before using context
              if (!mounted) return;
              if (response['status'] == 'success') {
                _refreshChildren(); // Refresh the children list
                _showSuccessDialog(child.name);
              } else {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  SnackBar(
                    content: Text(response['message'] ?? 'Failed to delete child'),
                    backgroundColor: AppColors.statusOverdue,
                  ),
                );
              }
            },
            child: Text(
              'Confirm',
              style: TextStyle(
                fontFamily: 'Roboto',
                color: AppColors.statusOverdue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String childName) {
    // Use context directly since this is called synchronously after checking mounted
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        backgroundColor: Theme.of(context).cardColor,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.light
                      ? AppColors.lightButtonPrimary
                      : AppColors.darkButtonPrimary,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.check,
                size: 40.sp,
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Child Deleted',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontFamily: 'Roboto',
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              '$childName has been deleted successfully',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontFamily: 'Roboto',
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close the success dialog
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
                padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
              ),
              child: Text(
                'Back to Home',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontFamily: 'Roboto',
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Child',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontFamily: 'Roboto',
              ),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: GestureDetector(
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddChildScreen(),
                  ),
                );
                if (result == true) {
                  _refreshChildren();
                }
              },
              child: Row(
                children: [
                  Icon(
                    Icons.add,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightButtonPrimary
                        : AppColors.darkButtonPrimary,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    'Add Child',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightButtonPrimary
                              : AppColors.darkButtonPrimary,
                          fontFamily: 'Roboto',
                        ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _childrenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
              ),
            );
          }
          if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
            return Center(
              child: Text(
                'Error loading children',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.statusOverdue,
                      fontFamily: 'Roboto',
                    ),
                textAlign: TextAlign.center,
              ),
            );
          }
          final List<Child> children = snapshot.data!['data'] as List<Child>;
          if (children.isEmpty) {
            return Center(
              child: Text(
                'No children found',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontFamily: 'Roboto',
                    ),
                textAlign: TextAlign.center,
              ),
            );
          }
          return GridView.builder(
            padding: EdgeInsets.all(10.w),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              bool isPressed = false;
              return StatefulBuilder(
                builder: (context, setState) {
                  return GestureDetector(
                    onTapDown: (_) => setState(() => isPressed = true),
                    onTapUp: (_) {
                      setState(() => isPressed = false);
                      // Tapping the box itself only selects the child
                      context.read<SelectedChildCubit>().selectChild(child.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${child.name} selected'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onTapCancel: () => setState(() => isPressed = false),
                    child: AnimatedScale(
                      scale: isPressed ? 0.95 : 1.0,
                      duration: const Duration(milliseconds: 100),
                      child: Card(
                        color: Theme.of(context).cardColor,
                        elevation: 3,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            child.photo != null
                                ? CircleAvatar(
                                    radius: 40.r,
                                    backgroundImage: NetworkImage(child.photo!),
                                  )
                                : CircleAvatar(
                                    radius: 40.r,
                                    backgroundColor: Theme.of(context).brightness == Brightness.light
                                        ? AppColors.lightButtonPrimary
                                        : AppColors.darkButtonPrimary,
                                    child: Icon(
                                      Icons.person,
                                      size: 40.sp,
                                    ),
                                  ),
                            SizedBox(height: 10.h),
                            Text(
                              child.name,
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontFamily: 'Roboto',
                                  ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Details Button
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChildDetailsScreen(child: child),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).brightness == Brightness.light
                                        ? AppColors.lightButtonPrimary
                                        : AppColors.darkButtonPrimary,
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  ),
                                  child: Text(
                                    'Details',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8.w),
                                // Delete Button
                                ElevatedButton(
                                  onPressed: () {
                                    _showDeleteConfirmationDialog(child);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.statusOverdue,
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                  ),
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}