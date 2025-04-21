import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:segma/models/growth_model.dart';
import 'package:segma/services/growth_service.dart';

part 'growth_state.dart';

class GrowthCubit extends Cubit<GrowthState> {
  final GrowthService growthService;
  String? childId;

  GrowthCubit({
    required this.growthService,
  }) : super(GrowthInitial());

  Future<void> initialize({required String childId}) async {
    this.childId = childId;
    await fetchAllGrowthRecords();
  }

  Future<void> fetchAllGrowthRecords() async {
    if (childId == null) {
      emit(GrowthError(message: 'Child ID not initialized'));
      return;
    }

    try {
      emit(GrowthLoading());
      final records = await growthService.getAllGrowthRecords(childId!);
      final lastRecord = await growthService.getLastGrowthRecord(childId!);
      final changes = await growthService.getGrowthChanges(childId!);
      emit(GrowthLoaded(
        records: records,
        lastRecord: lastRecord,
        changes: changes,
      ));
    } catch (e) {
      emit(GrowthError(message: e.toString()));
    }
  }

  Future<void> addGrowthRecord(Map<String, dynamic> data) async {
    if (childId == null) {
      emit(GrowthError(message: 'Child ID not initialized'));
      return;
    }

    try {
      emit(GrowthLoading());
      await growthService.addGrowthRecord(childId!, data);
      final records = await growthService.getAllGrowthRecords(childId!);
      final lastRecord = await growthService.getLastGrowthRecord(childId!);
      final changes = await growthService.getGrowthChanges(childId!);
      emit(GrowthLoaded(
        records: records,
        lastRecord: lastRecord,
        changes: changes,
      ));
    } catch (e) {
      emit(GrowthError(message: e.toString()));
    }
  }

  Future<void> updateGrowthRecord(String growthId, Map<String, dynamic> data) async {
    if (childId == null) {
      emit(GrowthError(message: 'Child ID not initialized'));
      return;
    }

    try {
      emit(GrowthLoading());
      await growthService.updateGrowthRecord(childId!, growthId, data);
      final records = await growthService.getAllGrowthRecords(childId!);
      final lastRecord = await growthService.getLastGrowthRecord(childId!);
      final changes = await growthService.getGrowthChanges(childId!);
      emit(GrowthLoaded(
        records: records,
        lastRecord: lastRecord,
        changes: changes,
      ));
    } catch (e) {
      emit(GrowthError(message: e.toString()));
    }
  }

  Future<void> deleteGrowthRecord(String growthId) async {
    if (childId == null) {
      emit(GrowthError(message: 'Child ID not initialized'));
      return;
    }

    try {
      emit(GrowthLoading());
      await growthService.deleteGrowthRecord(childId!, growthId);
      final records = await growthService.getAllGrowthRecords(childId!);
      final lastRecord = await growthService.getLastGrowthRecord(childId!);
      final changes = await growthService.getGrowthChanges(childId!);
      emit(GrowthLoaded(
        records: records,
        lastRecord: lastRecord,
        changes: changes,
      ));
    } catch (e) {
      emit(GrowthError(message: e.toString()));
    }
  }
}