import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';



class DoctorDetailsCubit extends Cubit<DoctorDetailsState> {
  DoctorDetailsCubit() : super(DoctorDetailsState.initial());

  void selectDate(String date) {
    emit(state.copyWith(selectedDate: date));
  }

  void selectTime(String time) {
    emit(state.copyWith(selectedTime: time));
  }

  void selectVisitType(String visitType) {
    emit(state.copyWith(visitType: visitType));
  }

  void showSuccessAnimation() {
    emit(state.copyWith(showSuccessAnimation: true));
  }

  void resetSuccessAnimation() {
    emit(state.copyWith(showSuccessAnimation: false));
  }
}




/////////////////////////




class DoctorDetailsState extends Equatable {
  final String? selectedDate;
  final String? selectedTime;
  final String visitType;
  final bool showSuccessAnimation;

  const DoctorDetailsState({
    required this.selectedDate,
    required this.selectedTime,
    required this.visitType,
    required this.showSuccessAnimation,
  });

  factory DoctorDetailsState.initial() {
    return DoctorDetailsState(
      selectedDate: DateFormat('yyyy-MM-dd').format(DateTime.now()),
      selectedTime: null,
      visitType: 'On Clinic',
      showSuccessAnimation: false,
    );
  }

  DoctorDetailsState copyWith({
    String? selectedDate,
    String? selectedTime,
    String? visitType,
    bool? showSuccessAnimation,
  }) {
    return DoctorDetailsState(
      selectedDate: selectedDate ?? this.selectedDate,
      selectedTime: selectedTime ?? this.selectedTime,
      visitType: visitType ?? this.visitType,
      showSuccessAnimation: showSuccessAnimation ?? this.showSuccessAnimation,
    );
  }

  @override
  List<Object?> get props => [selectedDate, selectedTime, visitType, showSuccessAnimation];
}