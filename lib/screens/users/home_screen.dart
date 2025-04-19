import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/screens/doctor_user/FavoriteDoctorsScreen.dart';
import 'package:segma/screens/doctor_user/doctors_appointments_screen.dart';
import 'package:segma/services/child_service.dart';
import 'package:segma/screens/childs/children_screen.dart';
import 'package:segma/screens/history_user/history_screen.dart';
import 'package:segma/screens/medicine_user/medicine_screen.dart';
import 'package:segma/screens/vaccination_user/vaccination_screen.dart';
import 'package:segma/screens/users/settings_screen.dart';
import 'package:intl/intl.dart';

class AIGrowthScreen extends StatelessWidget {
  const AIGrowthScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'AI Growth',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('AI Growth Screen')),
    );
  }
}

class CommunityScreen extends StatelessWidget {
  const CommunityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Community',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Community Screen')),
    );
  }
}

class MemoriesScreen extends StatelessWidget {
  const MemoriesScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Memories',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Memories Screen')),
    );
  }
}

class TemperatureScreen extends StatelessWidget {
  const TemperatureScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Temperature',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Temperature Screen')),
    );
  }
}

class SleepingQualityScreen extends StatelessWidget {
  const SleepingQualityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Sleeping Quality',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Sleeping Quality Screen')),
    );
  }
}

class HeartRateScreen extends StatelessWidget {
  const HeartRateScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Heart Rate',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Heart Rate Screen')),
    );
  }
}

class OxygenScreen extends StatelessWidget {
  const OxygenScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Oxygen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: const Center(child: Text('Oxygen Screen')),
    );
  }
}

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
        children: [
          Center(
            child: Text(
              'Emergency Screen',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const HistoryScreen(),
          const HomeContent(),
          const FavoriteDoctorsScreen(),
          const SettingsScreen(),
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
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
        unselectedLabelStyle: Theme.of(context).textTheme.bodyMedium,
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
                return Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ),
                );
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
                return Center(
                  child: Text(
                    'Error loading child data',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }
              final List<Child> children = snapshot.data!['data'] as List<Child>;
              if (children.isEmpty) {
                return Center(
                  child: Text(
                    'No children found',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }
              final selectedChild = children.firstWhere(
                (child) => child.id == childId,
                orElse: () => children.first,
              );
              return Column(
                children: [
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Card(
                        elevation: 4,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
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
                                  color: Theme.of(context).primaryColor,
                                  errorBuilder: (context, error, stackTrace) {
                                    print('Error loading arrows.png: $error');
                                    return Icon(
                                      Icons.swap_horiz,
                                      size: 20.w,
                                      color: Theme.of(context).primaryColor,
                                    );
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    CircleAvatar(
                                      radius: 16.r,
                                      backgroundImage: selectedChild.photo != null ? NetworkImage(selectedChild.photo!) : null,
                                      child: selectedChild.photo == null
                                          ? Icon(
                                              Icons.person,
                                              color: Theme.of(context).primaryColor,
                                              size: 16.r,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: 8.w),
                                    Text(
                                      'Hi ${selectedChild.name}',
                                      style: Theme.of(context).textTheme.titleLarge,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.notifications,
                                size: 20.w,
                                color: Theme.of(context).primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Card(
                        elevation: 4,
                        color: Theme.of(context).cardColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/battery_icon.png',
                                    width: 16.w,
                                    height: 16.h,
                                    color: Theme.of(context).iconTheme.color,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading battery_icon.png: $error');
                                      return Icon(
                                        Icons.battery_unknown,
                                        size: 16.w,
                                        color: Theme.of(context).iconTheme.color,
                                      );
                                    },
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Connected 95%',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              Text(
                                DateFormat('EEEE, d MMM yyyy').format(DateTime.now()),
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
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
                              child: Card(
                                elevation: 4,
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                                child: SizedBox(
                                  height: 120.h,
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
                                                color: Theme.of(context).primaryColor,
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
                                            color: Theme.of(context).primaryColor,
                                            borderRadius: BorderRadius.circular(8.r),
                                          ),
                                          child: Text(
                                            '15 KM',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                  color: Theme.of(context).colorScheme.onPrimary,
                                                ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 10.h,
                                        right: 10.w,
                                        child: Text(
                                          'Port Said',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Theme.of(context).colorScheme.onPrimary,
                                                shadows: [
                                                  Shadow(
                                                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
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
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w),
                            child: GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              crossAxisSpacing: 10.w,
                              mainAxisSpacing: 10.h,
                              childAspectRatio: 1,
                              children: [
                                HealthCard(
                                  title: 'Temperature',
                                  value: '37°C',
                                  status: 'Normal',
                                  statusColor: Colors.green,
                                  iconPath: 'assets/temperature_icon.png',
                                  onTap: () => Navigator.push(context, _createSlideRoute(const TemperatureScreen())),
                                  animationController: _animationController,
                                ),
                                HealthCard(
                                  title: 'Sleeping Quality',
                                  value: '70%',
                                  status: 'Ideal',
                                  statusColor: Colors.green,
                                  iconPath: 'assets/sleeping_quality_icon.png',
                                  onTap: () => Navigator.push(context, _createSlideRoute(const SleepingQualityScreen())),
                                  animationController: _animationController,
                                ),
                                HealthCard(
                                  title: 'Heart Rate',
                                  value: '75%',
                                  status: '',
                                  statusColor: Colors.transparent,
                                  iconPath: 'assets/heart_rate_icon.png',
                                  onTap: () => Navigator.push(context, _createSlideRoute(const HeartRateScreen())),
                                  animationController: _animationController,
                                ),
                                HealthCard(
                                  title: 'Oxygen',
                                  value: '110 bpm',
                                  status: 'Normal',
                                  statusColor: Colors.green,
                                  iconPath: 'assets/oxygen_icon.png',
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
                                  destination: const AIGrowthScreen(),
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
                                  destination: const MemoriesScreen(),
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

class HealthCard extends StatefulWidget {
  final String title;
  final String value;
  final String status;
  final Color statusColor;
  final String iconPath;
  final VoidCallback onTap;
  final AnimationController animationController;

  const HealthCard({
    Key? key,
    required this.title,
    required this.value,
    required this.status,
    required this.statusColor,
    required this.iconPath,
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

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _colorAnimation = ColorTween(
      begin: Colors.transparent,
      end: Theme.of(context).colorScheme.surface.withOpacity(0.1),
    ).animate(CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut));
    _elevationAnimation = Tween<double>(begin: 2.0, end: 6.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
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
                        Image.asset(
                          widget.iconPath,
                          width: 24.w,
                          height: 24.h,
                          color: Theme.of(context).primaryColor,
                          errorBuilder: (context, error, stackTrace) {
                            print('Error loading ${widget.iconPath}: $error');
                            return Icon(
                              Icons.broken_image,
                              size: 24.w,
                              color: Theme.of(context).primaryColor,
                            );
                          },
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          widget.title,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          widget.value,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                color: Theme.of(context).primaryColor,
                              ),
                        ),
                        if (widget.status.isNotEmpty) SizedBox(height: 2.h),
                        if (widget.status.isNotEmpty)
                          Text(
                            widget.status,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
  Widget build( context) {
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
              child: Card(
                elevation: 4,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                child: Padding(
                  padding: EdgeInsets.all(8.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        widget.iconPath,
                        width: 48.w,
                        height: 48.h,
                        errorBuilder: (context, error, stackTrace) {
                          print('Error loading ${widget.iconPath}: $error');
                          return Icon(
                            Icons.broken_image,
                            size: 48.w,
                            color: Theme.of(context).primaryColor,
                          );
                        },
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}