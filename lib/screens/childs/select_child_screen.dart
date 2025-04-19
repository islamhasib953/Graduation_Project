import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/services/child_service.dart';
import 'package:segma/utils/colors.dart';

class SelectChildScreen extends StatefulWidget {
  const SelectChildScreen({super.key});

  @override
  State<SelectChildScreen> createState() => _SelectChildScreenState();
}

class _SelectChildScreenState extends State<SelectChildScreen> {
  List<Child> _children = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren() async {
    final response = await ChildService.getChildren();
    setState(() {
      _isLoading = false;
      if (response['status'] == 'success') {
        _children = response['data'] ?? [];
      } else {
        _error = response['message'] ?? 'Error loading children';
      }
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
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
              ),
            )
          : _error != null
              ? Center(
                  child: Text(
                    _error!,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.statusOverdue,
                        ),
                    textAlign: TextAlign.center,
                  ),
                )
              : _children.isEmpty
                  ? Center(
                      child: Text(
                        'No children found. Please add a child.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(16.w),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1,
                      ),
                      itemCount: _children.length,
                      itemBuilder: (context, index) {
                        final child = _children[index];
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
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
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
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
    );
  }
}