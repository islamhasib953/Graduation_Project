import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedDoctorCubit extends Cubit<String?> {
  SelectedDoctorCubit() : super(null);

  void selectDoctor(String doctorId) {
    print('SelectedDoctorCubit: Selecting doctor with ID: $doctorId');
    emit(doctorId);
  }

  void clearSelection() {
    print('SelectedDoctorCubit: Clearing doctor selection');
    emit(null);
  }
}