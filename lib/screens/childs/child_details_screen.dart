import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/screens/childs/add_child_screen.dart';
import 'package:segma/screens/childs/child_card_screen.dart';
import 'package:segma/screens/childs/parent_info_screen.dart';
import 'package:segma/utils/colors.dart';

class ChildDetailsScreen extends StatelessWidget {
  final Child child;

  const ChildDetailsScreen({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formattedBirthDate = DateFormat('dd MMM').format(child.birthDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Baby Details',
          style: TextStyle(
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Child Header
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child.name,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 20.sp,
                                fontFamily: 'Roboto',
                              ),
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              child.gender == 'Boy' ? Icons.male : Icons.female,
                              color: child.gender == 'Boy' ? Colors.blue : Colors.pink,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              child.gender,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                            ),
                            SizedBox(width: 16.w),
                            Icon(
                              Icons.cake,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              formattedBirthDate,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.fitness_center,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${child.weightAtBirth} kg',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                            ),
                            SizedBox(width: 16.w),
                            Icon(
                              Icons.height,
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${child.heightAtBirth} cm',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.circle, // رمز دائرة لمحيط الرأس
                              color: Theme.of(context).brightness == Brightness.light
                                  ? AppColors.lightTextSecondary
                                  : AppColors.darkTextSecondary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              '${child.headCircumferenceAtBirth} cm', // عرض الحقل الجديد
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Row(
                          children: [
                            Icon(
                              Icons.bloodtype,
                              color: Colors.red,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Text(
                              child.bloodType,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 50.r,
                    backgroundImage: child.photo != null ? NetworkImage(child.photo!) : null,
                    child: child.photo == null
                        ? Icon(
                            Icons.person,
                            size: 50.sp,
                            color: Theme.of(context).iconTheme.color,
                          )
                        : null,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              // Baby Profile Section
              Text(
                'BABY PROFILE',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontFamily: 'Roboto',
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
              ),
              SizedBox(height: 8.h),
              _buildListTile(
                context,
                icon: Icons.person,
                title: 'Parent Info',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParentInfoScreen(child: child),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.card_membership,
                title: 'Baby Card',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BabyCardScreen(child: child),
                    ),
                  );
                },
              ),
              _buildListTile(
                context,
                icon: Icons.edit,
                title: 'Edit Baby Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddChildScreen(child: child),
                    ),
                  ).then((result) {
                    if (result == true) {
                      // يمكن إضافة refresh للبيانات هنا
                    }
                  });
                },
              ),
              SizedBox(height: 16.h),
              // Export Section
              Text(
                'EXPORT',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 16.sp,
                      fontFamily: 'Roboto',
                      color: Theme.of(context).brightness == Brightness.light
                          ? AppColors.lightTextSecondary
                          : AppColors.darkTextSecondary,
                    ),
              ),
              SizedBox(height: 8.h),
              _buildListTile(
                context,
                icon: Icons.vaccines,
                title: 'Vaccination Schedule',
                onTap: () {
                  // يمكن إضافة navigation إلى شاشة جدول التطعيمات هنا
                },
              ),
              _buildListTile(
                context,
                icon: Icons.show_chart,
                title: 'Growth Chart',
                onTap: () {
                  // يمكن إضافة navigation إلى شاشة مخطط النمو هنا
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 2, // Home
        onTap: (index) {
          // يمكن إضافة navigation للـ BottomNavigationBar هنا
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.emergency),
            label: 'Emergency',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorite',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Card(
      color: Theme.of(context).cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightTextSecondary
              : AppColors.darkTextSecondary,
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontFamily: 'Roboto',
              ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Theme.of(context).brightness == Brightness.light
              ? AppColors.lightTextSecondary
              : AppColors.darkTextSecondary,
        ),
        onTap: onTap,
      ),
    );
  }
}