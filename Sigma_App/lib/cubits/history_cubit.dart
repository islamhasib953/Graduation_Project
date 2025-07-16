import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/history_model.dart';
import 'package:segma/services/history_service.dart';
import 'package:segma/cubits/history_state.dart';
import 'package:flutter/foundation.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(HistoryInitial());

  String? childId;

  Future<void> initialize({required String childId}) async {
    this.childId = childId;
    await fetchHistory(childId);
  }

  Future<void> fetchHistory(String childId) async {
    try {
      emit(HistoryLoading());
      final result = await HistoryService.getHistories(childId).timeout(const Duration(seconds: 10), onTimeout: () {
        return {'status': 'error', 'message': 'Request timed out'};
      });
      if (result['status'] == 'success') {
        final data = result['data'];
        if (data is List) {
          final histories = data.map((h) {
            if (h is Map<String, dynamic>) {
              try {
                return History.fromJson(h);
              } catch (e) {
                print('Error parsing history item: $e, Item: $h');
                return null;
              }
            }
            return null;
          }).whereType<History>().toList();
          emit(HistoryLoaded(histories));
        } else {
          emit(HistoryError('Invalid data format: Expected a list'));
        }
      } else {
        emit(HistoryError(result['message'] ?? 'Failed to fetch records'));
      }
    } catch (e) {
      emit(HistoryError('Technical error: Failed to fetch history - $e'));
    }
  }

  Future<void> addHistory(History history, String childId, [dynamic image, BuildContext? context]) async {
    try {
      emit(HistoryLoading());
      final result = await HistoryService.addHistory(history, childId, image).timeout(const Duration(seconds: 10), onTimeout: () {
        return {'status': 'error', 'message': 'Request timed out'};
      });
      if (result['status'] == 'success') {
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          final addedHistory = History.fromJson(data);
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('History record added successfully')),
            );
            Navigator.pop(context);
          }
          await fetchHistory(childId);
        } else {
          emit(HistoryError('Invalid response format'));
        }
      } else {
        emit(HistoryError(result['message'] ?? 'Failed to add history'));
      }
    } catch (e) {
      emit(HistoryError('Technical error: Failed to add history'));
    }
  }

  Future<Map<String, dynamic>> updateHistory(History history, String childId, [dynamic image]) async {
    try {
      print('Starting updateHistory for historyId: ${history.id}');
      emit(HistoryLoading());
      if (!RegExp(r'^(0[0-9]|1[0-9]|2[0-3]):[0-5][0-9]\s?(AM|PM|am|pm)?$').hasMatch(history.time)) {
        emit(HistoryError('Invalid time format. Use HH:mm AM/PM (e.g., 08:00 PM)'));
        return {'status': 'error', 'message': 'Invalid time format'};
      }
      final result = await HistoryService.updateHistory(
        childId: childId,
        historyId: history.id,
        history: history,
        image: image is File ? image : (image is Uint8List ? image : null),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        return {'status': 'error', 'message': 'Request timed out'};
      });
      print('UpdateHistory response: $result');
      if (result['status'] == 'success') {
        final updatedHistoryData = result['data'];
        if (updatedHistoryData is Map<String, dynamic>) {
          try {
            final updatedHistory = History.fromJson(updatedHistoryData);
            if (state is HistoryLoaded) {
              final updatedList = List<History>.from((state as HistoryLoaded).histories);
              final index = updatedList.indexWhere((h) => h.id == history.id);
              if (index != -1) {
                updatedList[index] = updatedHistory;
                emit(HistoryUpdated(updatedList));
              }
            }
          } catch (e) {
            print('Error parsing updated history: $e');
          }
        }
        await fetchHistory(childId);
        emit(HistoryUpdated((state as HistoryLoaded).histories)); // Ensure state update
        return result;
      } else {
        emit(HistoryError(result['message'] ?? 'Failed to update record'));
        return result;
      }
    } catch (e) {
      print('UpdateHistory error: $e');
      emit(HistoryError('Technical error: Failed to update history - $e'));
      return {'status': 'error', 'message': 'Technical error: $e'};
    }
  }

  Future<void> deleteHistory(int index, String childId) async {
    if (state is! HistoryLoaded) return;
    final history = (state as HistoryLoaded).histories[index];
    final historyId = history.id;

    try {
      emit(HistoryLoading());
      final result = await HistoryService.deleteHistory(childId, historyId).timeout(const Duration(seconds: 10), onTimeout: () {
        return {'status': 'error', 'message': 'Request timed out'};
      });
      if (result['status'] == 'success') {
        final updatedList = List<History>.from((state as HistoryLoaded).histories);
        updatedList.removeAt(index);
        emit(HistoryLoaded(updatedList));
        await fetchHistory(childId);
      } else {
        emit(HistoryError(result['message'] ?? 'Failed to delete record'));
      }
    } catch (e) {
      emit(HistoryError('Technical error: Failed to delete history - $e'));
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
      emit(HistoryLoading());
      final result = await HistoryService.filterHistories(
        childId: childId,
        diagnosis: diagnosis,
        fromDate: fromDate,
        toDate: toDate,
        sortBy: sortBy,
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        return {'status': 'error', 'message': 'Request timed out'};
      });
      if (result['status'] == 'success') {
        final data = result['data'];
        if (data is List) {
          final histories = data.map((h) {
            if (h is Map<String, dynamic>) {
              try {
                return History.fromJson(h);
              } catch (e) {
                print('Error parsing history item: $e, Item: $h');
                return null;
              }
            }
            return null;
          }).whereType<History>().toList();
          emit(HistoryLoaded(histories));
        } else {
          emit(HistoryError('Failed to filter history'));
        }
      } else {
        emit(HistoryError(result['message'] ?? 'Failed to filter records'));
      }
    } catch (e) {
      emit(HistoryError('Technical error: Failed to filter history'));
    }
  }

  void setHistoryToView(History? history) {
    if (state is HistoryLoaded) {
      emit(HistoryViewUpdated(
        historyToView: history,
        histories: (state as HistoryLoaded).histories,
      ));
    } else if (state is HistoryUpdated) {
      emit(HistoryViewUpdated(
        historyToView: history,
        histories: (state as HistoryUpdated).histories,
      ));
    }
  }

  History? get historyToView {
    if (state is HistoryViewUpdated) return (state as HistoryViewUpdated).historyToView;
    if (state is HistoryLoaded) return (state as HistoryLoaded).historyToView;
    if (state is HistoryUpdated) return (state as HistoryUpdated).historyToView;
    return null;
  }

  void clearError() {
    if (state is HistoryError && state.histories.isNotEmpty) {
      emit(HistoryLoaded(state.histories));
    } else if (state is HistoryError) {
      emit(HistoryLoaded([]));
    }
  }
}