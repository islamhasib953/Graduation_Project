import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/screens/childs/add_child_screen.dart';
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
    setState(() {
      _childrenFuture = ChildService.getChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Select Child',
          style: Theme.of(context).textTheme.titleLarge,
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
                style: Theme.of(context).textTheme.bodyLarge,
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
                      context.read<SelectedChildCubit>().selectChild(child.id);
                      Navigator.pop(context);
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
                              style: Theme.of(context).textTheme.bodyLarge,
                              textAlign: TextAlign.center,
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