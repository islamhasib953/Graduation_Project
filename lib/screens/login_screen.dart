// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/screens/CommunityScreen.dart';
// import 'package:segma/screens/home_screen.dart';
// import 'package:segma/screens/doctor_home_screen.dart';
// import 'package:segma/screens/signup_screen.dart';
// import 'package:segma/services/api_service.dart';
// import 'package:segma/services/user_service.dart';
// import 'package:segma/services/child_service.dart';
// import 'package:segma/models/child_model.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/cubits/selected_child_cubit.dart';
// import 'package:segma/screens/add_child_screen.dart'; // إضافة الـ import للنسخة الصحيحة من AddChildScreen

// // شاشة جديدة لعرض رسالة "No children found" مع زر لإضافة طفل
// class NoChildrenScreen extends StatelessWidget {
//   const NoChildrenScreen({Key? key}) : super(key: key);

//   Route _createSlideRoute(Widget page) {
//     return PageRouteBuilder(
//       transitionDuration: const Duration(milliseconds: 500),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5F5F5),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Text(
//               'No children found',
//               style: TextStyle(
//                 fontFamily: 'Roboto',
//                 fontSize: 20,
//                 color: Color(0xFF0077B6),
//               ),
//             ),
//             SizedBox(height: 20.h),
//             IconButton(
//               icon: const Icon(
//                 Icons.add_circle,
//                 color: Color(0xFF00B4D8),
//                 size: 50,
//               ),
//               onPressed: () {
//                 Navigator.push(context, _createSlideRoute(const AddChildScreen()));
//               },
//             ),
//             SizedBox(height: 10.h),
//             const Text(
//               'Add a new child',
//               style: TextStyle(
//                 fontFamily: 'Roboto',
//                 fontSize: 16,
//                 color: Color(0xFF757575),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class LoginScreen extends StatefulWidget {
//   @override
//   _LoginScreenState createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   bool _isLoading = false;
//   bool _isPasswordVisible = false;
//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;
//   late Animation<Offset> _buttonSlideAnimation;

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: Duration(milliseconds: 1000),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Interval(0.0, 0.5, curve: Curves.easeIn),
//       ),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Interval(0.2, 0.7, curve: Curves.easeOutBack),
//       ),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Interval(0.3, 0.8, curve: Curves.easeOut),
//       ),
//     );

//     _buttonSlideAnimation = Tween<Offset>(
//       begin: Offset(0, 0.5),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(
//         parent: _animationController,
//         curve: Interval(0.5, 1.0, curve: Curves.easeOut),
//       ),
//     );

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     super.dispose();
//   }

//   Future<void> _login() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final result = await UserService.login(
//         _emailController.text.trim(),
//         _passwordController.text.trim(),
//         context,
//       );

//       print('📋 Login Result: $result');

//       setState(() => _isLoading = false);

//       if (result['status'] == 'success') {
//         final String? role = result['data']['role'];
//         print('🔑 Role: $role');

//         // جلب قايمة الأطفال
//         final childrenResult = await ChildService.getChildren();
//         if (childrenResult['status'] == 'success') {
//           final List<Child> children = childrenResult['data'] as List<Child>;

//           if (mounted) {
//             ScaffoldMessenger.of(context).showSnackBar(
//               SnackBar(
//                 content: Text(
//                   'Logged in successfully',
//                   style: TextStyle(color: Colors.white),
//                 ),
//                 backgroundColor: Color(0xFF00B4D8),
//                 behavior: SnackBarBehavior.floating,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 duration: Duration(seconds: 2),
//               ),
//             );

//             await Future.delayed(Duration(seconds: 2));

//             if (role == 'doctor') {
//               Navigator.pushReplacement(
//                 context,
//                 _createSlideRoute(DoctorHomeScreen()),
//               );
//             } else if (role == 'patient') {
//               if (children.isNotEmpty) {
//                 // لو فيه أطفال، اختار أول طفل وانتقل لـ HomeScreen
//                 final firstChild = children.first;
//                 context.read<SelectedChildCubit>().selectChild(firstChild.id);
//                 print('🔑 Selected First Child: ${firstChild.name} (ID: ${firstChild.id})');
//                 Navigator.pushReplacement(
//                   context,
//                   _createSlideRoute(const HomeScreen()),
//                 );
//               } else {
//                 // لو مفيش أطفال، انتقل لشاشة NoChildrenScreen
//                 Navigator.pushReplacement(
//                   context,
//                   _createSlideRoute(const NoChildrenScreen()),
//                 );
//               }
//             } else {
//               _showSnackBar('Unknown role');
//             }
//           }
//         } else {
//           _showSnackBar('Failed to load children');
//         }
//       } else {
//         _showSnackBar(result['message'] ?? 'Login failed');
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       print('🔥 Login Error: $e');
//       _showSnackBar('Connection error: $e');
//     }
//   }

