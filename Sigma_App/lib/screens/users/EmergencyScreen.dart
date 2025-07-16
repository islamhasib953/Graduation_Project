import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/utils/colors.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  void _navigateToArticle(BuildContext context, String title, String content) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyArticleScreen(title: title, content: content),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode
              ? [AppColors.darkBackground, AppColors.darkCardBackground]
              : [AppColors.lightBackground, AppColors.lightCardBackground],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(Icons.emergency, size: 80.sp, color: isDarkMode ? AppColors.darkIcon : AppColors.lightIcon),
              SizedBox(height: 10.h),
              Text(
                'Emergency Guide for Kids!',
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                  shadows: [
                    Shadow(color: Colors.black26, offset: Offset(2.w, 2.h), blurRadius: 4.r),
                  ],
                ),
              ),
              SizedBox(height: 20.h),

              // Emergency Numbers Card
              Card(
                color: isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Contacts',
                        style: TextStyle(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.featureDoctor,
                        ),
                      ),
                      SizedBox(height: 10.h),
                      _buildContactRow(context, 'Ambulance (Egypt)', '123', isDarkMode),
                      _buildContactRow(context, 'Police (Egypt)', '122', isDarkMode),
                      _buildContactRow(context, 'Fire Department (Egypt)', '180', isDarkMode),
                      Text(
                        'Always ask an adult to call for help!',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20.h),

              // Emergency Scenarios Grid
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 10.w,
                mainAxisSpacing: 10.h,
                children: [
                  _buildEmergencyIcon(context, 'Falls', Icons.trending_up, '''
Falls are common for kids! If you fall and it hurts a lot, sit down and stay calm. Tell an adult right away. They might put ice on it to reduce swelling. Don’t move if you think something is broken—wait for help. Always wear shoes or helmets when playing to stay safe!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Cuts', Icons.local_hospital, '''
Cuts can happen when you play with sharp things. If you get a cut, tell an adult immediately. They will clean it with water and put a bandage on it. If it bleeds a lot, don’t touch it—get help fast. Keep scissors and knives away from kids!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Choking', Icons.warning, '''
Choking is scary if food or toys get stuck in your throat. If you can’t breathe, try to cough. Tell an adult or point to your throat. They can do the Heimlich maneuver to help. Never eat while running or put small toys in your mouth!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Burns', Icons.local_fire_department, '''
Burns happen if you touch something hot like a stove. Run cold water on it for a few minutes and tell an adult. Don’t put ice or cream on it. Stay away from fire, matches, or hot pans—ask an adult for help in the kitchen!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Allergies', Icons.healing, '''
Allergies can make you itchy or sick if you eat or touch something bad. If your throat feels tight or you get spots, tell an adult fast. They might give you medicine. Know what foods or things you’re allergic to with your parents!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Broken Bones', Icons.broken_image, '''
If you fall hard and can’t move your arm or leg, it might be broken. Sit still and tell an adult. Don’t try to walk on it. Go to a doctor who can fix it with a cast. Be careful on slides or bikes!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Head Injury', Icons.face, '''
A bump on your head from falling can be serious. If you feel dizzy or sleepy, tell an adult right away. They might check you or take you to a hospital. Wear a helmet when biking or skating!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Poisoning', Icons.local_drink, '''
Poisoning happens if you swallow bad stuff like medicine or cleaning items. Tell an adult right away and don’t eat more. They can call for help. Keep dangerous things locked up high!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Drowning', Icons.pool, '''
Drowning can happen in water if you can’t swim. If you’re in trouble, wave your arms and shout. Always swim with an adult and wear a life jacket. Never go near deep water alone!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Fever', Icons.thermostat, '''
A fever means your body is hot because you’re sick. If you feel very warm or tired, tell an adult. They can check your temperature and give you medicine. Rest and drink water!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Asthma Attack', Icons.air, '''
If you can’t breathe well and feel tight in your chest, it might be an asthma attack. Use your inhaler if you have one and tell an adult. Stay calm and sit up straight!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Seizures', Icons.shutter_speed, '''
Seizures make your body shake a lot. If this happens, tell an adult and lay on the ground safely. Don’t hold them—let it stop, then get help. It might happen if you’re very sick!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Bee Stings', Icons.bug_report, '''
Bee stings hurt and can swell. Remove the stinger with a card and tell an adult. They might put ice or cream on it. If you feel dizzy, get help fast—it could be an allergy!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Eye Injury', Icons.remove_red_eye, '''
If something gets in your eye or it hurts, don’t rub it. Tell an adult to rinse it with water. If it’s bad, go to a doctor. Wear goggles when playing with toys!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Sprains', Icons.run_circle, '''
A sprain happens if you twist your ankle or wrist. It might swell—tell an adult. Rest it, ice it, and don’t walk on it. Wear good shoes when running!
''', isDarkMode),
                  _buildEmergencyIcon(context, 'Nosebleeds', Icons.bloodtype, 'Tilt your head forward and tell an adult to pinch your nose. Don’t tilt back!', isDarkMode),
                  _buildEmergencyIcon(context, 'Earache', Icons.hearing, 'If your ear hurts, tell an adult. They can check for infection or clean it.', isDarkMode),
                  _buildEmergencyIcon(context, 'Toothache', Icons.face, 'Rinse with water and tell an adult. Don’t eat hard food if it hurts!', isDarkMode),
                  _buildEmergencyIcon(context, 'Dehydration', Icons.water_drop, 'Drink water if you feel dizzy or dry—tell an adult if it’s bad.', isDarkMode),
                  _buildEmergencyIcon(context, 'Stranded', Icons.map, 'Stay where you are and tell an adult your location.', isDarkMode),
                  _buildEmergencyIcon(context, 'Animal Bite', Icons.pets, 'Wash with water and tell an adult—get help if it’s deep.', isDarkMode),
                  _buildEmergencyIcon(context, 'Electric Shock', Icons.flash_on, 'Don’t touch—tell an adult to turn off power and call help.', isDarkMode),
                  _buildEmergencyIcon(context, 'Heatstroke', Icons.wb_sunny, 'Rest in shade and tell an adult to cool you with water.', isDarkMode),
                  _buildEmergencyIcon(context, 'Frostbite', Icons.ac_unit, 'Warm up slowly and tell an adult if fingers turn white.', isDarkMode),
                  _buildEmergencyIcon(context, 'Lost', Icons.location_off, 'Stay calm, stay put, and tell a trusted adult.', isDarkMode),
                  _buildEmergencyIcon(context, 'Car Accident', Icons.car_crash, 'Stay in the car and wait for an adult or help.', isDarkMode),
                  _buildEmergencyIcon(context, 'Stomach Pain', Icons.sick, 'Tell an adult if it hurts a lot—don’t eat more.', isDarkMode),
                  _buildEmergencyIcon(context, 'Vomiting', Icons.pest_control, 'Rest and tell an adult—drink small sips of water.', isDarkMode),
                  _buildEmergencyIcon(context, 'Coughing Fits', Icons.airline_seat_flat, 'Sit up and tell an adult if it won’t stop.', isDarkMode),
                  _buildEmergencyIcon(context, 'Splinters', Icons.invert_colors_off, 'Tell an adult to remove it with tweezers.', isDarkMode),
                  _buildEmergencyIcon(context, 'Sunburn', Icons.wb_iridescent, 'Stay in shade and tell an adult to put cool water.', isDarkMode),
                  _buildEmergencyIcon(context, 'Strangulation', Icons.no_encryption, 'Tell an adult if something is tight around your neck.', isDarkMode),
                  _buildEmergencyIcon(context, 'Foreign Object', Icons.widgets, 'Don’t pull—tell an adult to remove it safely.', isDarkMode),
                  _buildEmergencyIcon(context, 'Hypothermia', Icons.thermostat, 'Warm up with blankets and tell an adult.', isDarkMode),
                  _buildEmergencyIcon(context, 'Concussion', Icons.brightness_6, 'Rest and tell an adult if you feel confused.', isDarkMode),
                  _buildEmergencyIcon(context, 'Bleeding', Icons.bloodtype, 'Press with a cloth and tell an adult.', isDarkMode),
                  _buildEmergencyIcon(context, 'Insect Bite', Icons.bug_report, 'Wash and tell an adult if it swells.', isDarkMode),
                  _buildEmergencyIcon(context, 'Struck by Object', Icons.gavel, 'Tell an adult if you’re hit hard.', isDarkMode),
                  _buildEmergencyIcon(context, 'Trapped', Icons.lock, 'Stay calm and shout for an adult.', isDarkMode),
                  _buildEmergencyIcon(context, 'Overdose', Icons.local_pharmacy, 'Tell an adult immediately if you take too much medicine.', isDarkMode),
                  _buildEmergencyIcon(context, 'Panic Attack', Icons.heart_broken, 'Breathe slow and tell an adult.', isDarkMode),
                ],
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground,
                  borderRadius: BorderRadius.circular(15.r),
                  boxShadow: [
                    BoxShadow(color: Colors.black12, blurRadius: 6.r, offset: Offset(0, 3.h)),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, color: AppColors.featureDoctor, size: 30.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Be a Superhero – Stay Safe!',
                      style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.featureDoctor),
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

  Widget _buildContactRow(BuildContext context, String title, String number, bool isDarkMode) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5.h),
      child: Row(
        children: [
          Icon(Icons.phone, color: AppColors.featureDoctor, size: 20.sp),
          SizedBox(width: 10.w),
          Text(
            '$title: $number',
            style: TextStyle(fontSize: 16.sp, color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyIcon(BuildContext context, String title, IconData icon, String content, bool isDarkMode) {
    return GestureDetector(
      onTap: () => _navigateToArticle(context, title, content),
      child: Card(
        color: isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 30.sp, color: AppColors.featureDoctor),
            SizedBox(height: 5.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.sp,
                color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EmergencyArticleScreen extends StatelessWidget {
  final String title;
  final String content;

  const EmergencyArticleScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.featureDoctor,
        title: Text(title, style: TextStyle(color: isDarkMode ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDarkMode ? AppColors.darkIcon : AppColors.lightIcon),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [AppColors.darkBackground, AppColors.darkCardBackground]
                : [AppColors.lightBackground, AppColors.lightCardBackground],
          ),
        ),
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Card(
            color: isDarkMode ? AppColors.darkCardBackground : AppColors.lightCardBackground,
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r)),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: AppColors.featureDoctor),
                  ),
                  SizedBox(height: 15.h),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    'Always tell an adult and stay safe, superhero!',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDarkMode ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}