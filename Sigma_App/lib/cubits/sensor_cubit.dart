import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/sensor_data_model.dart';
import 'package:segma/services/sensor_service.dart';

class SensorCubit extends Cubit<SensorState> {
  SensorCubit() : super(SensorInitial());

  void initialize(String childId) {
    SensorService.initializeSocket(childId);
    emit(SensorLoading());
    // لا نحتاج إلى إعادة إصدار الحالة لكل تحديث، سنعتمد على ValueNotifier
    SensorService.latestSensorData.addListener(() {
      if (SensorService.latestSensorData.value != null) {
        // إصدار الحالة فقط عند الحاجة (مثل التحميل الأولي)
        if (state is SensorInitial || state is SensorLoading) {
          emit(SensorLoaded(SensorService.latestSensorData.value!));
        }
      }
    });
    SensorService.latestActivityData.addListener(() {
      if (SensorService.latestActivityData.value != null) {
        emit(ActivityUpdate(SensorService.latestActivityData.value));
      }
    });
    SensorService.latestSleepData.addListener(() {
      if (SensorService.latestSleepData.value != null) {
        emit(SleepUpdate(SensorService.latestSleepData.value));
      }
    });
  }

  Future<void> fetchHistory(String childId, String type) async {
    emit(SensorLoading());
    try {
      final history = await SensorService.getSensorDataByType(childId, type);
      emit(SensorHistoryLoaded(history));
    } catch (e) {
      emit(SensorError('Failed to load history: $e'));
    }
  }
}

abstract class SensorState {}

class SensorInitial extends SensorState {}
class SensorLoading extends SensorState {}
class SensorLoaded extends SensorState {
  final SensorDataModel data;
  SensorLoaded(this.data);
}
class SensorHistoryLoaded extends SensorState {
  final List<SensorDataModel> history;
  SensorHistoryLoaded(this.history);
}
class ActivityUpdate extends SensorState {
  final dynamic data;
  ActivityUpdate(this.data);
}
class SleepUpdate extends SensorState {
  final dynamic data;
  SleepUpdate(this.data);
}
class SensorError extends SensorState {
  final String message;
  SensorError(this.message);
}