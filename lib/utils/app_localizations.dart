// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class AppLocalizations {
//   AppLocalizations(this.locale);

//   final Locale locale;

//   static AppLocalizations? of(BuildContext context) {
//     return Localizations.of<AppLocalizations>(context, AppLocalizations);
//   }

//   static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

//   String _getText(String key) {
//     final translations = _localizedValues[locale.languageCode] ?? _localizedValues['en']!;
//     return translations[key] ?? 'Missing translation for "$key"';
//   }

//   // تنسيق التاريخ بناءً على اللغة
//   String formatDate(DateTime date) {
//     final formatter = DateFormat.yMMMd(locale.languageCode);
//     return formatter.format(date);
//   }

//   // تنسيق الوقت بناءً على اللغة
//   String formatTime(TimeOfDay time) {
//     final now = DateTime.now();
//     final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
//     final formatter = DateFormat.Hm(locale.languageCode);
//     return formatter.format(dateTime);
//   }

//   static const Map<String, Map<String, String>> _localizedValues = {
//     'en': {
//       // General
//       'error': 'Error',
//       'cancel': 'Cancel',
//       'delete': 'Delete',
//       'na': 'N/A',
//       'save': 'Save',
//       'confirm': 'Confirm',

//       // LogDiagnosisScreen
//       'addDiagnosis': 'Add Diagnosis',
//       'updateDiagnosis': 'Update Diagnosis',
//       'diagnosis': 'Diagnosis',
//       'disease': 'Disease',
//       'treatment': 'Treatment',
//       'notes': 'Notes',
//       'date': 'Date',
//       'time': 'Time',
//       'notesImage': 'Notes Image',
//       'pickImage': 'Pick Image',
//       'selectDateTime': 'Please select a date and time',
//       'diagnosisAdded': 'Diagnosis added successfully',
//       'diagnosisUpdated': 'Diagnosis updated successfully',
//       'noImageSelected': 'No image selected',
//       'errorLoadingImage': 'Error loading image',
//       'enterDiagnosis': 'Please enter a diagnosis',
//       'enterDisease': 'Please enter a disease',
//       'enterTreatment': 'Please enter a treatment',
//       'enterNotes': 'Please enter notes',

//       // AllHistoryScreen
//       'childRecords': 'Child Records',
//       'history': 'History',
//       'growth': 'Growth',
//       'enterChildId': 'Enter Child ID',
//       'search': 'Search',
//       'noHistoryRecords': 'No history records found',
//       'noGrowthRecords': 'No growth records found',
//       'details': 'Details',
//       'record': 'Record',

//       // HistoryDetailsDoctorScreen
//       'diagnosisDetails': 'Diagnosis Details',
//       'confirmDeletion': 'Confirm Deletion',
//       'confirmDeletionMessage': 'Type "DELETE" to confirm deletion of this diagnosis record.',
//       'typeDelete': 'Type DELETE',
//       'diagnosisDeleted': 'Diagnosis deleted successfully',
//       'doctor': 'Doctor',

//       // DoctorHomeScreen
//       'doctorHome': 'Doctor Home',
//       'helloDoctor': 'Hello, Dr. %s',
//       'upcomingAppointments': 'You have %d appointments',
//       'noUpcomingAppointments': 'No upcoming appointments',
//       'errorLoadingAppointments': 'Error loading appointments',
//       'retry': 'Retry',
//       'notificationNotImplemented': 'Notification screen is not implemented yet',
//       'schedule': 'Schedule',
//       'home': 'Home',
//       'notification': 'Notifications',
//       'settings': 'Settings',

//       // DoctorAvailabilityScreen
//       'setYourAvailability': 'Set Your Availability',
//       'selectAvailableDays': 'Select Available Days',
//       'availableTimes': 'Available Times',
//       'noTimesAdded': 'No times added yet',
//       'saveAvailability': 'Save Availability',
//       'availabilityUpdated': 'Availability updated successfully',
//       'errorUpdatingAvailability': 'Error updating availability',
//       'selectDayAndTime': 'Please select at least one day and one time',

//       // SettingsScreen
//       'settings': 'Settings',
//       'themeSettings': 'Theme Settings',
//       'lightMode': 'Light Mode',
//       'darkMode': 'Dark Mode',
//       'systemDefault': 'System Default',
//       'languageSettings': 'Language Settings',
//       'english': 'English',
//       'arabic': 'Arabic',
//       'frequentlyAskedQuestions': 'FAQs',
//       'about': 'About',
//       'contactUs': 'Contact Us',
//       'logout': 'Logout',
//       'profile': 'Profile',
//       'changePassword': 'Change Password',
//       'helpContent': 'Help Center',

