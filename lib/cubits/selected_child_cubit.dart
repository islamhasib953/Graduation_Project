// import 'package:flutter_bloc/flutter_bloc.dart';

// class SelectedChildCubit extends Cubit<String?> {
//   SelectedChildCubit() : super(null);

//   void selectChild(String childId) {
//     emit(childId);
//   }

//   void clearSelection() {
//     emit(null);
//   }
// }

//**************************************************** */

// import 'package:flutter_bloc/flutter_bloc.dart';

// class SelectedChildCubit extends Cubit<String?> {
//   SelectedChildCubit() : super(null);

//   void selectChild(String childId) {
//     emit(childId);
//   }

//   void clearSelection() {
//     emit(null);
//   }
// }

//************************************************ */

import 'package:flutter_bloc/flutter_bloc.dart';

class SelectedChildCubit extends Cubit<String?> {
  SelectedChildCubit() : super(null);

  void selectChild(String childId) {
    emit(childId);
  }

  void clearChild() {
    emit(null);
  }
}