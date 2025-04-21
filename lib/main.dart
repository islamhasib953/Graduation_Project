import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:segma/cubits/growth_cubit.dart';
import 'package:segma/cubits/medication_cubit.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/selected_doctor_cubit.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/cubits/vaccination_cubit.dart';
import 'package:segma/screens/SplashScreen.dart';
import 'package:segma/screens/childs/add_child_screen.dart';
import 'package:segma/screens/doctor/DoctorSettingsScreen.dart';
import 'package:segma/screens/doctor/doctor_home_screen.dart';
import 'package:segma/screens/users/home_screen.dart';
import 'package:segma/screens/login_screen.dart';
import 'package:segma/screens/signup_screen.dart';
import 'package:segma/services/growth_service.dart';
import 'package:segma/utils/providers.dart';
import 'package:segma/utils/themes.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ThemeProvider()),
            BlocProvider(create: (context) => MedicationCubit()),
            BlocProvider(create: (context) => SelectedChildCubit()),
            BlocProvider(create: (context) => SelectedDoctorCubit()),
            BlocProvider(create: (context) => HistoryCubit()),
            BlocProvider(create: (context) => VaccinationCubit()),
            BlocProvider(create: (context) => GrowthCubit(growthService: GrowthService())), // إضافة GrowthCubit
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'Care Kids',
                theme: AppThemes.lightTheme(context),
                darkTheme: AppThemes.darkTheme(context),
                themeMode: themeProvider.themeMode,
                initialRoute: '/splash',
                routes: {
                  '/splash': (context) => SplashScreen(),
                  '/login': (context) => LoginScreen(),
                  '/signup': (context) => SignupScreen(),
                  '/add-child': (context) => const AddChildScreen(),
                  '/home': (context) => const HomeScreen(),
                  '/doctor-home': (context) => const DoctorHomeScreen(),
                  '/settings': (context) => const SettingsScreen(),
                  '/doctor-settings': (context) => const SettingsScreen(),
                },
              );
            },
          ),
        );
      },
    );
  }
}