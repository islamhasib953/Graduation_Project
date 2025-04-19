// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/models/vaccination_model.dart';
// import 'package:segma/services/vaccination_service.dart';

// class VaccinationCubit extends Cubit<List<Vaccination>> {
//   String? _error;

//   VaccinationCubit() : super([]);

//   Future<void> fetchVaccinations(String childId) async {
//     try {
//       final result = await VaccinationService.getVaccinations(childId);
//       if (result['status'] == 'success') {
//         emit(result['data'] as List<Vaccination>);
//         _error = null;
//       } else {
//         _error = result['message'];
//         emit([]);
//       }
//     } catch (e) {
//       _error = e.toString();
//       emit([]);
//     }
//   }

//   Future<void> logVaccination({
//     required String childId,
//     required String userVaccinationId,
//     required String status,
//     required DateTime actualDate,
//     String? notes,
//     String? image,
//   }) async {
//     try {
//       final result = await VaccinationService.logVaccination(
//         childId: childId,
//         userVaccinationId: userVaccinationId,
//         status: status,
//         actualDate: actualDate,
//         notes: notes,
//         image: image,
//       );
//       if (result['status'] == 'success') {
//         _error = null;
//         await fetchVaccinations(childId); // Refresh the list after logging
//       } else {
//         _error = result['message'];
//       }
//     } catch (e) {
//       _error = e.toString();
//     }
//   }

//   String? get error => _error;

//   void clearError() {
//     _error = null;
//   }
// }


import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/vaccination_model.dart';
import 'package:segma/services/vaccination_service.dart';

// تعريف الحالات (States) للـ VaccinationCubit
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
      emit(VaccinationLoading());
      final response = await VaccinationService.getVaccinations(childId);
      if (response['status'] == 'success') {
        final List<Vaccination> vaccinations = response['data'];
        emit(VaccinationLoaded(vaccinations));
      } else {
        emit(VaccinationError('Failed to load vaccinations'));
      }
    } catch (e) {
      emit(VaccinationError('Error: $e'));
    }
  }

  Future<void> logVaccination({
    required String childId,
    required String userVaccinationId,
    required String status,
    required DateTime actualDate,
    required String notes,
    required String? image,
  }) async {
    try {
      final response = await VaccinationService.logVaccination(
        childId: childId,
        userVaccinationId: userVaccinationId,
        status: status,
        actualDate: actualDate,
        notes: notes,
        image: image,
      );
      if (response['status'] == 'success') {
        // نجيب التطعيمات تاني بعد التعديل
        fetchVaccinations(childId);
      } else {
        emit(VaccinationError('Failed to log vaccination'));
      }
    } catch (e) {
      emit(VaccinationError('Error: $e'));
    }
  }
}