//       // DoctorSettingsScreen
//       'doctorSettings': 'Doctor Settings',
//       'myDoctorProfile': 'My Profile',
//       'language': 'Language',
//       'help': 'Help',
//       'aboutUs': 'About Us',
//       'aboutUsContent': 'We are a healthcare platform dedicated to connecting doctors and patients efficiently.',
//       'deleteDoctorAccount': 'Delete Account',
//       'logOut': 'Log Out',
//       'confirmAccountDeletion': 'Confirm Account Deletion',
//       'typeDeleteToConfirm': 'Type "DELETE" to confirm account deletion.',
//       'accountDeletedSuccessfully': 'Account deleted successfully',
//       'failedToLogOut': 'Failed to log out',
//       'fieldRequired': 'This field is required',
//       'invalidPhoneNumber': 'Invalid phone number',
//       'profileUpdatedSuccessfully': 'Profile updated successfully',
//       'failedToLoadProfile': 'Failed to load profile',
//       'firstName': 'First Name',
//       'lastName': 'Last Name',
//       'gender': 'Gender',
//       'phone': 'Phone',
//       'email': 'Email',
//       'address': 'Address',
//       'specialization': 'Specialization',
//       'about': 'About',
//       'updateProfile': 'Update Profile',
//     },
//     'ar': {
//       // General
//       'error': 'خطأ',
//       'cancel': 'إلغاء',
//       'delete': 'حذف',
//       'na': 'غير متوفر',
//       'save': 'حفظ',
//       'confirm': 'تأكيد',

//       // LogDiagnosisScreen
//       'addDiagnosis': 'إضافة تشخيص',
//       'updateDiagnosis': 'تحديث التشخيص',
//       'diagnosis': 'التشخيص',
//       'disease': 'المرض',
//       'treatment': 'العلاج',
//       'notes': 'ملاحظات',
//       'date': 'التاريخ',
//       'time': 'الوقت',
//       'notesImage': 'صورة الملاحظات',
//       'pickImage': 'اختيار صورة',
//       'selectDateTime': 'يرجى اختيار التاريخ والوقت',
//       'diagnosisAdded': 'تم إضافة التشخيص بنجاح',
//       'diagnosisUpdated': 'تم تحديث التشخيص بنجاح',
//       'noImageSelected': 'لم يتم اختيار صورة',
//       'errorLoadingImage': 'خطأ في تحميل الصورة',
//       'enterDiagnosis': 'يرجى إدخال التشخيص',
//       'enterDisease': 'يرجى إدخال المرض',
//       'enterTreatment': 'يرجى إدخال العلاج',
//       'enterNotes': 'يرجى إدخال الملاحظات',

//       // AllHistoryScreen
//       'childRecords': 'سجلات الطفل',
//       'history': 'التاريخ',
//       'growth': 'النمو',
//       'enterChildId': 'أدخل معرف الطفل',
//       'search': 'بحث',
//       'noHistoryRecords': 'لم يتم العثور على سجلات تاريخية',
//       'noGrowthRecords': 'لم يتم العثور على سجلات نمو',
//       'details': 'التفاصيل',
//       'record': 'سجل',

//       // HistoryDetailsDoctorScreen
//       'diagnosisDetails': 'تفاصيل التشخيص',
//       'confirmDeletion': 'تأكيد الحذف',
//       'confirmDeletionMessage': 'اكتب "DELETE" لتأكيد حذف سجل التشخيص هذا.',
//       'typeDelete': 'اكتب DELETE',
//       'diagnosisDeleted': 'تم حذف التشخيص بنجاح',
//       'doctor': 'الطبيب',

//       // DoctorHomeScreen
//       'doctorHome': 'الصفحة الرئيسية للطبيب',
//       'helloDoctor': 'مرحبًا، د. %s',
//       'upcomingAppointments': 'لديك %d مواعيد',
//       'noUpcomingAppointments': 'لا توجد مواعيد قادمة',
//       'errorLoadingAppointments': 'خطأ في تحميل المواعيد',
//       'retry': 'إعادة المحاولة',
//       'notificationNotImplemented': 'شاشة الإشعارات لم يتم تنفيذها بعد',
//       'schedule': 'الجدول',
//       'home': 'الرئيسية',
//       'notification': 'الإشعارات',
//       'settings': 'الإعدادات',

//       // DoctorAvailabilityScreen
//       'setYourAvailability': 'تحديد مواعيدك المتاحة',
//       'selectAvailableDays': 'اختر الأيام المتاحة',
//       'availableTimes': 'الأوقات المتاحة',
//       'noTimesAdded': 'لم يتم إضافة أوقات بعد',
//       'saveAvailability': 'حفظ المواعيد المتاحة',
//       'availabilityUpdated': 'تم تحديث المواعيد المتاحة بنجاح',
//       'errorUpdatingAvailability': 'خطأ في تحديث المواعيد المتاحة',
//       'selectDayAndTime': 'يرجى اختيار يوم واحد على الأقل ووقت واحد',

