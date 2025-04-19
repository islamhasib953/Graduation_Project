import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:segma/cubits/selected_child_cubit.dart';
import 'package:segma/models/doctor_model.dart';
import 'package:segma/screens/doctor_user/doctor_details_screen.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:segma/utils/colors.dart';

class FavoriteDoctorsScreen extends StatefulWidget {
  const FavoriteDoctorsScreen({Key? key}) : super(key: key);

  @override
  _FavoriteDoctorsScreenState createState() => _FavoriteDoctorsScreenState();
}

class _FavoriteDoctorsScreenState extends State<FavoriteDoctorsScreen> {
  Future<void> _toggleFavorite(String childId, String doctorId, bool isFavorite) async {
    try {
      final response = isFavorite
          ? await DoctorService.removeFavorite(childId, doctorId)
          : await DoctorService.toggleFavorite(childId, doctorId);
      if (response['status'] == 'success') {
        setState(() {}); // Refresh the list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isFavorite ? 'Removed from Favorites' : 'Added to Favorites'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update favorites: ${response['message']}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Doctors', style: Theme.of(context).textTheme.titleLarge),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: BlocBuilder<SelectedChildCubit, String?>(
        builder: (context, childId) {
          if (childId == null) {
            return Center(child: Text('Please select a child', style: Theme.of(context).textTheme.bodyLarge));
          }
          return FutureBuilder<Map<String, dynamic>>(
            future: DoctorService.getFavoriteDoctors(childId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError || !snapshot.hasData || snapshot.data!['status'] != 'success') {
                return Center(
                  child: Text(
                    'Error loading favorite doctors: ${snapshot.error ?? snapshot.data?['message'] ?? 'Unknown error'}',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                );
              }
              final List<Doctor> favoriteDoctors = (snapshot.data!['data'] as List)
                  .map((doctor) => Doctor.fromJson(doctor))
                  .toList();
              if (favoriteDoctors.isEmpty) {
                return Center(child: Text('No favorite doctors found', style: Theme.of(context).textTheme.bodyLarge));
              }
              return GridView.builder(
                padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.8,
                ),
                itemCount: favoriteDoctors.length,
                itemBuilder: (context, index) {
                  final doctor = favoriteDoctors[index];
                  return Card(
                    color: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    elevation: 4,
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorDetailsScreen(doctorId: doctor.id),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12.r),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30.r,
                                backgroundImage: doctor.avatar.isNotEmpty ? NetworkImage(doctor.avatar) : null,
                                backgroundColor: Theme.of(context).colorScheme.secondary,
                                onBackgroundImageError: (error, stackTrace) {},
                                child: doctor.avatar.isEmpty
                                    ? Text(
                                        '${doctor.firstName[0]}${doctor.lastName[0]}',
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                                      )
                                    : null,
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Icon(
                                  Icons.favorite,
                                  color: Theme.of(context).colorScheme.error, // Updated
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            '${doctor.firstName} ${doctor.lastName}',
                            style: Theme.of(context).textTheme.titleMedium,
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DoctorDetailsScreen(doctorId: doctor.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                                child: Text('Details', style: Theme.of(context).textTheme.bodySmall),
                              ),
                              SizedBox(width: 8.w),
                              ElevatedButton(
                                onPressed: () {
                                  // TODO: Implement chat functionality
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Chat functionality not implemented')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).primaryColor,
                                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                ),
                                child: Text('Chat', style: Theme.of(context).textTheme.bodySmall),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          IconButton(
                            icon: Icon(Icons.favorite, color: Theme.of(context).colorScheme.error), // Updated
                            onPressed: () => _toggleFavorite(childId, doctor.id, true),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}