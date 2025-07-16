import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/memory_model.dart';
import 'package:segma/services/memory_service.dart';
import 'package:flutter/material.dart';

class MemoryCubit extends Cubit<MemoryState> {
  MemoryCubit() : super(MemoryLoaded([])); // بداية مباشرة بقائمة فارغة
  List<Memory> _memories = [];
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isShowingFavorites = false;

  Future<void> init(String childId) async {
    _currentPage = 1;
    _hasMore = true;
    _isShowingFavorites = false;
    await loadMemories(childId);
  }

  Future<void> loadMemories(String childId) async {
    try {
      final newMemories = await MemoryService.getMemories(childId, page: _currentPage);
      _memories = newMemories;
      _hasMore = newMemories.length == 10;
      emit(MemoryLoaded(_memories));
    } catch (e) {
      emit(MemoryError('Failed to load memories: $e'));
    }
  }

  Future<void> loadMoreMemories(String childId) async {
    if (!_hasMore) return;
    try {
      _currentPage++;
      final newMemories = await MemoryService.getMemories(childId, page: _currentPage);
      _memories.addAll(newMemories);
      _hasMore = newMemories.length == 10;
      emit(MemoryLoaded(_memories));
    } catch (e) {
      _currentPage--;
      emit(MemoryError('Failed to load more memories: $e'));
    }
  }

  Future<void> loadFavoriteMemories(String childId) async {
    try {
      final memories = await MemoryService.getFavoriteMemories(childId);
      _memories = memories;
      _isShowingFavorites = true;
      emit(MemoryLoaded(_memories));
    } catch (e) {
      emit(MemoryError('Failed to load favorite memories: $e'));
    }
  }

  Future<void> returnToAllMemories(String childId) async {
    _isShowingFavorites = false;
    await loadMemories(childId);
  }

  Future<void> addMemory(String childId, Memory memory, dynamic image, [BuildContext? context]) async {
    try {
      final result = await MemoryService.addMemory(childId, memory, image);
      if (result['status'] == 'success') {
        final data = result['data'];
        if (data is Map<String, dynamic>) {
          final addedMemory = Memory.fromJson(data);
          _memories.insert(0, addedMemory);
          emit(MemoryLoaded(_memories)); // تحديث فوري
          if (context != null) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'])));
            Navigator.pop(context);
          }
        } else {
          emit(MemoryError('Invalid response format'));
        }
      } else {
        emit(MemoryError(result['message'] ?? 'Failed to add memory'));
      }
    } catch (e) {
      emit(MemoryError('Technical error: Failed to add memory - $e'));
    }
  }

  Future<void> updateMemory(String childId, String memoryId, Map<String, dynamic> updates, dynamic image) async {
    try {
      final updatedMemory = await MemoryService.updateMemory(childId, memoryId, updates, image);
      final index = _memories.indexWhere((m) => m.id == memoryId);
      if (index != -1) _memories[index] = updatedMemory;
      emit(MemoryLoaded(_memories)); // تحديث فوري
      emit(MemorySuccess('Memory updated successfully'));
    } catch (e) {
      emit(MemoryError('Failed to update memory: $e'));
    }
  }

  Future<void> deleteMemory(String childId, String memoryId) async {
    try {
      await MemoryService.deleteMemory(childId, memoryId);
      _memories.removeWhere((m) => m.id == memoryId);
      emit(MemoryLoaded(_memories)); // تحديث فوري
      emit(MemorySuccess('Memory deleted successfully'));
    } catch (e) {
      emit(MemoryError('Failed to delete memory: $e'));
    }
  }

  Future<void> toggleFavorite(String childId, String memoryId) async {
    try {
      final updatedMemory = await MemoryService.toggleFavorite(childId, memoryId);
      final index = _memories.indexWhere((m) => m.id == memoryId);
      if (index != -1) {
        _memories[index] = updatedMemory;
        if (_isShowingFavorites && !updatedMemory.isFavorite) {
          _memories.removeAt(index);
        }
      }
      emit(MemoryLoaded(_memories)); // تحديث فوري
      emit(MemorySuccess(updatedMemory.isFavorite ? 'Added to favorites' : 'Removed from favorites'));
    } catch (e) {
      emit(MemoryError('Failed to toggle favorite: $e'));
    }
  }
}

abstract class MemoryState {}

class MemoryInitial extends MemoryState {}

class MemoryLoaded extends MemoryState {
  final List<Memory> memories;
  MemoryLoaded(this.memories);
}

class MemorySuccess extends MemoryState {
  final String message;
  MemorySuccess(this.message);
}

class MemoryError extends MemoryState {
  final String message;
  MemoryError(this.message);
}