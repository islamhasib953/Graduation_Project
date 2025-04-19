import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/services/history_service.dart';

class HistoryCubit extends Cubit<List<History>> {
  History? _historyToView;
  String? _error;

  HistoryCubit() : super([]);

  Future<void> fetchHistory(String childId) async {
    try {
      final result = await HistoryService.getHistories(childId);
      if (result['status'] == 'success') {
        emit(result['data'] as List<History>);
        _error = null;
      } else {
        _error = result['message'];
        emit([]);
      }
    } catch (e) {
      _error = e.toString();
      emit([]);
    }
  }

  Future<void> addHistory(History history, String childId) async {
    try {
      final result = await HistoryService.addHistory(history, childId);
      if (result['status'] == 'success') {
        final updatedList = List<History>.from(state);
        updatedList.add(result['data'] as History);
        emit(updatedList);
        _error = null;
        await fetchHistory(childId); // Refresh the list
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> updateHistory(History history, String childId) async {
    try {
      final result = await HistoryService.updateHistory(
        childId: childId,
        historyId: history.id,
        history: history,
      );
      if (result['status'] == 'success') {
        final updatedList = List<History>.from(state);
        final index = updatedList.indexWhere((h) => h.id == history.id);
        if (index != -1) {
          updatedList[index] = result['data'] as History;
          emit(updatedList);
        }
        _error = null;
        await fetchHistory(childId); // Refresh the list
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> deleteHistory(int index, String childId) async {
    final history = state[index];
    final historyId = history.id;

    try {
      final result = await HistoryService.deleteHistory(childId, historyId);
      if (result['status'] == 'success') {
        final updatedList = List<History>.from(state);
        updatedList.removeAt(index);
        emit(updatedList);
        _error = null;
        await fetchHistory(childId); // Refresh the list after deletion
      } else {
        _error = result['message'];
      }
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<void> filterHistory({
    required String childId,
    String? diagnosis,
    DateTime? fromDate,
    DateTime? toDate,
    String? sortBy,
  }) async {
    try {
      final result = await HistoryService.filterHistories(
        childId: childId,
        diagnosis: diagnosis,
        fromDate: fromDate,
        toDate: toDate,
        sortBy: sortBy,
      );
      if (result['status'] == 'success') {
        emit(result['data'] as List<History>);
        _error = null;
      } else {
        _error = result['message'];
        emit([]);
      }
    } catch (e) {
      _error = e.toString();
      emit([]);
    }
  }

  void setHistoryToView(History? history) {
    _historyToView = history;
  }

  History? get historyToView => _historyToView;

  String? get error => _error;

  void clearError() {
    _error = null;
  }
}