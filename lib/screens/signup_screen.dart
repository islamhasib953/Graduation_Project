// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:segma/screens/childs/add_child_screen.dart';
// import 'package:segma/screens/doctor/doctor_home_screen.dart';
// import 'package:segma/screens/users/home_screen.dart';
// import 'package:segma/services/user_service.dart';
// import 'package:segma/utils/colors.dart';

// class SignupScreen extends StatefulWidget {
//   const SignupScreen({super.key});

//   @override
//   _SignupScreenState createState() => _SignupScreenState();
// }

// class _SignupScreenState extends State<SignupScreen>
//     with SingleTickerProviderStateMixin {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _firstNameController = TextEditingController();
//   final TextEditingController _lastNameController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();
//   final TextEditingController _specializationController =
//       TextEditingController();
//   final TextEditingController _aboutController = TextEditingController();

//   String? _selectedGender;
//   String? _selectedAccountType;
//   bool _isLoading = false;
//   bool _isPasswordVisible = false;

//   late AnimationController _animationController;
//   late Animation<double> _fadeAnimation;
//   late Animation<double> _scaleAnimation;
//   late Animation<Offset> _slideAnimation;

//   final List<String> _genders = ['Male', 'Female'];

//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       duration: const Duration(milliseconds: 800),
//       vsync: this,
//     );

//     _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
//     );

//     _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
//     );

//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.3),
//       end: Offset.zero,
//     ).animate(
//       CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
//     );

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _showAccountTypeDialog();
//     });

//     _animationController.forward();
//   }

//   @override
//   void dispose() {
//     _animationController.dispose();
//     _firstNameController.dispose();
//     _lastNameController.dispose();
//     _phoneController.dispose();
//     _addressController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _specializationController.dispose();
//     _aboutController.dispose();
//     super.dispose();
//   }

//   void _showAccountTypeDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) => ScaleTransition(
//         scale: Tween<double>(begin: 0.8, end: 1.0).animate(
//           CurvedAnimation(
//             parent: _animationController,
//             curve: Curves.easeOut,
//           ),
//         ),
//         child: AlertDialog(
//           title: Text(
//             'Are you a Doctor or a Patient?',
//             style: Theme.of(context).textTheme.titleLarge,
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedAccountType = 'Patient';
//                     print('🔍 Selected Account Type: $_selectedAccountType');
//                   });
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Patient'),
//               ),
//               SizedBox(height: 10.h),
//               ElevatedButton(
//                 onPressed: () {
//                   setState(() {
//                     _selectedAccountType = 'Doctor';
//                     print('🔍 Selected Account Type: $_selectedAccountType');
//                   });
//                   Navigator.pop(context);
//                 },
//                 child: const Text('Doctor'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Future<void> _handleSignup() async {
//     if (_formKey.currentState!.validate()) {
//       setState(() => _isLoading = true);

//       try {
//         Map<String, dynamic> result = await UserService.register(
//           firstName: _firstNameController.text,
//           lastName: _lastNameController.text,
//           phone: _phoneController.text,
//           email: _emailController.text,
//           password: _passwordController.text,
//           accountType: _selectedAccountType?.toLowerCase() ?? 'patient',
//           gender: _selectedGender ?? 'Male',
//           address: _addressController.text,
//           specialise: _selectedAccountType == 'Doctor' ? _specializationController.text : null,
//           about: _selectedAccountType == 'Doctor' ? _aboutController.text : null,
//           context: context,
//         );

//         print('📋 Register Result: $result');

//         setState(() => _isLoading = false);

//         if (result['status'] == 'success') {
//           print('🎉 Signup successful');

//           if (_selectedAccountType?.toLowerCase() == 'doctor') {
//             print('➡️ Navigating to HomeDoctor');
//             Navigator.pushReplacement(
//               context,
//               MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
//             );
//           } else {
//             print('➡️ Navigating to AddChildScreen');
//             // استخدام push بدلاً من pushReplacement وانتظار النتيجة
//             final result = await Navigator.push(
//               context,
//               MaterialPageRoute(builder: (context) => const AddChildScreen()),
//             );

