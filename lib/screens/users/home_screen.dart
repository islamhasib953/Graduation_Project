import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/growth_cubit.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/screens/childs/child_details_screen.dart';
import 'package:segma/screens/community_screen.dart';
import 'package:segma/screens/doctor/DoctorSettingsScreen.dart';
import 'package:segma/screens/doctor_user/FavoriteDoctorsScreen.dart';
import 'package:segma/screens/doctor_user/doctors_appointments_screen.dart';
import 'package:segma/screens/memory_user/MemoriesScreen.dart';
import 'package:segma/screens/sensors/heart_rate_screen.dart';
import 'package:segma/screens/sensors/oxygen_screen.dart';
import 'package:segma/screens/sensors/sleeping_quality_screen.dart';
import 'package:segma/screens/sensors/temperature_screen.dart';
import 'package:segma/services/child_service.dart';
import 'package:segma/screens/childs/children_screen.dart';
import 'package:segma/screens/history_user/history_screen.dart';
import 'package:segma/screens/medicine_user/medicine_screen.dart';
import 'package:segma/screens/vaccination_user/vaccination_screen.dart';
import 'package:segma/screens/users/settings_screen.dart';
import 'package:intl/intl.dart';
import 'package:segma/utils/colors.dart';
import '../growth_user/GrowthScreen.dart';
import 'package:segma/cubits/memory_cubit.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'dart:async';
import 'dart:math';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late ScrollController _featuresScrollController;
  int _selectedIndex = 2;

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

    _featuresScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInfiniteScroll();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _featuresScrollController.dispose();
    super.dispose();
  }

  void _startInfiniteScroll() {
    if (_featuresScrollController.hasClients) {
      double maxExtent = _featuresScrollController.position.maxScrollExtent;
      double currentOffset = _featuresScrollController.offset;

      if (currentOffset >= maxExtent) {
        _featuresScrollController.jumpTo(0);
      }

      _featuresScrollController.animateTo(
        currentOffset + 1000,
        duration: const Duration(seconds: 10),
        curve: Curves.linear,
      ).then((_) {
        _startInfiniteScroll();
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          Center(child: Text('Emergency Screen')),
          HistoryScreen(),
          HomeContent(),
          FavoriteDoctorsScreen(),
          SettingsScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.emergency), label: 'Emergency'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favorite'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).bottomNavigationBarTheme.selectedItemColor,
        unselectedItemColor: Theme.of(context).bottomNavigationBarTheme.unselectedItemColor,
        backgroundColor: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: Theme.of(context).bottomNavigationBarTheme.selectedLabelStyle,
        unselectedLabelStyle: Theme.of(context).bottomNavigationBarTheme.unselectedLabelStyle,
      ),
    );
  }
}

class HomeContent extends StatefulWidget {
  const HomeContent({Key? key}) : super(key: key);

