import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/cubits/memory_cubit.dart';
import 'package:segma/models/memory_model.dart';
import 'package:segma/screens/memory_user/memory_details_screen.dart';

class FavoriteMemoriesScreen extends StatefulWidget {
  final String childId;

  const FavoriteMemoriesScreen({Key? key, required this.childId}) : super(key: key);

  @override
  _FavoriteMemoriesScreenState createState() => _FavoriteMemoriesScreenState();
}

class _FavoriteMemoriesScreenState extends State<FavoriteMemoriesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    context.read<MemoryCubit>().loadFavoriteMemories(widget.childId);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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
        title: const Text('Favorite Memories'),
      ),
      body: BlocConsumer<MemoryCubit, MemoryState>(
        listener: (context, state) {
          if (state is MemoryError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is MemoryLoading) {
            return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
          } else if (state is MemoryLoaded) {
            if (state.memories.isEmpty) {
              return Center(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No favorite memories yet!',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Mark some memories as favorites to see them here.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              itemCount: state.memories.length,
              itemBuilder: (context, index) {
                final memory = state.memories[index];
                return FadeTransition(
                  opacity: _fadeAnimation,
                  child: FavoriteMemoryCard(
                    memory: memory,
                    onTap: () {
                      Navigator.push(
                        context,
                        _createSlideRoute(
                          BlocProvider.value(
                            value: context.read<MemoryCubit>(),
                            child: MemoryDetailsScreen(
                              memory: memory,
                              childId: widget.childId,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          } else if (state is MemoryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading favorite memories',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    state.message,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context.read<MemoryCubit>().loadFavoriteMemories(widget.childId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }
}

class FavoriteMemoryCard extends StatelessWidget {
  final Memory memory;
  final VoidCallback onTap;

  const FavoriteMemoryCard({Key? key, required this.memory, required this.onTap}) : super(key: key);

  String _truncateDescription(String description) {
    final words = description.split(' ');
    if (words.length <= 5) {
      return description;
    }
    return '${words.take(5).join(' ')}...';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
              blurRadius: 8.r,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: CachedNetworkImage(
                imageUrl: memory.image,
                width: 80.w,
                height: 80.h,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 80.w,
                  height: 80.h,
                  color: Colors.grey[300],
                  child: const Center(child: CircularProgressIndicator()),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 80.w,
                  height: 80.h,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.broken_image,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMM yyyy, hh:mm a').format(
                          DateTime.parse('${memory.date.toIso8601String().split('T')[0]} ${memory.time}'),
                        ),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10.sp),
                      ),
                      Icon(
                        Icons.favorite,
                        color: Colors.red,
                        size: 16.w,
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _truncateDescription(memory.description),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}