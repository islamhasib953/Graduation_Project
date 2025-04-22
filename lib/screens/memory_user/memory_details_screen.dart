import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/memory_cubit.dart';
import 'package:segma/models/memory_model.dart';
import 'package:segma/screens/memory_user/add_edit_memory_screen.dart';

class MemoryDetailsScreen extends StatelessWidget {
  final Memory memory;
  final String childId;

  const MemoryDetailsScreen({
    Key? key,
    required this.memory,
    required this.childId,
  }) : super(key: key);

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: const Duration(milliseconds: 500),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);
        return SlideTransition(
          position: offsetAnimation,
          child: child,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                _createSlideRoute(
                  BlocProvider.value(
                    value: context.read<MemoryCubit>(),
                    child: AddEditMemoryScreen(
                      memory: memory,
                      childId: childId,
                    ),
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
                  title: const Text('Delete Memory'),
                  content: const Text('Are you sure you want to delete this memory?'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(dialogContext);
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<MemoryCubit>().deleteMemory(childId, memory.id);
                        Navigator.pop(dialogContext);
                        Navigator.pop(context); // Return to MemoriesScreen
                      },
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: memory.image,
                width: double.infinity,
                height: 300.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 300.h,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => const Center(
                  child: Icon(Icons.broken_image, size: 50),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Date: ${DateFormat('dd MMM yyyy').format(memory.date)}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              'Time: ${memory.time}',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            Text(
              'Description:',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              memory.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}