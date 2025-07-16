import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:segma/cubits/ai_cubit.dart';
import 'package:segma/cubits/appointments_cubit.dart';
import 'package:segma/cubits/growth_cubit.dart';
import 'package:segma/cubits/medication_cubit.dart';
import 'package:segma/cubits/notification_cubit.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/cubits/selected_doctor_cubit.dart';
import 'package:segma/cubits/history_cubit.dart';
import 'package:segma/cubits/vaccination_cubit.dart';
import 'package:segma/cubits/sensor_cubit.dart';
import 'package:segma/screens/AI_user/AIScreen.dart';
import 'package:segma/screens/AI_user/chatbot_screen.dart';
import 'package:segma/screens/AI_user/questions_screen.dart';
import 'package:segma/screens/SplashScreen.dart';
import 'package:segma/screens/doctor/DoctorSettingsScreen.dart';
import 'package:segma/screens/childs/add_child_screen.dart';
import 'package:segma/screens/doctor/doctor_home_screen.dart';
import 'package:segma/screens/users/home_screen.dart';
import 'package:segma/screens/login_screen.dart';
import 'package:segma/screens/notifications_screen.dart';
import 'package:segma/screens/signup_screen.dart';
import 'package:segma/screens/onboarding_screen.dart'; // Added OnboardingScreen
import 'package:segma/services/auth_service.dart';
import 'package:segma/services/growth_service.dart';
import 'package:segma/services/notification_service.dart';
import 'package:segma/utils/providers.dart';
import 'package:segma/utils/themes.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📩 Background message received: ${message.notification?.title}');
  if (message.notification != null) {
    await NotificationService.showNotification(
      title: message.notification?.title ?? 'New Notification',
      body: message.notification?.body ?? 'You have a new message',
    );
  }
}

Future<void> _initializeFirebaseAndNotifications() async {
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyCEqnpRV8s7YV0oAZIVzgYjTAgLPbZB8kY",
        authDomain: "sigma-8d395.firebaseapp.com",
        projectId: "sigma-8d395",
        storageBucket: "sigma-8d395.firebasestorage.app",
        messagingSenderId: "970958422401",
        appId: "1:970958422401:web:acfecfdebf31a7a2c9e880",
        measurementId: "G-DMWRQYS73B",
      ),
    );
    print('✅ Firebase initialized successfully');

    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    print('📩 Notification permission status: ${settings.authorizationStatus}');

    await NotificationService.initialize();
    print('✅ NotificationService initialized successfully');

    // Save FCM token
    final fcmToken = await FirebaseMessaging.instance.getToken();
    if (fcmToken != null) {
      print('📩 FCM Token: $fcmToken');
      // Assuming role is fetched from AuthService after login
      await AuthService.saveFcmToken(fcmToken, null); // Role will be set after login
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message received: ${message.notification?.title}');
      if (message.notification != null) {
        NotificationService.showNotification(
          title: message.notification?.title ?? 'New Notification',
          body: message.notification?.body ?? 'You have a new message',
        );
      }
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📩 App opened from notification: ${message.notification?.title}');
      if (navigatorKey.currentContext != null) {
        Navigator.of(navigatorKey.currentContext!).pushNamed('/notifications');
      }
    });
  } catch (e) {
    print('🔥 Error initializing Firebase or NotificationService: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ScreenUtil.ensureScreenSize();
  await _initializeFirebaseAndNotifications();
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
          ],
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return MultiBlocProvider(
                providers: [
                  BlocProvider(create: (context) => MedicationCubit()),
                  BlocProvider(create: (context) => SelectedChildCubit()),
                  BlocProvider(create: (context) => SelectedDoctorCubit()),
                  BlocProvider(create: (context) => HistoryCubit()),
                  BlocProvider(create: (context) => VaccinationCubit()),
                  BlocProvider(create: (context) => GrowthCubit(growthService: GrowthService())),
                  BlocProvider(create: (context) => NotificationCubit()),
                  BlocProvider(create: (context) => AiCubit()),
                  BlocProvider(create: (context) => SensorCubit()),
                  BlocProvider(create: (context) => SelectedChildCubit()),
                  BlocProvider(create: (context) => SelectedDoctorCubit()),
                  BlocProvider(create: (context) => AppointmentsCubit()), // Added
                ],
                child: MaterialApp(
                  navigatorKey: navigatorKey,
                  debugShowCheckedModeBanner: false,
                  title: 'Sigma',
                  theme: AppThemes.lightTheme(context),
                  darkTheme: AppThemes.darkTheme(context),
                  themeMode: themeProvider.themeMode,
                  initialRoute: '/onboarding', // Changed to onboarding
                  routes: {
                     // Added OnboardingScreen
                    '/splash': (context) => const SplashScreen(),
                    '/onboarding': (context) => const OnboardingScreen(),
                    '/login': (context) => LoginScreen(),
                    '/signup': (context) => const SignupScreen(),
                    '/add-child': (context) => const AddChildScreen(),
                    '/home': (context) => const HomeScreen(),
                    '/doctor-home': (context) => const DoctorHomeScreen(),
                    '/settings': (context) => const SettingsScreen(),
                    '/doctor-settings': (context) => const SettingsScreen(),
                    '/notifications': (context) => const NotificationsScreen(),
                    '/ai': (context) => const AIScreen(),
                    '/chatbot': (context) => const ChatbotScreen(),
                  },
                  onGenerateRoute: (settings) {
                    if (settings.name == '/questions') {
                      final args = settings.arguments as Map<String, dynamic>?;
                      if (args != null && args.containsKey('condition')) {
                        return MaterialPageRoute(
                          builder: (context) => QuestionsScreen(condition: args['condition']),
                        );
                      }
                    }
                    return null;
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}
