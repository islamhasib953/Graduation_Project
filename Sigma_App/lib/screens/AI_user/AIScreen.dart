import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/utils/colors.dart';

class AIScreen extends StatefulWidget {
  const AIScreen({super.key});

  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Assistant',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  AICard(
                    title: 'Stroke',
                    description: 'A condition caused by interrupted blood flow to the brain, leading to symptoms like weakness or speech difficulty.',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/questions',
                        arguments: {'condition': 'stroke'},
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  AICard(
                    title: 'Autism',
                    description: 'A developmental disorder affecting communication and behavior, with signs like repetitive actions or social challenges.',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/questions',
                        arguments: {'condition': 'autism'},
                      );
                    },
                  ),
                  SizedBox(height: 16.h),
                  AICard(
                    title: 'Asthma',
                    description: 'A respiratory condition causing breathing difficulties, triggered by allergens, exercise, or pollution.',
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/questions',
                        arguments: {'condition': 'asthma'},
                      );
                    },
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/chatbot');
                  },
                  backgroundColor: isDark ? AppColors.darkButtonPrimary : AppColors.lightButtonPrimary,
                  child: const Icon(Icons.chat),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AICard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onTap;

  const AICard({
    super.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: isDark ? AppColors.darkCardBackground : AppColors.lightCardBackground,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8.h),
              Text(
                description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}