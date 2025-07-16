import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/services/user_service.dart';
import 'package:segma/utils/colors.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

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
  String? _avatarUrl; // الصورة من الخادم
  String? _newAvatar; // الصورة المختارة مؤقتًا
  bool _isLoading = false;
  bool _isButtonPressed = false;
  String? _role;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    print('ProfileScreen: Initializing state');
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _genderController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _addressController = TextEditingController();
    _specialiseController = TextEditingController();
    _aboutController = TextEditingController();
    _loadRoleAndProfile();
  }

  Future<void> _loadRoleAndProfile() async {
    print('ProfileScreen: Loading role and profile');
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
    print('ProfileScreen: Starting to load profile');
    try {
      final response = await _profileFuture;
      print('ProfileScreen: Received profile response: $response');
      if (response['status'] == 'success' && response['data'] != null) {
        final profileData = response['data'];
        print('ProfileScreen: Extracted profile data: $profileData');
        setState(() {
          print('ProfileScreen: Updating UI with new data');
          _firstNameController.text = profileData['firstName'] ?? '';
          _lastNameController.text = profileData['lastName'] ?? '';
          _genderController.text = profileData['gender'] ?? '';
          _phoneController.text = profileData['phone'] ?? '';
          _emailController.text = profileData['email'] ?? '';
          _addressController.text = profileData['address'] ?? '';
          _avatarUrl = profileData['avatar'];
          if (_role == 'doctor') {
            _specialiseController.text = profileData['specialise'] ?? '';
            _aboutController.text = profileData['about'] ?? '';
          }
          print(
              'ProfileScreen: Updated controllers - FirstName: ${_firstNameController.text}, Address: ${_addressController.text}, Avatar: $_avatarUrl');
        });
      } else {
        print('ProfileScreen: Error - Invalid response status or data');
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
    print('ProfileScreen: Starting profile update');
    if (_formKey.currentState!.validate()) {
      print('ProfileScreen: Form validated successfully');
      setState(() => _isLoading = true);
      print('ProfileScreen: Set loading state to true');
      try {
        Map<String, dynamic> response;
        final data = {
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'gender': _genderController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          if (_newAvatar != null) 'avatar': _newAvatar,
        };
        if (_role == 'doctor') {
          data['specialise'] = _specialiseController.text;
          data['about'] = _aboutController.text;
        }
        print('ProfileScreen: Prepared update data: $data');
        if (_role == 'doctor') {
          print('ProfileScreen: Updating doctor profile');
          response = await DoctorService.updateDoctorProfile(data);
        } else {
          print('ProfileScreen: Updating user profile');
          response = await UserService.updateUserProfile(data);
        }
        print('ProfileScreen: Received update response: $response');
        if (response['status'] == 'success') {
          print('ProfileScreen: Update successful');
          setState(() {
            print('ProfileScreen: Refreshing profile future');
            _profileFuture = _role == 'doctor'
                ? DoctorService.getDoctorProfile()
                : UserService.getUserProfile();
          });
          await _loadProfile();
          print('ProfileScreen: Profile reloaded after update');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Profile updated successfully'),
              backgroundColor: AppColors.statusUpcoming,
            ),
          );
          setState(() {
            print(
                'ProfileScreen: Updating avatar URL: ${response['data']['avatar'] ?? _avatarUrl}');
            _avatarUrl = response['data']['avatar'] ?? _avatarUrl;
            _newAvatar = null;
            print('ProfileScreen: Cleared new avatar');
          });
        } else {
          print('ProfileScreen: Error - Update failed: ${response['message']}');
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
        print('ProfileScreen: Setting loading state to false');
        setState(() => _isLoading = false);
      }
    } else {
      print('ProfileScreen: Form validation failed');
    }
  }

  void _showEditAvatarDialog() {
    print('ProfileScreen: Showing edit avatar dialog');
    bool isDialogEditPressed = false;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              title: Text(
                'Edit Profile Picture',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.photo),
                    title: Text('Choose from Gallery'),
                    onTap: () async {
                      print('ProfileScreen: Selecting image from gallery');
                      Navigator.pop(dialogContext);
                      final pickedFile =
                          await _picker.pickImage(source: ImageSource.gallery);
                      if (pickedFile != null) {
                        final bytes = await pickedFile.readAsBytes();
                        final base64Image = base64Encode(bytes);
                        print(
                            'ProfileScreen: Image selected - Base64 length: ${base64Image.length}');
                        setState(() {
                          _newAvatar = 'data:image/jpeg;base64,$base64Image';
                          print(
                              'ProfileScreen: Updated newAvatar: $_newAvatar');
                        });
                      } else {
                        print('ProfileScreen: No image selected');
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.camera_alt),
                    title: Text('Take a Photo'),
                    onTap: () async {
                      print('ProfileScreen: Taking a photo');
                      Navigator.pop(dialogContext);
                      final pickedFile =
                          await _picker.pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        final bytes = await pickedFile.readAsBytes();
                        final base64Image = base64Encode(bytes);
                        print(
                            'ProfileScreen: Photo taken - Base64 length: ${base64Image.length}');
                        setState(() {
                          _newAvatar = 'data:image/jpeg;base64,$base64Image';
                          print(
                              'ProfileScreen: Updated newAvatar: $_newAvatar');
                        });
                      } else {
                        print('ProfileScreen: No photo taken');
                      }
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.delete),
                    title: Text('Remove Photo'),
                    onTap: () async {
                      print('ProfileScreen: Removing photo');
                      Navigator.pop(dialogContext);
                      setState(() {
                        _newAvatar = null;
                        print('ProfileScreen: Cleared newAvatar');
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    print('ProfileScreen: Canceling avatar edit');
                    Navigator.pop(dialogContext);
                  },
                  child: Text('Cancel'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFullImage() {
    print('ProfileScreen: Showing full image');
    if (_newAvatar != null || _avatarUrl != null) {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          child: GestureDetector(
            onTap: () {
              print('ProfileScreen: Closing full image view');
              Navigator.pop(context);
            },
            child: _newAvatar != null
                ? Image.memory(
                    base64Decode(_newAvatar!.split(',').last),
                    fit: BoxFit.cover,
                  )
                : _avatarUrl!.startsWith('data:image')
                    ? Image.memory(
                        base64Decode(_avatarUrl!.split(',').last),
                        fit: BoxFit.cover,
                      )
                    : Image.network(
                        _avatarUrl!,
                        errorBuilder: (context, error, stackTrace) {
                          print(
                              'ProfileScreen: Error loading network image: $error');
                          return const Icon(Icons.error);
                        },
                        cacheWidth: 500,
                        cacheHeight: 500,
                      ),
          ),
        ),
      );
    } else {
      print('ProfileScreen: No image to show');
    }
  }

  @override
  void dispose() {
    print('ProfileScreen: Disposing controllers');
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
    print('ProfileScreen: Building UI');
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Profile',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            print('ProfileScreen: Navigating back');
            Navigator.pop(context);
          },
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Map<String, dynamic>>(
          future: _profileFuture,
          builder: (context, snapshot) {
            print(
                'ProfileScreen: FutureBuilder - Connection State: ${snapshot.connectionState}');
            if (snapshot.connectionState == ConnectionState.waiting) {
              print('ProfileScreen: Displaying loading indicator');
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            } else if (snapshot.hasError) {
              print('ProfileScreen: Displaying error: ${snapshot.error}');
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            } else if (!snapshot.hasData ||
                snapshot.data!['status'] != 'success' ||
                snapshot.data!['data'] == null) {
              print('ProfileScreen: Displaying failed to load message');
              return Center(
                child: Text(
                  'Failed to load profile',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            }

            print('ProfileScreen: Displaying profile data');
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: _showFullImage,
                        child: CircleAvatar(
                          radius: 50.r,
                          backgroundImage: _newAvatar != null
                              ? MemoryImage(
                                  base64Decode(_newAvatar!.split(',').last))
                              : _avatarUrl != null
                                  ? (_avatarUrl!.startsWith('data:image')
                                          ? MemoryImage(base64Decode(
                                              _avatarUrl!.split(',').last))
                                          : NetworkImage(_avatarUrl!))
                                      as ImageProvider
                                  : null,
                          onBackgroundImageError: (error, stackTrace) {
                            print(
                                'ProfileScreen: Error loading avatar: $error');
                            setState(() => _avatarUrl = null);
                          },
                          child: _newAvatar == null && _avatarUrl == null
                              ? Icon(
                                  Icons.person,
                                  size: 50.r,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      IconButton(
                        icon: Icon(Icons.edit,
                            size: 20.sp, color: Theme.of(context).primaryColor),
                        onPressed: _showEditAvatarDialog,
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
                              onTapDown: (_) =>
                                  setState(() => _isButtonPressed = true),
                              onTapUp: (_) {
                                print('ProfileScreen: Update button released');
                                setState(() => _isButtonPressed = false);
                                _updateProfile();
                              },
                              onTapCancel: () =>
                                  setState(() => _isButtonPressed = false),
                              child: AnimatedScale(
                                scale: _isButtonPressed ? 0.95 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: ElevatedButton(
                                  onPressed: _updateProfile,
                                  style: ElevatedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 32.w, vertical: 12.h),
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
    print('ProfileScreen: Building text field for $label');
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
          print('ProfileScreen: Validation error - $label is required');
          return 'This field is required';
        }
        if (isPhone && !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
          print('ProfileScreen: Validation error - Invalid phone number');
          return 'Invalid phone number';
        }
        return null;
      },
    );
  }
}
