// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/models/vaccination_model.dart';
// import 'package:segma/services/vaccination_service.dart';

// // تعريف الحالات (States) للـ VaccinationCubit
// abstract class VaccinationState {}

// class VaccinationInitial extends VaccinationState {}

// class VaccinationLoading extends VaccinationState {}

// class VaccinationLoaded extends VaccinationState {
//   final List<Vaccination> vaccinations;

//   VaccinationLoaded(this.vaccinations);
// }

// class VaccinationError extends VaccinationState {
//   final String message;

//   VaccinationError(this.message);
// }

// class VaccinationCubit extends Cubit<VaccinationState> {
//   VaccinationCubit() : super(VaccinationInitial());

//   Future<void> fetchVaccinations(String childId) async {
//     try {
//       print('Starting fetchVaccinations for childId: $childId');
//       emit(VaccinationLoading());
//       final response = await VaccinationService.getVaccinations(childId);
//       print('Received response from getVaccinations: $response');
//       if (response['status'] == 'success') {
//         final List<Vaccination> vaccinations = response['data'];
//         print('Vaccinations loaded: $vaccinations');
//         emit(VaccinationLoaded(vaccinations));
//       } else {
//         print('Failed to load vaccinations: ${response['message']}');
//         emit(VaccinationError('Failed to load vaccinations'));
//       }
//     } catch (e) {
//       print('Error fetching vaccinations: $e');
//       emit(VaccinationError('Error: $e'));
//     }
//   }

//   Future<void> logVaccination({
//     required String childId,
//     required String userVaccinationId,
//     required String status,
//     required DateTime actualDate,
//     required String notes,
//     required String? image,
//   }) async {
//     try {
//       print('Starting logVaccination for childId: $childId, userVaccinationId: $userVaccinationId');
//       final response = await VaccinationService.logVaccination(
//         childId: childId,
//         userVaccinationId: userVaccinationId,
//         status: status,
//         actualDate: actualDate,
//         notes: notes,
//         image: image,
//       );
//       print('Received response from logVaccination: $response');
//       if (response['status'] == 'success') {
//         print('Vaccination logged successfully, refetching vaccinations...');
//         await fetchVaccinations(childId); // انتظر إكمال الاستدعاء
//         print('Refetch completed, current state: ${state.toString()}');
//       } else {
//         print('Failed to log vaccination: ${response['message']}');
//         emit(VaccinationError('Failed to log vaccination'));
//       }
//     } catch (e) {
//       print('Error logging vaccination: $e');
//       emit(VaccinationError('Error: $e'));
//     }
//   }
// }

import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/vaccination_model.dart';
import 'package:segma/services/vaccination_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class VaccinationState {}

class VaccinationInitial extends VaccinationState {}

class VaccinationLoading extends VaccinationState {}

class VaccinationLoaded extends VaccinationState {
  final List<Vaccination> vaccinations;

  VaccinationLoaded(this.vaccinations);
}

class VaccinationError extends VaccinationState {
  final String message;

  VaccinationError(this.message);
}

class VaccinationCubit extends Cubit<VaccinationState> {
  VaccinationCubit() : super(VaccinationInitial());

  Future<void> fetchVaccinations(String childId) async {
    try {
      print('Starting fetchVaccinations for childId: $childId');
      emit(VaccinationLoading());
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('vaccinations_$childId');
      if (cachedData != null) {
        final List<Vaccination> cachedVaccinations =
            (jsonDecode(cachedData) as List)
                .map((json) => Vaccination.fromJson(json))
                .toList();
        emit(VaccinationLoaded(cachedVaccinations));
      }

      final response = await VaccinationService.getVaccinations(childId);
      print('Received response from getVaccinations: $response');
      if (response['status'] == 'success') {
        final List<Vaccination> vaccinations = response['data'];
        print('Vaccinations loaded: $vaccinations');
        await prefs.setString(
            'vaccinations_$childId', jsonEncode(vaccinations));
        emit(VaccinationLoaded(vaccinations));
      } else {
        print('Failed to load vaccinations: ${response['message']}');
        emit(VaccinationError('Failed to load vaccinations'));
      }
    } catch (e) {
      print('Error fetching vaccinations: $e');
      emit(VaccinationError('Error: $e'));
    }
  }

  Future<Map<String, dynamic>> logVaccination({
    required String childId,
    required String userVaccinationId,
    required String status,
    required DateTime actualDate,
    required String notes,
    required String? image,
  }) async {
    try {
      print(
          'Starting logVaccination for childId: $childId, userVaccinationId: $userVaccinationId');
      final response = await VaccinationService.logVaccination(
        childId: childId,
        userVaccinationId: userVaccinationId,
        status: status,
        actualDate: actualDate,
        notes: notes,
        image: image,
      );
      print('Received response from logVaccination: $response');
      if (response['status'] == 'success') {
        print('Vaccination logged successfully, refetching vaccinations...');
        await fetchVaccinations(childId); // تحديث القائمة
      } else {
        print('Failed to log vaccination: ${response['message']}');
      }
      return response; // إرجاع الاستجابة
    } catch (e) {
      print('Error logging vaccination: $e');
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }
}
