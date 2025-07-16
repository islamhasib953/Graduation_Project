import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segma/screens/childs/add_child_screen.dart';
import 'package:segma/screens/doctor/doctor_home_screen.dart';
import 'package:segma/screens/users/home_screen.dart';
import 'package:segma/services/auth_service.dart';
import 'package:segma/services/user_service.dart';
import 'package:segma/utils/colors.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:universal_html/html.dart' as html;
import 'package:universal_io/io.dart' as io;
import 'package:shared_preferences/shared_preferences.dart'; // إضافة هذا لـ SharedPreferences

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
  final TextEditingController _specializationController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();

  String? _selectedGender;
  String? _selectedRole;
  bool _isLoading = false;
  bool _isPasswordVisible = false;
  dynamic _selectedImage; // يمكن أن يكون File أو Uint8List

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _genders = ['Male', 'Female'];
  final ImagePicker _picker = ImagePicker();

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
            'Are you a Doctor or a Parent?',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          content: Row(
  mainAxisSize: MainAxisSize.min,
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedRole = 'Patient';
          print('🔍 Selected Role: $_selectedRole');
        });
        Navigator.pop(context);
      },
      child: const Text('Parent'),
    ),
    SizedBox(width: 10.w),
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

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      if (io.Platform.isAndroid || io.Platform.isIOS) {
        setState(() {
          _selectedImage = io.File(pickedFile.path);
        });
      } else if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = bytes;
        });
      }
    }
  }

  Future<void> _showImageSourceDialog() {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        actions: [
          TextButton(
            onPressed: () {
              _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            },
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () {
              _pickImage(ImageSource.camera);
              Navigator.pop(context);
            },
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        var request = http.MultipartRequest(
          'POST',
          Uri.parse('${AuthService.baseUrl}/users/register'),
        );
        request.headers.addAll(await AuthService.getHeaders());
        request.fields['firstName'] = _firstNameController.text;
        request.fields['lastName'] = _lastNameController.text;
        request.fields['phone'] = _phoneController.text;
        request.fields['email'] = _emailController.text;
        request.fields['password'] = _passwordController.text;
        request.fields['role'] = _selectedRole?.toLowerCase() ?? 'Parent';
        request.fields['gender'] = _selectedGender ?? 'Male';
        request.fields['address'] = _addressController.text;
        if (_selectedRole == 'Doctor') {
          request.fields['specialise'] = _specializationController.text;
          request.fields['about'] = _aboutController.text;
        }
        if (_selectedImage != null) {
          if (_selectedImage is io.File) {
            request.files.add(await http.MultipartFile.fromPath(
              'avatar',
              _selectedImage.path,
            ));
          } else if (_selectedImage is Uint8List) {
            request.files.add(http.MultipartFile.fromBytes(
              'avatar',
              _selectedImage,
              filename: 'avatar.png',
            ));
          }
        }

        final response = await request.send();
        final respStr = await response.stream.bytesToString();
        final result = jsonDecode(respStr);

        print('📋 Register Result: $result');

        setState(() => _isLoading = false);

        if (result['status'] == 'success') {
          print('🎉 Signup successful');

          // حفظ الـ token و User ID في SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          prefs.setString('token', result['data']['user']['token']);
          prefs.setString('userId', result['data']['user']['_id']);

          String? fcmToken = await FirebaseMessaging.instance.getToken();
          if (fcmToken != null) {
            await AuthService.saveFcmToken(fcmToken, _selectedRole);
          }

          if (_selectedRole?.toLowerCase() == 'doctor') {
            print('➡️ Navigating to HomeDoctor');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const DoctorHomeScreen()),
            );
          } else {
            print('➡️ Navigating to AddChildScreen');
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddChildScreen()),
            );

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

  void _showFullImage() {
    if (_selectedImage != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: Container(
            padding: EdgeInsets.all(10.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                (io.Platform.isAndroid || io.Platform.isIOS
                    ? Image.file(
                        _selectedImage as io.File,
                        fit: BoxFit.contain,
                      )
                    : Image.memory(
                        _selectedImage as Uint8List,
                        fit: BoxFit.contain,
                      )),
                SizedBox(height: 10.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    }
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
                    child: SizedBox(
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
                  child: GestureDetector(
                    onTap: _showImageSourceDialog,
                    child: CircleAvatar(
                      radius: 50.r,
                      backgroundColor: Colors.grey[200],
                      child: _selectedImage != null
                          ? ClipOval(
                              child: (io.Platform.isAndroid || io.Platform.isIOS
                                  ? Image.file(
                                      _selectedImage as io.File,
                                      fit: BoxFit.cover,
                                      width: 100.w,
                                      height: 100.h,
                                    )
                                  : Image.memory(
                                      _selectedImage as Uint8List,
                                      fit: BoxFit.cover,
                                      width: 100.w,
                                      height: 100.h,
                                    )),
                            )
                          : Icon(Icons.camera_alt, size: 50.h, color: Colors.grey),
                    ),
                  ),
                ),
                SizedBox(height: 15.h),
                SlideTransition(
                  position: _slideAnimation,
                  child: GestureDetector(
                    onTap: _selectedImage != null ? _showFullImage : null,
                    child: _buildTextField(_firstNameController, 'First Name', false),
                  ),
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
              !RegExp(r'^\+?01[0125][0-9]{8}$').hasMatch(value)) { // تحقق من رقم مصري صحيح
            return 'Invalid Egyptian phone number (e.g., 01012345678)';
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