//   Route _createSlideRoute(Widget page) {
//     return PageRouteBuilder(
//       transitionDuration: Duration(milliseconds: 500),
//       pageBuilder: (context, animation, secondaryAnimation) => page,
//       transitionsBuilder: (context, animation, secondaryAnimation, child) {
//         const begin = Offset(1.0, 0.0);
//         const end = Offset.zero;
//         const curve = Curves.easeInOut;
//         var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
//         var offsetAnimation = animation.drive(tween);
//         return SlideTransition(
//           position: offsetAnimation,
//           child: child,
//         );
//       },
//     );
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFFFF5252),
//         duration: Duration(seconds: 3),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         title: Text(
//           'Login',
//           style: TextStyle(color: Color(0xFF00B4D8)),
//         ),
//         backgroundColor: Colors.white,
//         centerTitle: true,
//         elevation: 0,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           physics: AlwaysScrollableScrollPhysics(),
//           padding: EdgeInsets.all(20.w),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: Image.asset(
//                       'assets/logo.png',
//                       height: 100.h,
//                       errorBuilder: (context, error, stackTrace) => Icon(
//                         Icons.broken_image,
//                         size: 100.h,
//                         color: Color(0xFF00B4D8),
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(
//                     _emailController,
//                     'Email',
//                     false,
//                   ),
//                 ),
//                 SizedBox(height: 15.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(
//                     _passwordController,
//                     'Password',
//                     true,
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 _isLoading
//                     ? Center(
//                         child: CircularProgressIndicator(
//                           color: Color(0xFF00B4D8),
//                         ),
//                       )
//                     : SlideTransition(
//                         position: _buttonSlideAnimation,
//                         child: ScaleTransition(
//                           scale: _scaleAnimation,
//                           child: ElevatedButton(
//                             onPressed: _login,
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Color(0xFF00B4D8),
//                               padding: EdgeInsets.symmetric(vertical: 15.h),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(10.r),
//                               ),
//                               elevation: 5,
//                             ),
//                             child: Text(
//                               'Login',
//                               style: TextStyle(color: Colors.white),
//                             ),
//                           ),
//                         ),
//                       ),
//                 SizedBox(height: 10.h),
//                 SlideTransition(
//                   position: _buttonSlideAnimation,
//                   child: TextButton(
//                     onPressed: () => Navigator.push(
//                       context,
//                       _createSlideRoute(SignupScreen()),
//                     ),
//                     child: Text(
//                       'Create New Account',
//                       style: TextStyle(color: Color(0xFF00B4D8)),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, bool isPassword) {
//     return AnimatedContainer(
//       duration: Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword ? !_isPasswordVisible : false,
//         style: TextStyle(color: Color(0xFF00B4D8)),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: TextStyle(color: Color(0xFF00B4D8)),
//           filled: true,
//           fillColor: Colors.white,
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(color: Color(0xFF0077B6)),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(color: Color(0xFF0077B6)),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(color: Color(0xFF00B4D8), width: 2),
//           ),
//           suffixIcon: isPassword
//               ? IconButton(
//                   icon: Icon(
//                     _isPasswordVisible
//                         ? Icons.visibility
//                         : Icons.visibility_off,
//                     color: Color(0xFF00B4D8),
//                   ),
//                   onPressed: () {
//                     setState(() {
//                       _isPasswordVisible = !_isPasswordVisible;
//                     });
//                   },
//                 )
//               : null,
//         ),
//         validator: (value) {
//           if (value == null || value.isEmpty) {
//             return '$label is required';
//           }
//           if (label == 'Email' &&
//               !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
//                   .hasMatch(value)) {
//             return 'Invalid email address';
//           }
//           if (label == 'Password' && value.length < 6) {
//             return 'Password must be at least 6 characters';
//           }
//           return null;
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/screens/community_user/CommunityScreen.dart';
import 'package:segma/screens/users/home_screen.dart';
import 'package:segma/screens/doctor/doctor_home_screen.dart';
import 'package:segma/screens/signup_screen.dart';
import 'package:segma/services/api_service.dart';
import 'package:segma/services/user_service.dart';
import 'package:segma/services/child_service.dart';
import 'package:segma/models/child_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/screens/childs/add_child_screen.dart';

// شاشة جديدة لعرض رسالة "No children found" مع زر لإضافة طفل
class NoChildrenScreen extends StatelessWidget {
  const NoChildrenScreen({Key? key}) : super(key: key);

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
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No children found',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 20,
                color: Color(0xFF0077B6),
              ),
            ),
            SizedBox(height: 20.h),
            IconButton(
              icon: const Icon(
                Icons.add_circle,
                color: Color(0xFF00B4D8),
                size: 50,
              ),
              onPressed: () {
                Navigator.push(context, _createSlideRoute(const AddChildScreen()));
              },
            ),
            SizedBox(height: 10.h),
            const Text(
              'Add a new child',
              style: TextStyle(
                fontFamily: 'Roboto',
                fontSize: 16,
                color: Color(0xFF757575),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _buttonSlideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.2, 0.7, curve: Curves.easeOutBack),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.3, 0.8, curve: Curves.easeOut),
      ),
    );

    _buttonSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final result = await UserService.login(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        context,
      );

      print('📋 Login Result: $result');

      setState(() => _isLoading = false);

      if (result['status'] == 'success') {
        final String? role = result['data']['role'];
        print('🔑 Role: $role');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Logged in successfully',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Color(0xFF00B4D8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.r),
              ),
              duration: Duration(seconds: 2),
            ),
          );

          await Future.delayed(Duration(seconds: 2));

          if (role == 'doctor') {
            // إذا كان الدور doctor، انتقل مباشرة إلى DoctorHomeScreen دون جلب الأطفال
            Navigator.pushReplacement(
              context,
              _createSlideRoute(const DoctorHomeScreen()),
            );
          } else if (role == 'patient') {
            // جلب قائمة الأطفال فقط إذا كان الدور patient
            final childrenResult = await ChildService.getChildren();
            if (childrenResult['status'] == 'success') {
              final List<Child> children = childrenResult['data'] as List<Child>;

              if (children.isNotEmpty) {
                // لو فيه أطفال، اختار أول طفل وانتقل لـ HomeScreen
                final firstChild = children.first;
                context.read<SelectedChildCubit>().selectChild(firstChild.id);
                print('🔑 Selected First Child: ${firstChild.name} (ID: ${firstChild.id})');
                Navigator.pushReplacement(
                  context,
                  _createSlideRoute(const HomeScreen()),
                );
              } else {
                // لو مفيش أطفال، انتقل لشاشة NoChildrenScreen
                Navigator.pushReplacement(
                  context,
                  _createSlideRoute(const NoChildrenScreen()),
                );
              }
            } else {
              _showSnackBar('Failed to load children');
            }
          } else {
            _showSnackBar('Unknown role');
          }
        }
      } else {
        _showSnackBar(result['message'] ?? 'Login failed');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('🔥 Login Error: $e');
      _showSnackBar('Connection error: $e');
    }
  }

  Route _createSlideRoute(Widget page) {
    return PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 500),
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

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFFF5252),
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.r),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Login',
          style: TextStyle(color: Color(0xFF00B4D8)),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Image.asset(
                      'assets/logo.png',
                      height: 100.h,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.broken_image,
                        size: 100.h,
                        color: Color(0xFF00B4D8),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(
                    _emailController,
                    'Email',
                    false,
                  ),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(
                    _passwordController,
                    'Password',
                    true,
                  ),
                ),
                SizedBox(height: 20.h),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF00B4D8),
                        ),
                      )
                    : SlideTransition(
                        position: _buttonSlideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF00B4D8),
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              elevation: 5,
                            ),
                            child: Text(
                              'Login',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                SizedBox(height: 10.h),
                SlideTransition(
                  position: _buttonSlideAnimation,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      _createSlideRoute(SignupScreen()),
                    ),
                    child: Text(
                      'Create New Account',
                      style: TextStyle(color: Color(0xFF00B4D8)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, bool isPassword) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        style: TextStyle(color: Color(0xFF00B4D8)),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Color(0xFF00B4D8)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: Color(0xFF0077B6)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: Color(0xFF0077B6)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(color: Color(0xFF00B4D8), width: 2),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Color(0xFF00B4D8),
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                )
              : null,
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return '$label is required';
          }
          if (label == 'Email' &&
              !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                  .hasMatch(value)) {
            return 'Invalid email address';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }
}