//             // التحقق من نتيجة AddChildScreen
//             if (result == true) {
//               print('➡️ Child added successfully, navigating to HomeScreen');
//               Navigator.pushReplacement(
//                 context,
//                 MaterialPageRoute(builder: (context) => const HomeScreen()),
//               );
//             } else {
//               print('❌ Child addition cancelled or failed');
//               // يمكنك إضافة رسالة أو التعامل مع الحالة حسب الحاجة
//               _showSnackBar('Child addition was cancelled or failed.');
//             }
//           }
//         } else {
//           print('❌ Signup failed: ${result['message']}');
//           _showSnackBar(result['message'] ?? 'فشل التسجيل، حاول مرة تانية.');
//         }
//       } catch (e) {
//         setState(() => _isLoading = false);
//         print('🔥 Signup error: $e');
//         _showSnackBar('خطأ: $e');
//       }
//     }
//   }

//   void _showSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message),
//         duration: const Duration(seconds: 3),
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
//       appBar: AppBar(
//         title: Text(
//           'Sign Up',
//           style: Theme.of(context).textTheme.titleLarge!.copyWith(
//                 color: Theme.of(context).brightness == Brightness.light
//                     ? AppColors.lightButtonPrimary
//                     : AppColors.darkButtonPrimary,
//               ),
//         ),
//         centerTitle: true,
//       ),
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.all(20.w),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 FadeTransition(
//                   opacity: _fadeAnimation,
//                   child: ScaleTransition(
//                     scale: _scaleAnimation,
//                     child: Container(
//                       height: 100.h,
//                       child: Image.asset(
//                         'assets/logo.png',
//                         height: 100.h,
//                         errorBuilder: (context, error, stackTrace) {
//                           print('🖼️ Asset load error: $error');
//                           return Icon(
//                             Icons.broken_image,
//                             size: 100.h,
//                             color: Theme.of(context).brightness == Brightness.light
//                                 ? AppColors.lightButtonPrimary
//                                 : AppColors.darkButtonPrimary,
//                           );
//                         },
//                       ),
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(_firstNameController, 'First Name', false),
//                 ),
//                 SizedBox(height: 15.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(_lastNameController, 'Last Name', false),
//                 ),
//                 SizedBox(height: 15.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildDropdown('Gender', _genders, _selectedGender, (value) {
//                     setState(() => _selectedGender = value);
//                   }),
//                 ),
//                 SizedBox(height: 15.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(_addressController, 'Address', false),
//                 ),
//                 SizedBox(height: 15.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(_phoneController, 'Phone', false, isNumber: true),
//                 ),
//                 SizedBox(height: 15.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(_emailController, 'Email', false),
//                 ),
//                 SizedBox(height: 15.h),
//                 SlideTransition(
//                   position: _slideAnimation,
//                   child: _buildTextField(_passwordController, 'Password', true),
//                 ),
//                 SizedBox(height: 15.h),
//                 if (_selectedAccountType == 'Doctor') ...[
//                   SlideTransition(
//                     position: _slideAnimation,
//                     child: _buildTextField(_specializationController, 'Specialization', false),
//                   ),
//                   SizedBox(height: 15.h),
//                   SlideTransition(
//                     position: _slideAnimation,
//                     child: _buildTextField(_aboutController, 'About', false),
//                   ),
//                   SizedBox(height: 15.h),
//                 ],
//                 SizedBox(height: 20.h),
//                 _isLoading
//                     ? Center(
//                         child: CircularProgressIndicator(
//                           color: Theme.of(context).brightness == Brightness.light
//                               ? AppColors.lightButtonPrimary
//                               : AppColors.darkButtonPrimary,
//                         ),
//                       )
//                     : SlideTransition(
//                         position: _slideAnimation,
//                         child: ScaleTransition(
//                           scale: _scaleAnimation,
//                           child: ElevatedButton(
//                             onPressed: _handleSignup,
//                             style: ElevatedButton.styleFrom(
//                               padding: EdgeInsets.symmetric(vertical: 15.h),
//                               elevation: 5,
//                             ),
//                             child: const Text('Sign Up'),
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField(
//       TextEditingController controller, String label, bool isPassword,
//       {bool isNumber = false}) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: TextFormField(
//         controller: controller,
//         obscureText: isPassword ? !_isPasswordVisible : false,
//         keyboardType: isNumber ? TextInputType.number : TextInputType.text,
//         style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//               color: Theme.of(context).brightness == Brightness.light
//                   ? AppColors.lightButtonPrimary
//                   : AppColors.darkButtonPrimary,
//             ),
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                 color: Theme.of(context).brightness == Brightness.light
//                     ? AppColors.lightButtonPrimary
//                     : AppColors.darkButtonPrimary,
//               ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(
//               color: Theme.of(context).brightness == Brightness.light
//                   ? AppColors.lightTextSecondary
//                   : AppColors.darkTextSecondary,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(
//               color: Theme.of(context).brightness == Brightness.light
//                   ? AppColors.lightTextSecondary
//                   : AppColors.darkTextSecondary,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(
//               color: Theme.of(context).brightness == Brightness.light
//                   ? AppColors.lightButtonPrimary
//                   : AppColors.darkButtonPrimary,
//               width: 2,
//             ),
//           ),
//           suffixIcon: isPassword
//               ? IconButton(
//                   icon: Icon(
//                     _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
//                     color: Theme.of(context).brightness == Brightness.light
//                         ? AppColors.lightButtonPrimary
//                         : AppColors.darkButtonPrimary,
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
//           if (label == 'Phone' &&
//               !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
//             return 'Invalid phone number (must be 10-15 digits)';
//           }
//           if (label == 'Password' && value.length < 6) {
//             return 'Password must be at least 6 characters';
//           }
//           if (label == 'Specialization' && value.length < 3) {
//             return 'Specialization must be at least 3 characters';
//           }
//           if (label == 'About' && value.length < 10) {
//             return 'About must be at least 10 characters';
//           }
//           if (label == 'Address' && value.length < 5) {
//             return 'Address must be at least 5 characters';
//           }
//           return null;
//         },
//       ),
//     );
//   }

//   Widget _buildDropdown(String label, List<String> items, String? selectedValue,
//       Function(String?) onChanged) {
//     return AnimatedContainer(
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeInOut,
//       child: DropdownButtonFormField<String>(
//         value: selectedValue,
//         decoration: InputDecoration(
//           labelText: label,
//           labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
//                 color: Theme.of(context).brightness == Brightness.light
//                     ? AppColors.lightButtonPrimary
//                     : AppColors.darkButtonPrimary,
//               ),
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(
//               color: Theme.of(context).brightness == Brightness.light
//                   ? AppColors.lightTextSecondary
//                   : AppColors.darkTextSecondary,
//             ),
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(
//               color: Theme.of(context).brightness == Brightness.light
//                   ? AppColors.lightTextSecondary
//                   : AppColors.darkTextSecondary,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(15.r),
//             borderSide: BorderSide(
//               color: Theme.of(context).brightness == Brightness.light
//                   ? AppColors.lightButtonPrimary
//                   : AppColors.darkButtonPrimary,
//               width: 2,
//             ),
//           ),
//         ),
//         items: items.map((String value) {
//           return DropdownMenuItem<String>(
//             value: value,
//             child: Text(
//               value,
//               style: Theme.of(context).textTheme.bodyLarge!.copyWith(
//                     color: Theme.of(context).brightness == Brightness.light
//                         ? AppColors.lightButtonPrimary
//                         : AppColors.darkButtonPrimary,
//                   ),
//             ),
//           );
//         }).toList(),
//         onChanged: onChanged,
//         validator: (value) => value == null ? '$label is required' : null,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/screens/childs/add_child_screen.dart';
import 'package:segma/screens/doctor/doctor_home_screen.dart';
import 'package:segma/screens/users/home_screen.dart';
import 'package:segma/services/user_service.dart';
import 'package:segma/utils/colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _specializationController =
      TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  String? _selectedGender;
  String? _selectedRole;
  bool _isLoading = false;
  bool _isPasswordVisible = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _genders = ['Male', 'Female'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRoleDialog();
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _specializationController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  void _showRoleDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        ),
        child: AlertDialog(
          title: Text(
            'Are you a Doctor or a Patient?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'Patient';
                    print('🔍 Selected Role: $_selectedRole');
                  });
                  Navigator.pop(context);
                },
                child: const Text('Patient'),
              ),
              SizedBox(height: 10.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedRole = 'Doctor';
                    print('🔍 Selected Role: $_selectedRole');
                  });
                  Navigator.pop(context);
                },
                child: const Text('Doctor'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        Map<String, dynamic> result = await UserService.register(
          firstName: _firstNameController.text,
          lastName: _lastNameController.text,
          phone: _phoneController.text,
          email: _emailController.text,
          password: _passwordController.text,
          role: _selectedRole?.toLowerCase() ?? 'patient',
          gender: _selectedGender ?? 'Male',
          address: _addressController.text,
          specialise: _selectedRole == 'Doctor' ? _specializationController.text : null,
          about: _selectedRole == 'Doctor' ? _aboutController.text : null,
          context: context,
        );

        print('📋 Register Result: $result');

        setState(() => _isLoading = false);

        if (result['status'] == 'success') {
          print('🎉 Signup successful');

          if (_selectedRole?.toLowerCase() == 'doctor') {
            print('➡️ Navigating to HomeDoctor');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
            );
          } else {
            print('➡️ Navigating to AddChildScreen');
            // استخدام push بدلاً من pushReplacement وانتظار النتيجة
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddChildScreen()),
            );

            // التحقق من نتيجة AddChildScreen
            if (result == true) {
              print('➡️ Child added successfully, navigating to HomeScreen');
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            } else {
              print('❌ Child addition cancelled or failed');
              _showSnackBar('Child addition was cancelled or failed.');
            }
          }
        } else {
          print('❌ Signup failed: ${result['message']}');
          _showSnackBar(result['message'] ?? 'فشل التسجيل، حاول مرة تانية.');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        print('🔥 Signup error: $e');
        _showSnackBar('خطأ: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
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
      appBar: AppBar(
        title: Text(
          'Sign Up',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
              ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FadeTransition(
                  opacity: _fadeAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      height: 100.h,
                      child: Image.asset(
                        'assets/logo.png',
                        height: 100.h,
                        errorBuilder: (context, error, stackTrace) {
                          print('🖼️ Asset load error: $error');
                          return Icon(
                            Icons.broken_image,
                            size: 100.h,
                            color: Theme.of(context).brightness == Brightness.light
                                ? AppColors.lightButtonPrimary
                                : AppColors.darkButtonPrimary,
                          );
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(_firstNameController, 'First Name', false),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(_lastNameController, 'Last Name', false),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildDropdown('Gender', _genders, _selectedGender, (value) {
                    setState(() => _selectedGender = value);
                  }),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(_addressController, 'Address', false),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(_phoneController, 'Phone', false, isNumber: true),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(_emailController, 'Email', false),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: _buildTextField(_passwordController, 'Password', true),
                ),
                SizedBox(height: 15.h),
                if (_selectedRole == 'Doctor') ...[
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildTextField(_specializationController, 'Specialization', false),
                  ),
                  SizedBox(height: 15.h),
                  SlideTransition(
                    position: _slideAnimation,
                    child: _buildTextField(_aboutController, 'About', false),
                  ),
                  SizedBox(height: 15.h),
                ],
                SizedBox(height: 20.h),
                _isLoading
                    ? Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).brightness == Brightness.light
                              ? AppColors.lightButtonPrimary
                              : AppColors.darkButtonPrimary,
                        ),
                      )
                    : SlideTransition(
                        position: _slideAnimation,
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: ElevatedButton(
                            onPressed: _handleSignup,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 15.h),
                              elevation: 5,
                            ),
                            child: const Text('Sign Up'),
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
      TextEditingController controller, String label, bool isPassword,
      {bool isNumber = false}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: TextFormField(
        controller: controller,
        obscureText: isPassword ? !_isPasswordVisible : false,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightButtonPrimary
                  : AppColors.darkButtonPrimary,
            ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightButtonPrimary
                  : AppColors.darkButtonPrimary,
              width: 2,
            ),
          ),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightButtonPrimary
                        : AppColors.darkButtonPrimary,
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
          if (label == 'Phone' &&
              !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
            return 'Invalid phone number (must be 10-15 digits)';
          }
          if (label == 'Password' && value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          if (label == 'Specialization' && value.length < 3) {
            return 'Specialization must be at least 3 characters';
          }
          if (label == 'About' && value.length < 10) {
            return 'About must be at least 10 characters';
          }
          if (label == 'Address' && value.length < 5) {
            return 'Address must be at least 5 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? selectedValue,
      Function(String?) onChanged) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: DropdownButtonFormField<String>(
        value: selectedValue,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Theme.of(context).brightness == Brightness.light
                    ? AppColors.lightButtonPrimary
                    : AppColors.darkButtonPrimary,
              ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightTextSecondary
                  : AppColors.darkTextSecondary,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.r),
            borderSide: BorderSide(
              color: Theme.of(context).brightness == Brightness.light
                  ? AppColors.lightButtonPrimary
                  : AppColors.darkButtonPrimary,
              width: 2,
            ),
          ),
        ),
        items: items.map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context).brightness == Brightness.light
                        ? AppColors.lightButtonPrimary
                        : AppColors.darkButtonPrimary,
                  ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
        validator: (value) => value == null ? '$label is required' : null,
      ),
    );
  }
}