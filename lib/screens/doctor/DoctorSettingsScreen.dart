import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/services/user_service.dart';
import 'package:segma/screens/login_screen.dart';
import 'package:segma/utils/colors.dart';
import 'package:segma/utils/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _role;

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role')?.toLowerCase();
      print('SettingsScreen: Loaded role: $_role');
    });
    // Update the ThemeProvider with the role
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    await themeProvider.updateRole(_role);
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final TextEditingController deleteController = TextEditingController();
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    bool _isDialogDeletePressed = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Confirm Account Deletion',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Type "DELETE" to confirm',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: deleteController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      hintText: 'Type DELETE',
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                      filled: true,
                      fillColor: Theme.of(context).dividerColor,
                    ),
                    style: Theme.of(context).textTheme.bodyLarge,
                    onChanged: (value) {
                      setDialogState(() {});
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: Text('Cancel'),
                ),
                GestureDetector(
                  onTapDown: (_) => setDialogState(() => _isDialogDeletePressed = true),
                  onTapUp: (_) {
                    setDialogState(() => _isDialogDeletePressed = false);
                    if (deleteController.text.toUpperCase() == 'DELETE') {
                      _deleteAccount(context, scaffoldMessenger);
                    }
                  },
                  onTapCancel: () => setDialogState(() => _isDialogDeletePressed = false),
                  child: AnimatedScale(
                    scale: _isDialogDeletePressed ? 0.95 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      onPressed: deleteController.text.toUpperCase() == 'DELETE'
                          ? () => _deleteAccount(context, scaffoldMessenger)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusOverdue,
                      ),
                      child: Text('Delete'),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(BuildContext context, ScaffoldMessengerState scaffoldMessenger) async {
    try {
      Map<String, dynamic> response;
      print('SettingsScreen: Attempting to delete account for role: $_role');
      if (_role == 'doctor') {
        response = await DoctorService.deleteDoctorAccount();
      } else {
        response = await UserService.deleteUserAccount();
      }
      print('SettingsScreen: Delete account response: $response');
      if (response['status'] == 'success') {
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => LoginScreen()),
            (route) => false,
          );
          scaffoldMessenger.showSnackBar(
            SnackBar(
              content: Text('Account deleted successfully'),
              backgroundColor: AppColors.statusUpcoming,
            ),
          );
        }
      } else {
        throw Exception(response['message'] ?? 'Unknown error');
      }
    } catch (e) {
      print('SettingsScreen: Error deleting account: $e');
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
    }
  }

  Future<void> _logout(BuildContext context) async {
    try {
      Map<String, dynamic> response;
      print('SettingsScreen: Attempting to logout for role: $_role');
      if (_role == 'doctor') {
        response = await DoctorService.logoutDoctor();
      } else {
        response = await UserService.logoutUser();
      }
      print('SettingsScreen: Logout response: $response');
      if (response['status'] == 'success' && context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logged out successfully'),
            backgroundColor: AppColors.statusUpcoming,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Logout failed');
      }
    } catch (e) {
      print('SettingsScreen: Error logging out: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Settings',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Icon(
                    Icons.settings,
                    size: 24.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              _buildSectionTitle('Profile', context),
              _buildSettingsItem(
                context,
                icon: Icons.person,
                title: 'My Profile',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const ProfileScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              _buildSectionTitle('Appearance', context),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    children: [
                      _buildRadioTile(
                        context,
                        title: 'Light Mode',
                        value: ThemeMode.light,
                        groupValue: themeProvider.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            print('SettingsScreen: Switching to Light Mode');
                            themeProvider.toggleTheme(false);
                          }
                        },
                      ),
                      _buildRadioTile(
                        context,
                        title: 'Dark Mode',
                        value: ThemeMode.dark,
                        groupValue: themeProvider.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            print('SettingsScreen: Switching to Dark Mode');
                            themeProvider.toggleTheme(true);
                          }
                        },
                      ),
                      _buildRadioTile(
                        context,
                        title: 'System Default',
                        value: ThemeMode.system,
                        groupValue: themeProvider.themeMode,
                        onChanged: (ThemeMode? value) {
                          if (value != null) {
                            print('SettingsScreen: Switching to System Default');
                            themeProvider.setSystemTheme();
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height: 24.h),
              _buildSectionTitle('Support', context),
              _buildSettingsItem(
                context,
                icon: Icons.help,
                title: 'Help',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const HelpScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                context,
                icon: Icons.info,
                title: 'About Us',
                onTap: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) => const AboutUsScreen(),
                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(1.0, 0.0),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        );
                      },
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              _buildSectionTitle('Account', context),
              _buildSettingsItem(
                context,
                icon: Icons.delete,
                title: 'Delete Account',
                titleColor: AppColors.statusOverdue,
                onTap: () => _showDeleteAccountDialog(context),
              ),
              _buildSettingsItem(
                context,
                icon: Icons.logout,
                title: 'Log Out',
                titleColor: AppColors.statusOverdue,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildSettingsItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    Color? titleColor,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    bool isPressed = false;
    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) {
            setState(() => isPressed = false);
            onTap();
          },
          onTapCancel: () => setState(() => isPressed = false),
          child: AnimatedScale(
            scale: isPressed ? 0.95 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.1),
                    blurRadius: 4.r,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: titleColor ?? Theme.of(context).iconTheme.color,
                    size: 24.sp,
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: titleColor ?? Theme.of(context).textTheme.bodyLarge?.color,
                            fontSize: 16.sp,
                          ),
                    ),
                  ),
                  trailing ??
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        size: 16.sp,
                      ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRadioTile<T>(
    BuildContext context, {
    required String title,
    required T value,
    required T groupValue,
    required void Function(T?) onChanged,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOut,
      child: RadioListTile<T>(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16.sp),
        ),
        value: value,
        groupValue: groupValue,
        onChanged: onChanged,
        activeColor: Theme.of(context).primaryColor,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      ),
    );
  }
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _genderController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _specialiseController;
  late TextEditingController _aboutController;
  String? _avatarUrl;
  bool _isLoading = false;
  bool _isButtonPressed = false;
  String? _role;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _genderController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _specialiseController = TextEditingController();
    _aboutController = TextEditingController();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _role = prefs.getString('role')?.toLowerCase();
      print('ProfileScreen: Loaded role: $_role');
      _profileFuture = _role == 'doctor'
          ? DoctorService.getDoctorProfile()
          : UserService.getUserProfile();
    });
    await _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final response = await _profileFuture;
      print('ProfileScreen: Load profile response: $response');
      if (response['status'] == 'success' && response['data'] != null) {
        final profileData = response['data'];
        setState(() {
          _firstNameController.text = profileData['firstName'] ?? '';
          _lastNameController.text = profileData['lastName'] ?? '';
          _genderController.text = profileData['gender'] ?? '';
          _phoneController.text = profileData['phone'] ?? '';
          _emailController.text = profileData['email'] ?? '';
          _addressController.text = profileData['address'] ?? '';
          _avatarUrl = profileData['avatar'] ?? 'https://example.com/avatar.jpg';
          if (_role == 'doctor') {
            _specialiseController.text = profileData['specialise'] ?? '';
            _aboutController.text = profileData['about'] ?? '';
          }
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load profile');
      }
    } catch (e) {
      print('ProfileScreen: Error loading profile: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading profile: $e'),
          backgroundColor: AppColors.statusOverdue,
        ),
      );
    }
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        Map<String, dynamic> response;
        final data = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'gender': _genderController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
        };
        print('ProfileScreen: Updating profile for role: $_role');
        print('ProfileScreen: Update profile data: $data');
        if (_role == 'doctor') {
          data['specialise'] = _specialiseController.text;
          data['about'] = _aboutController.text;
          response = await DoctorService.updateDoctorProfile(data);
        } else {
          response = await UserService.updateUserProfile(data);
        }
        print('ProfileScreen: Update profile response: $response');
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.statusUpcoming,
            ),
          );
          setState(() {
            _profileFuture = _role == 'doctor'
                ? DoctorService.getDoctorProfile()
                : UserService.getUserProfile();
          });
          await _loadProfile();
        } else {
          throw Exception('Error: ${response['message']}');
        }
      } catch (e) {
        print('ProfileScreen: Error updating profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.statusOverdue,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _genderController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _specialiseController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!['status'] != 'success' || snapshot.data!['data'] == null) {
              return Center(
                child: Text(
                  'Failed to load profile',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundImage: _avatarUrl != null ? NetworkImage(_avatarUrl!) : null,
                        onBackgroundImageError: (error, stackTrace) {
                          print('ProfileScreen: Error loading avatar: $error');
                        },
                        child: _avatarUrl == null
                            ? Icon(
                                Icons.person,
                                size: 50.r,
                              )
                            : null,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _firstNameController,
                        label: 'First Name',
                        icon: Icons.person,
                        context: context,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _lastNameController,
                        label: 'Last Name',
                        icon: Icons.person,
                        context: context,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _genderController,
                        label: 'Gender',
                        icon: Icons.person,
                        context: context,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Phone Number',
                        icon: Icons.phone,
                        isPhone: true,
                        context: context,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email',
                        icon: Icons.email,
                        readOnly: true,
                        context: context,
                      ),
                      SizedBox(height: 16.h),
                      _buildTextField(
                        controller: _addressController,
                        label: 'Address',
                        icon: Icons.location_on,
                        context: context,
                      ),
                      if (_role == 'doctor') ...[
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _specialiseController,
                          label: 'Specialization',
                          icon: Icons.medical_services,
                          context: context,
                        ),
                        SizedBox(height: 16.h),
                        _buildTextField(
                          controller: _aboutController,
                          label: 'About Me',
                          icon: Icons.info,
                          maxLines: 3,
                          context: context,
                        ),
                      ],
                      SizedBox(height: 24.h),
                      _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).primaryColor,
                              ),
                            )
                          : GestureDetector(
                              onTapDown: (_) => setState(() => _isButtonPressed = true),
                              onTapUp: (_) {
                                setState(() => _isButtonPressed = false);
                                _updateProfile();
                              },
                              onTapCancel: () => setState(() => _isButtonPressed = false),
                              child: AnimatedScale(
                                scale: _isButtonPressed ? 0.95 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Update Profile',
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                ),
                              ),
                            ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPhone = false,
    bool readOnly = false,
    int maxLines = 1,
    required BuildContext context,
  }) {
    return TextFormField(
      controller: controller,
      style: Theme.of(context).textTheme.bodyLarge,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      readOnly: readOnly,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Theme.of(context).dividerColor),
        ),
        filled: true,
        fillColor: Theme.of(context).dividerColor,
      ),
      validator: (value) {
        if (readOnly) return null;
        if (value == null || value.isEmpty) {
          return 'This field is required';
        }
        if (isPhone && !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
          return 'Invalid phone number';
        }
        return null;
      },
    );
  }
}

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Us',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(
            'Our mission is to provide high-quality healthcare services through a seamless digital platform. '
            'We connect patients with certified doctors to ensure reliable and accessible medical care.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.justify,
          ),
        ),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Help',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Frequently Asked Questions',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 8.h),
              Text(
                'For assistance, contact our support team at support@segma.com or call +123-456-7890.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}