//       // SettingsScreen
//       'settings': 'الإعدادات',
//       'themeSettings': 'إعدادات الثيم',
//       'lightMode': 'الوضع الفاتح',
//       'darkMode': 'الوضع الداكن',
//       'systemDefault': 'افتراضي النظام',
//       'languageSettings': 'إعدادات اللغة',
//       'english': 'الإنجليزية',
//       'arabic': 'العربية',
//       'frequentlyAskedQuestions': 'الأسئلة الشائعة',
//       'about': 'حول التطبيق',
//       'contactUs': 'تواصل معنا',
//       'logout': 'تسجيل الخروج',
//       'profile': 'الملف الشخصي',
//       'changePassword': 'تغيير كلمة المرور',
//       'helpContent': 'مركز المساعدة',

//       // DoctorSettingsScreen
//       'doctorSettings': 'إعدادات الطبيب',
//       'myDoctorProfile': 'ملفي الشخصي',
//       'language': 'اللغة',
//       'help': 'المساعدة',
//       'aboutUs': 'معلومات عنا',
//       'aboutUsContent': 'نحن منصة صحية مكرسة لربط الأطباء والمرضى بكفاءة.',
//       'deleteDoctorAccount': 'حذف الحساب',
//       'logOut': 'تسجيل الخروج',
//       'confirmAccountDeletion': 'تأكيد حذف الحساب',
//       'typeDeleteToConfirm': 'اكتب "DELETE" لتأكيد حذف الحساب.',
//       'accountDeletedSuccessfully': 'تم حذف الحساب بنجاح',
//       'failedToLogOut': 'فشل تسجيل الخروج',
//       'fieldRequired': 'هذا الحقل مطلوب',
//       'invalidPhoneNumber': 'رقم الهاتف غير صالح',
//       'profileUpdatedSuccessfully': 'تم تحديث الملف الشخصي بنجاح',
//       'failedToLoadProfile': 'فشل تحميل الملف الشخصي',
//       'firstName': 'الاسم الأول',
//       'lastName': 'الاسم الأخير',
//       'gender': 'الجنس',
//       'phone': 'الهاتف',
//       'email': 'البريد الإلكتروني',
//       'address': 'العنوان',
//       'specialization': 'التخصص',
//       'about': 'حول',
//       'updateProfile': 'تحديث الملف الشخصي',
//     },
//   };

//   // الخصائص الأساسية فقط للتوافق مع DoctorSettingsScreen
//   String get doctorSettings => _getText('doctorSettings');
//   String get myDoctorProfile => _getText('myDoctorProfile');
//   String get language => _getText('language');
//   String get help => _getText('help');
//   String get aboutUs => _getText('aboutUs');
//   String get aboutUsContent => _getText('aboutUsContent');
//   String get deleteDoctorAccount => _getText('deleteDoctorAccount');
//   String get logOut => _getText('logOut');
//   String get confirmAccountDeletion => _getText('confirmAccountDeletion');
//   String get typeDeleteToConfirm => _getText('typeDeleteToConfirm');
//   String get accountDeletedSuccessfully => _getText('accountDeletedSuccessfully');
//   String get failedToLogOut => _getText('failedToLogOut');
//   String get fieldRequired => _getText('fieldRequired');
//   String get invalidPhoneNumber => _getText('invalidPhoneNumber');
//   String get profileUpdatedSuccessfully => _getText('profileUpdatedSuccessfully');
//   String get failedToLoadProfile => _getText('failedToLoadProfile');
//   String get firstName => _getText('firstName');
//   String get lastName => _getText('lastName');
//   String get gender => _getText('gender');
//   String get phone => _getText('phone');
//   String get email => _getText('email');
//   String get address => _getText('address');
//   String get specialization => _getText('specialization');
//   String get about => _getText('about');
//   String get updateProfile => _getText('updateProfile');
//   String get lightMode => _getText('lightMode');
//   String get darkMode => _getText('darkMode');
//   String get systemDefault => _getText('systemDefault');
//   String get english => _getText('english');
//   String get arabic => _getText('arabic');
// }

// class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
//   const _AppLocalizationsDelegate();

//   @override
//   bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

//   @override
//   Future<AppLocalizations> load(Locale locale) async {
//     // تهيئة intl للغة الحالية
//     Intl.defaultLocale = locale.languageCode;
//     return AppLocalizations(locale);
//   }

//   @override
//   bool shouldReload(_AppLocalizationsDelegate old) => false;
// }