import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/utils/colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildPage(
                  title: 'Manage Appointments',
                  description: 'Easily schedule and track your child’s doctor visits.',
                  icon: Icons.calendar_today,
                  color: AppColors.featureDoctor,
                ),
                _buildPage(
                  title: 'Consult with Doctors',
                  description: 'Get expert advice and book consultations with top doctors.',
                  icon: Icons.local_hospital,
                  color: AppColors.featureMedicine,
                ),
                _buildPage(
                  title: 'Track Vaccination',
                  description: 'Stay updated with your child’s vaccination schedule.',
                  icon: Icons.local_pharmacy,
                  color: AppColors.featureVaccination,
                ),
                _buildPage(
                  title: 'Monitor Health',
                  description: 'Check temperature, heart rate, and sleep quality.',
                  icon: Icons.favorite,
                  color: AppColors.featureAIGrowth,
                ),
                _buildPage(
                  title: 'View History',
                  description: 'Access your child’s medical history anytime.',
                  icon: Icons.history,
                  color: AppColors.featureMemories,
                ),
                _buildPage(
                  title: 'Growth & Medication',
                  description: 'Track growth and organize medication schedules.',
                  icon: Icons.trending_up,
                  color: AppColors.featureGrowth,
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: List.generate(6, (index) => Container(
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    width: _currentPage == index ? 12.w : 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: _currentPage == index
                          ? (isDarkMode ? AppColors.darkNavBarActive : AppColors.lightNavBarActive)
                          : (isDarkMode ? AppColors.darkNavBarInactive : AppColors.lightNavBarInactive),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  )),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == 5) {
                      Navigator.pushReplacementNamed(context, '/splash');
                    } else {
                      _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDarkMode ? AppColors.darkButtonPrimary : AppColors.lightButtonPrimary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  ),
                  child: Text(
                    _currentPage == 5 ? 'Get Started' : 'Next',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPage({required String title, required String description, required IconData icon, required Color color}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: EdgeInsets.all(20.r),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 80.sp, color: color),
        ),
        SizedBox(height: 30.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.w),
          child: Text(
            description,
            style: TextStyle(
              fontSize: 16.sp,
              color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}