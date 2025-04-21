import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:segma/models/child_model.dart';
import 'package:segma/services/user_service.dart';

class ParentInfoScreen extends StatefulWidget {
  final Child child;

  const ParentInfoScreen({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  _ParentInfoScreenState createState() => _ParentInfoScreenState();
}

class _ParentInfoScreenState extends State<ParentInfoScreen> {
  String? userGender;
  String? userPhone;
  String? userFirstName;
  String? userLastName;
  String? userEmail;
  String? userAddress;
  List<String> additionalInfoList = [];
  bool isAddingInfo = false;
  bool isLoading = false;
  bool hasError = false;
  String? errorMessage;
  Map<String, String?> userInfoMap = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
      hasError = false;
      errorMessage = null;
    });
    try {
      final result = await UserService.getUserProfile();
      print('🔍 Load User Data Result: $result');
      if (result['status'] == 'success') {
        final userData = result['data'];
        setState(() {
          userGender = userData['gender']?.toLowerCase();
          userPhone = userData['phone'];
          userFirstName = userData['firstName'];
          userLastName = userData['lastName'];
          userEmail = userData['email'];
          userAddress = userData['address'];

          userInfoMap = {
            'First Name': userFirstName,
            'Last Name': userLastName,
            'Phone': userPhone,
            'Gender': userGender == 'male' ? 'Father' : userGender == 'female' ? 'Mother' : 'Parent',
            if (userEmail != null) 'Email': userEmail,
            if (userAddress != null) 'Address': userAddress,
          };
          print('👤 User Info Map: $userInfoMap');
        });
      } else {
        setState(() {
          hasError = true;
          errorMessage = result['message'] ?? 'فشل في جلب بيانات المستخدم';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage!),
            action: SnackBarAction(
              label: 'إعادة المحاولة',
              onPressed: _loadUserData,
            ),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      print('🔥 Error loading user data: $e');
      setState(() {
        hasError = true;
        errorMessage = 'خطأ في جلب بيانات المستخدم: $e';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage!),
          action: SnackBarAction(
            label: 'إعادة المحاولة',
            onPressed: _loadUserData,
          ),
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _toggleAddInfo() {
    setState(() {
      isAddingInfo = !isAddingInfo;
    });
  }

  void _addInfo(String info) {
    if (info.isNotEmpty && !additionalInfoList.contains(info)) {
      setState(() {
        additionalInfoList.add(info);
        isAddingInfo = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedBirthDate = DateFormat('dd MMM yyyy').format(widget.child.birthDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Parents Info',
          style: TextStyle(
            fontFamily: 'Roboto',
            fontSize: 20.sp,
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        errorMessage ?? 'حدث خطأ أثناء جلب البيانات',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontFamily: 'Roboto',
                          color: Colors.red,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: _loadUserData,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'إعادة المحاولة',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(16.w),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Child Info Section
                        Row(
                          children: [
                            widget.child.photo != null
                                ? ClipOval(
                                    child: Image.network(
                                      widget.child.photo!,
                                      width: 60.r,
                                      height: 60.r,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 60.r,
                                        height: 60.r,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.grey.shade300,
                                        ),
                                        child: Icon(
                                          Icons.person,
                                          size: 30.sp,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 60.r,
                                    height: 60.r,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey.shade300,
                                    ),
                                    child: Icon(
                                      Icons.person,
                                      size: 30.sp,
                                      color: Colors.white,
                                    ),
                                  ),
                            SizedBox(width: 16.w),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.child.name,
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.cake,
                                      size: 16.sp,
                                      color: Colors.grey,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      formattedBirthDate,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: Colors.grey,
                                        fontFamily: 'Roboto',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 24.h),
                        // Parent Info Section
                        Container(
                          padding: EdgeInsets.all(16.w),
                          decoration: BoxDecoration(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey.shade800
                                : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    userGender == 'male' ? Icons.male : Icons.female,
                                    size: 20.sp,
                                    color: userGender == 'male' ? Colors.blue : Colors.pink,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    userGender == 'male'
                                        ? 'Father'
                                        : userGender == 'female'
                                            ? 'Mother'
                                            : 'Parent',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              if (userFirstName != null && userLastName != null)
                                Text(
                                  '$userFirstName $userLastName',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              if (userPhone != null) ...[
                                SizedBox(height: 4.h),
                                Text(
                                  userPhone!,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        // Additional Parent Info
                        if (additionalInfoList.isNotEmpty) ...[
                          SizedBox(height: 16.h),
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: additionalInfoList.map((info) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.info,
                                        size: 20.sp,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(width: 8.w),
                                      Expanded(
                                        child: Text(
                                          info,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontFamily: 'Roboto',
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                        SizedBox(height: 24.h),
                        // Add Parent Info Button or Info List
                        if (!isAddingInfo)
                          OutlinedButton(
                            onPressed: _toggleAddInfo,
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                              side: BorderSide(color: Colors.blue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.r),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 20.sp,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  'Add Parent Info',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.blue,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            padding: EdgeInsets.all(16.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                ...userInfoMap.entries.map((entry) {
                                  final label = entry.key;
                                  final value = entry.value;
                                  if (value == null || value.isEmpty) return const SizedBox.shrink();
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 8.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '$label: $value',
                                            style: TextStyle(
                                              fontSize: 14.sp,
                                              fontFamily: 'Roboto',
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          onPressed: () => _addInfo('$label: $value'),
                                          icon: Icon(
                                            Icons.add_circle,
                                            color: Colors.blue,
                                            size: 20.sp,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                SizedBox(height: 8.h),
                                OutlinedButton(
                                  onPressed: _toggleAddInfo,
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                                    side: BorderSide(color: Colors.red),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: Colors.red,
                                      fontFamily: 'Roboto',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
    );
  }
}