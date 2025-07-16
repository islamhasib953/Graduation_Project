import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:segma/models/appointment_model.dart';
import 'package:segma/services/doctor_service.dart';
import 'package:intl/intl.dart';

part 'appointments_state.dart';

class AppointmentsCubit extends Cubit<AppointmentsState> {
  AppointmentsCubit() : super(AppointmentsInitial());

  Future<void> fetchAppointments(String childId) async {
    emit(AppointmentsLoading());
    try {
      final response = await DoctorService.getUserAppointments(childId);
      if (response['status'] == 'success') {
        final List<UserAppointment> appointments = (response['data'] as List)
            .map((appointment) => UserAppointment.fromJson(appointment))
            .toList();
        emit(AppointmentsLoaded(appointments));
      } else {
        emit(AppointmentsError(message: response['message'] ?? 'Failed to load appointments'));
      }
    } catch (e) {
      emit(AppointmentsError(message: 'Error: $e'));
    }
  }

  Future<void> bookAppointment(String childId, String doctorId, DateTime date, String time) async {
    emit(AppointmentsLoading());
    try {
      final dateString = DateFormat('yyyy-MM-dd').format(date); // Convert DateTime to String
      final appointmentData = {'date': dateString, 'time': time}; // Create map for API request
      final response = await DoctorService.bookAppointment(childId, doctorId, appointmentData);
      if (response['status'] == 'success') {
        final updatedAppointments = (response['data'] as List)
            .map((appointment) => UserAppointment.fromJson(appointment))
            .toList();
        emit(AppointmentsLoaded(updatedAppointments));
      } else if (response['status'] == 'fail' && response['message'] == 'Slot already booked') {
        emit(AppointmentsError(message: 'This slot is already booked. Please choose another time.'));
      } else {
        emit(AppointmentsError(message: response['message'] ?? 'Failed to book appointment'));
      }
    } catch (e) {
      emit(AppointmentsError(message: 'Error: $e'));
    }
  }

  bool isSlotBooked(DateTime date, String time, List<UserAppointment> appointments) {
    return appointments.any((appointment) =>
        DateTime.parse(appointment.date).isAtSameMomentAs(date) && appointment.time == time);
  }
}