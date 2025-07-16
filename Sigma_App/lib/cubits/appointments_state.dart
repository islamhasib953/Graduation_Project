part of 'appointments_cubit.dart';

abstract class AppointmentsState extends Equatable {
  const AppointmentsState();

  @override
  List<Object> get props => [];
}

class AppointmentsInitial extends AppointmentsState {}

class AppointmentsLoading extends AppointmentsState {}

class AppointmentsLoaded extends AppointmentsState {
  final List<UserAppointment> appointments;

  const AppointmentsLoaded(this.appointments);

  @override
  List<Object> get props => [appointments];
}

class AppointmentsError extends AppointmentsState {
  final String message;

  const AppointmentsError({required this.message});

  @override
  List<Object> get props => [message];
}