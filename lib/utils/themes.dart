import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/utils/colors.dart';

class AppThemes {
  static ThemeData lightTheme(BuildContext context) {
    const fontFamily = 'Poppins'; // خط ثابت بدون توطين

    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.lightBackground,
      primaryColor: AppColors.lightButtonPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.lightCardBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        iconTheme: IconThemeData(
          color: AppColors.lightIcon,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontFamily: fontFamily,
          fontSize: 16.sp,
        ),
        bodyMedium: TextStyle(
          color: AppColors.lightTextSecondary,
          fontFamily: fontFamily,
          fontSize: 14.sp,
        ),
        titleLarge: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
      cardColor: AppColors.lightCardBackground,
      dividerColor: AppColors.lightSearchBackground,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.lightButtonPrimary,
          foregroundColor: Colors.white, // تغيير لون النص/الأيقونات للأبيض عشان يتناسب مع الأزرق
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontFamily: fontFamily,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.lightButtonPrimary,
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: fontFamily,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.lightIcon,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.lightCardBackground,
        contentTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 14.sp,
          fontFamily: fontFamily,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.lightNavBarBackground,
        selectedItemColor: AppColors.lightNavBarActive,
        unselectedItemColor: AppColors.lightNavBarInactive,
        selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 12.sp),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 12.sp),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.lightNavBarActive,
        unselectedLabelColor: AppColors.lightNavBarInactive,
        labelStyle: TextStyle(fontFamily: fontFamily, fontSize: 14.sp),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 14.sp),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.lightNavBarActive, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSearchBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.lightSearchBackground),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.lightButtonPrimary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.lightSearchBackground),
        ),
        labelStyle: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14.sp,
          fontFamily: fontFamily,
        ),
        hintStyle: TextStyle(
          color: AppColors.lightTextSecondary,
          fontSize: 14.sp,
          fontFamily: fontFamily,
        ),
      ),
      dialogBackgroundColor: AppColors.lightCardBackground,
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.lightButtonPrimary),
      ),
    );
  }

  static ThemeData darkTheme(BuildContext context) {
    const fontFamily = 'Poppins'; // خط ثابت بدون توطين

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.darkBackground,
      primaryColor: AppColors.darkButtonPrimary,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.darkCardBackground,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        iconTheme: IconThemeData(
          color: AppColors.darkIcon,
        ),
      ),
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontFamily: fontFamily,
          fontSize: 16.sp,
        ),
        bodyMedium: TextStyle(
          color: AppColors.darkTextSecondary,
          fontFamily: fontFamily,
          fontSize: 14.sp,
        ),
        titleLarge: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
        titleMedium: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 16.sp,
          fontWeight: FontWeight.w600,
          fontFamily: fontFamily,
        ),
      ),
      cardColor: AppColors.darkCardBackground,
      dividerColor: AppColors.darkSearchBackground,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkButtonPrimary,
          foregroundColor: Colors.white, // تغيير لون النص/الأيقونات للأبيض عشان يتناسب مع الأزرق الفاتح
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          textStyle: TextStyle(
            fontSize: 16.sp,
            fontFamily: fontFamily,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.darkButtonPrimary,
          textStyle: TextStyle(
            fontSize: 14.sp,
            fontFamily: fontFamily,
          ),
        ),
      ),
      iconTheme: IconThemeData(
        color: AppColors.darkIcon,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.darkCardBackground,
        contentTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 14.sp,
          fontFamily: fontFamily,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.darkNavBarBackground,
        selectedItemColor: AppColors.darkNavBarActive,
        unselectedItemColor: AppColors.darkNavBarInactive,
        selectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 12.sp),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 12.sp),
      ),
      tabBarTheme: TabBarTheme(
        labelColor: AppColors.darkNavBarActive,
        unselectedLabelColor: AppColors.darkNavBarInactive,
        labelStyle: TextStyle(fontFamily: fontFamily, fontSize: 14.sp),
        unselectedLabelStyle: TextStyle(fontFamily: fontFamily, fontSize: 14.sp),
        indicator: UnderlineTabIndicator(
          borderSide: BorderSide(color: AppColors.darkNavBarActive, width: 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSearchBackground,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.darkSearchBackground),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.darkButtonPrimary),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.darkSearchBackground),
        ),
        labelStyle: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14.sp,
          fontFamily: fontFamily,
        ),
        hintStyle: TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14.sp,
          fontFamily: fontFamily,
        ),
      ),
      dialogBackgroundColor: AppColors.darkCardBackground,
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all(AppColors.darkButtonPrimary),
      ),
    );
  }
}