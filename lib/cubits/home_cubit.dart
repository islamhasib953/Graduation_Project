// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:segma/models/user_model.dart';
// import 'package:segma/services/api_service.dart';
// import 'package:segma/services/login_service.dart';

// class HomeCubit extends Cubit<HomeState> {
//   final AuthService _apiService = AuthService();

//   HomeCubit() : super(HomeState(user: UserModel.empty()));

//   Future<void> fetchUserData() async {
//     try {
//       emit(HomeState(user: state.user, isLoading: true));

//       final userData = await _apiService.fetchUserData();

//       emit(HomeState(user: userData));
//     } catch (e) {
//       emit(HomeState(user: UserModel.empty(), error: e.toString()));
//     }
//   }
// }

// class HomeState {
//   final UserModel user;
//   final String? error;
//   final bool isLoading;

//   HomeState({required this.user, this.error, this.isLoading = false});
// }