  @override
  _HomeContentState createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late ScrollController _featuresScrollController;

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
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    _featuresScrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startInfiniteScroll();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _featuresScrollController.dispose();
    super.dispose();
  }

  void _startInfiniteScroll() {
    if (_featuresScrollController.hasClients) {
      double maxExtent = _featuresScrollController.position.maxScrollExtent;
      double currentOffset = _featuresScrollController.offset;

      if (currentOffset >= maxExtent) {
        _featuresScrollController.jumpTo(0);
      }

      _featuresScrollController.animateTo(
        currentOffset + 1000,
        duration: const Duration(seconds: 10),
        curve: Curves.linear,
      ).then((_) {
        _startInfiniteScroll();
      });
    }
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
    return SafeArea(
      child: BlocBuilder<SelectedChildCubit, String?>(
        builder: (context, childId) {
          return FutureBuilder<Map<String, dynamic>>(
            future: ChildService.getChildren(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator(color: Theme.of(context).colorScheme.primary));
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
                return const Center(child: Text('Error loading child data'));
              }
              final List<Child> children = snapshot.data!['data'] as List<Child>;
              if (children.isEmpty) {
                return const Center(child: Text('No children found'));
              }
              final selectedChild = children.firstWhere(
                (child) => child.id == childId,
                orElse: () => children.first,
              );

              WidgetsBinding.instance.addPostFrameCallback((_) {
                context.read<GrowthCubit>().initialize(
                      childId: selectedChild.id,
                    );
              });

              return Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(context, _createSlideRoute(const ChildrenScreen()));
                              },
                              child: Image.asset(
                                'assets/arrows.png',
                                width: 20.w,
                                height: 20.h,
                                color: Theme.of(context).colorScheme.primary,
                                errorBuilder: (context, error, stackTrace) {
                                  print('Error loading arrows.png: $error');
                                  return Icon(
                                    Icons.swap_horiz,
                                    size: 20.w,
                                    color: Theme.of(context).colorScheme.primary,
                                  );
                                },
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    _createSlideRoute(ChildDetailsScreen(child: selectedChild)),
                                  );
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 16.r,
                                      backgroundImage: selectedChild.photo != null ? NetworkImage(selectedChild.photo!) : null,
                                      child: selectedChild.photo == null
                                          ? Icon(
                                              Icons.person,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: 16.r,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Hi ${selectedChild.name}',
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14.sp),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.notifications,
                              size: 20.w,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Image.asset(
                                  'assets/battery_icon.png',
                                  width: 16.w,
                                  height: 16.h,
                                  color: Theme.of(context).textTheme.bodyMedium?.color,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading battery_icon.png: $error');
                                    return Icon(
                                      Icons.battery_unknown,
                                      size: 16.w,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    );
                                  },
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Connected 95%',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10.sp),
                                ),
                              ],
                            ),
                            Text(
                              DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          FadeTransition(
                            opacity: _fadeAnimation,
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: Container(
                                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                height: 120.h,
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
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12.r),
                                      child: Image.asset(
                                        'assets/map_placeholder.png',
                                        width: double.infinity,
                                        height: 120.h,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          print('Error loading map_placeholder.png: $error');
                                          return Center(
                                            child: Icon(
                                              Icons.map,
                                              color: Theme.of(context).colorScheme.primary,
                                              size: 50,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    Positioned(
                                      top: 10.h,
                                      left: 10.w,
                                      child: Container(
                                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).colorScheme.primary,
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Text(
                                          '15 KM',
                                          style: TextStyle(
                                            fontFamily: 'Roboto',
                                            fontSize: 10.sp,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 10.h,
                                      right: 10.w,
                                      child: Text(
                                        'Port Said',
                                        style: TextStyle(
                                          fontFamily: 'Roboto',
                                          fontSize: 12.sp,
                                          color: Colors.white,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black54,
                                              blurRadius: 4.r,
                                              offset: const Offset(1, 1),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                              childAspectRatio: 0.95,
                              children: [
                                HealthCard(
                                  title: 'Temperature',
                                  value: '37°C',
                                  status: 'Normal',
                                  statusColor: Theme.of(context).colorScheme.secondary,
                                  chartType: ChartType.funnel,
                                  onTap: () => Navigator.push(context, _createSlideRoute(const TemperatureScreen())),
                                  animationController: _animationController,
                                ),
                                HealthCard(
                                  title: 'Sleeping Quality',
                                  value: '70%',
                                  status: 'Ideal',
                                  statusColor: Theme.of(context).colorScheme.secondary,
                                  chartType: ChartType.radialBar,
                                  onTap: () => Navigator.push(context, _createSlideRoute(const SleepingQualityScreen())),
                                  animationController: _animationController,
                                ),
                                HealthCard(
                                  title: 'Heart Rate',
                                  value: '75 bpm',
                                  status: '',
                                  statusColor: Color.fromARGB(0, 41, 207, 7),
                                  chartType: ChartType.live,
                                  onTap: () => Navigator.push(context, _createSlideRoute(const HeartRateScreen())),
                                  animationController: _animationController,
                                ),
                                HealthCard(
                                  title: 'Oxygen',
                                  value: '110 bpm',
                                  status: 'Normal',
                                  statusColor: Theme.of(context).colorScheme.secondary,
                                  chartType: ChartType.area,
                                  onTap: () => Navigator.push(context, _createSlideRoute(const OxygenScreen())),
                                  animationController: _animationController,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 120.h,
                            child: ListView(
                              controller: _featuresScrollController,
                              scrollDirection: Axis.horizontal,
                              children: [
                                FeatureCard(
                                  iconPath: 'assets/vaccination_icon.png',
                                  label: 'Vaccination',
                                  destination: const VaccinationScreen(),
                                  animationController: _animationController,
                                ),
                                FeatureCard(
                                  iconPath: 'assets/ai_growth_icon.png',
                                  label: 'AI Growth',
                                  destination: GrowthScreen2(
                                    childId: selectedChild.id,
                                  ),
                                  animationController: _animationController,
                                ),
                                FeatureCard(
                                  iconPath: 'assets/doctor_icon.png',
                                  label: 'Doctor',
                                  destination: const DoctorsAppointmentsScreen(),
                                  animationController: _animationController,
                                ),
                                FeatureCard(
                                  iconPath: 'assets/community_icon.png',
                                  label: 'Community',
                                  destination: const CommunityScreen(),
                                  animationController: _animationController,
                                ),
                                FeatureCard(
                                  iconPath: 'assets/medicine_icon.png',
                                  label: 'Medicine',
                                  destination: const MedicineScreen(),
                                  animationController: _animationController,
                                ),
                                FeatureCard(
                                  iconPath: 'assets/memories_icon.png',
                                  label: 'Memories',
                                  destination: BlocProvider(
                                    create: (context) => MemoryCubit(),
                                    child: MemoriesScreen(childId: selectedChild.id),
                                  ),
                                  animationController: _animationController,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

enum ChartType { live, funnel, radialBar, area }

class ChartData {
  ChartData(this.x, this.y, [this.color]);
  final dynamic x;
  final num y;
  final Color? color;
}

class HealthCard extends StatefulWidget {
  final String title;
  final String value;
  final String status;
  final Color statusColor;
  final ChartType chartType;
  final VoidCallback onTap;
  final AnimationController animationController;

  const HealthCard({
    Key? key,
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.chartType,
    required this.onTap,
    required this.animationController,
  }) : super(key: key);

  @override
  _HealthCardState createState() => _HealthCardState();
}

class _HealthCardState extends State<HealthCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _elevationAnimation;

  // For Live Chart (Heart Rate)
  List<ChartData> _heartRateData = [];
  late Timer _timer;
  int _dataPoints = 0;
  final int _maxDataPoints = 12;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Colors.grey.withOpacity(0.1),
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
    _elevationAnimation = Tween<double>(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );

    // Initialize Heart Rate data for Live Chart
    if (widget.chartType == ChartType.live) {
      _heartRateData = [
        ChartData(0, 75),
      ];
      _dataPoints = 1;
      _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
        setState(() {
          if (_dataPoints >= _maxDataPoints) {
            _heartRateData.removeAt(0);
            for (int i = 0; i < _heartRateData.length; i++) {
              _heartRateData[i] = ChartData(i, _heartRateData[i].y);
            }
          }
          final random = Random();
          final newValue = 70 + random.nextInt(10);
          _heartRateData.add(ChartData(_dataPoints, newValue));
          _dataPoints++;
        });
      });
    }
  }

  @override
  void dispose() {
    _hoverController.dispose();
    if (widget.chartType == ChartType.live) {
      _timer.cancel();
    }
    super.dispose();
  }

  Widget _buildChart() {
    final isDarkTheme = Theme.of(context).brightness == Brightness.dark;

    switch (widget.chartType) {
      case ChartType.live:
        return SizedBox(
          width: 80.w,
          height: 80.h,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: isDarkTheme
                    ? [AppColors.darkButtonPrimary, Colors.teal[700]!]
                    : [AppColors.lightButtonPrimary, Colors.green[200]!],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            child: SfCartesianChart(
              primaryXAxis: const NumericAxis(
                isVisible: false,
                minimum: 0,
                maximum: 11,
              ),
              primaryYAxis: const NumericAxis(
                isVisible: false,
                minimum: 60,
                maximum: 90,
              ),
              plotAreaBorderWidth: 0,
              enableAxisAnimation: true,
              series: <CartesianSeries<ChartData, num>>[
                SplineSeries<ChartData, num>(
                  dataSource: _heartRateData,
                  xValueMapper: (ChartData data, _) => data.x,
                  yValueMapper: (ChartData data, _) => data.y,
                  width: 3,
                  color: Colors.white, // Set to white so the gradient can be applied via ShaderMask
                  markerSettings: const MarkerSettings(
                    isVisible: true,
                    height: 4,
                    width: 4,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
      case ChartType.funnel:
        final List<ChartData> chartData = [
          ChartData('Temperature', 37),
        ];
        return SizedBox(
          width: 80.w,
          height: 80.h,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: isDarkTheme
                    ? [const Color.fromARGB(255, 235, 108, 74), const Color.fromARGB(255, 133, 221, 134)!]
                    : [AppColors.statusOverdue, Colors.red[200]!],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds);
            },
            child: SfFunnelChart(
              series: FunnelSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                pointColorMapper: (ChartData data, _) => Colors.white,
                neckHeight: '20%',
                height: '100%',
                width: '60%',
              ),
            ),
          ),
        );
      case ChartType.radialBar:
        final List<ChartData> chartData = [
          ChartData('Quality', 70, isDarkTheme ? AppColors.darkIcon : AppColors.statusUpcoming),
        ];
        return SizedBox(
          width: 80.w,
          height: 80.h,
          child: SfCircularChart(
            series: <CircularSeries<ChartData, String>>[
              RadialBarSeries<ChartData, String>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                pointColorMapper: (ChartData data, _) => data.color,
                maximumValue: 100,
                radius: '100%',
                innerRadius: '60%',
                trackColor: isDarkTheme ? AppColors.darkSearchBackground : Colors.grey.withOpacity(0.3),
              ),
            ],
          ),
        );
      case ChartType.area:
        final List<ChartData> chartData = [
          ChartData(0, 108),
          ChartData(1, 109),
          ChartData(2, 110),
          ChartData(3, 111),
          ChartData(4, 110),
          ChartData(5, 109),
          ChartData(6, 110),
        ];
        return SizedBox(
          width: 80.w,
          height: 80.h,
          child: SfCartesianChart(
            primaryXAxis: const NumericAxis(
              isVisible: false,
              minimum: 0,
              maximum: 6,
            ),
            primaryYAxis: const NumericAxis(
              isVisible: false,
              minimum: 100,
              maximum: 120,
            ),
            plotAreaBorderWidth: 0,
            enableAxisAnimation: false,
            series: <CartesianSeries<ChartData, num>>[
              AreaSeries<ChartData, num>(
                dataSource: chartData,
                xValueMapper: (ChartData data, _) => data.x,
                yValueMapper: (ChartData data, _) => data.y,
                color: (isDarkTheme ? AppColors.darkButtonPrimary : AppColors.lightIcon).withOpacity(0.6),
                borderColor: isDarkTheme ? AppColors.darkButtonPrimary : AppColors.lightIcon,
                borderWidth: 2,
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController, curve: Curves.easeInOut),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: widget.animationController, curve: Curves.easeInOut),
        ),
        child: MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          child: AnimatedBuilder(
            animation: _hoverController,
            builder: (context, child) {
              return Card(
                elevation: _elevationAnimation.value,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: _colorAnimation.value,
                  ),
                  child: InkWell(
                    onTap: widget.onTap,
                    borderRadius: BorderRadius.circular(12.r),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildChart(),
                        SizedBox(height: 6.h),
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12.sp),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.value,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontSize: 14.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                        ),
                        if (widget.status.isNotEmpty) SizedBox(height: 4.h),
                        if (widget.status.isNotEmpty)
                          Text(
                            widget.status,
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: 12.sp,
                              color: widget.statusColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class FeatureCard extends StatefulWidget {
  final String iconPath;
  final String label;
  final Widget destination;
  final AnimationController animationController;

  const FeatureCard({
    Key? key,
    required this.iconPath,
    required this.label,
    required this.destination,
    required this.animationController,
  }) : super(key: key);

  @override
  _FeatureCardState createState() => _FeatureCardState();
}

class _FeatureCardState extends State<FeatureCard> with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _hoverAnimation;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _hoverAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
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
    return FadeTransition(
      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: widget.animationController, curve: Curves.easeInOut),
      ),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: widget.animationController, curve: Curves.easeInOut),
        ),
        child: MouseRegion(
          onEnter: (_) => _hoverController.forward(),
          onExit: (_) => _hoverController.reverse(),
          child: ScaleTransition(
            scale: _hoverAnimation,
            child: GestureDetector(
              onTap: () => Navigator.push(context, _createSlideRoute(widget.destination)),
              child: Container(
                width: 60.w,
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      widget.iconPath,
                      width: 48.w,
                      height: 48.h,
                      color: Theme.of(context).colorScheme.primary,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading ${widget.iconPath}: $error');
                        return Icon(
                          Icons.broken_image,
                          size: 48.w,
                          color: Theme.of(context).colorScheme.primary,
                        );
                      },
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      widget.label,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 10.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}