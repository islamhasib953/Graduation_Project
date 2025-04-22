import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/memory_model.dart';
import 'package:segma/services/memory_service.dart';

class MemoryCubit extends Cubit<MemoryState> {
  MemoryCubit() : super(MemoryInitial());
  List<Memory> _memories = []; // لتخزين الذكريات محليًا
  int _currentPage = 1;
  bool _hasMore = true; // للتحقق إذا كان فيه ذكريات أكتر للتحميل

  Future<void> init(String childId) async {
    await loadMemories(childId);
  }

  Future<void> loadMemories(String childId) async {
    try {
      emit(MemoryLoading());
      print('Loading memories for childId: $childId, page: $_currentPage');
      final newMemories = await MemoryService.getMemories(childId, page: _currentPage);
      print('Loaded memories: ${newMemories.length} items');
      newMemories.forEach((memory) => print('Memory: ${memory.description}, ID: ${memory.id}'));
      _memories = newMemories; // Reset the list for the first page
      _hasMore = newMemories.length == 10; // Assuming limit is 10, adjust based on backend
      emit(MemoryLoaded(_memories));
    } catch (e) {
      print('Error loading memories: $e');
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> loadMoreMemories(String childId) async {
    if (!_hasMore) return;
    try {
      _currentPage++;
      print('Loading more memories for childId: $childId, page: $_currentPage');
      final newMemories = await MemoryService.getMemories(childId, page: _currentPage);
      print('Loaded more memories: ${newMemories.length} items');
      newMemories.forEach((memory) => print('Memory: ${memory.description}, ID: ${memory.id}'));
      _memories.addAll(newMemories);
      _hasMore = newMemories.length == 10; // Assuming limit is 10
      emit(MemoryLoaded(_memories));
    } catch (e) {
      print('Error loading more memories: $e');
      _currentPage--; // Revert page if failed
      emit(MemoryError('فشل في تحميل المزيد من الذكريات: $e'));
    }
  }

  Future<void> loadFavoriteMemories(String childId) async {
    try {
      emit(MemoryLoading());
      print('Loading favorite memories for childId: $childId');
      final memories = await MemoryService.getFavoriteMemories(childId);
      print('Loaded favorite memories: ${memories.length} items');
      memories.forEach((memory) => print('Favorite Memory: ${memory.description}, ID: ${memory.id}'));
      emit(MemoryLoaded(memories));
    } catch (e) {
      print('Error loading favorite memories: $e');
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> addMemory(String childId, Memory memory) async {
    try {
      emit(MemoryLoading());
      print('Adding memory for childId: $childId, Description: ${memory.description}');
      final addedMemory = await MemoryService.addMemory(childId, memory);
      print('Memory added successfully: ${addedMemory.id}');
      _memories.add(addedMemory); // إضافة الذكرى محليًا
      print('Updated memories: ${_memories.length} items');
      _memories.forEach((memory) => print('Memory: ${memory.description}, ID: ${memory.id}'));
      emit(MemoryLoaded(_memories));
      emit(MemorySuccess('Memory added successfully'));
    } catch (e) {
      print('Error adding memory: $e');
      emit(MemoryError(e.toString()));
    }
  }

  Future<void> updateMemory(String childId, String memoryId, Map<String, dynamic> updates) async {
    try {
      emit(MemoryLoading());
      print('Updating memory: $memoryId for childId: $childId');
      print('Updates: $updates');
      final updatedMemory = await MemoryService.updateMemory(childId, memoryId, updates);
      print('Memory updated successfully: ${updatedMemory.id}');
      // تحديث الذكرى محليًا
      final index = _memories.indexWhere((m) => m.id == memoryId);
      if (index != -1) {
        _memories[index] = updatedMemory;
      }
      print('Updated memories: ${_memories.length} items');
      _memories.forEach((memory) => print('Memory: ${memory.description}, ID: ${memory.id}'));
      emit(MemoryLoaded(_memories));
      emit(MemorySuccess('تم تعديل الذكرى بنجاح'));
    } catch (e) {
      print('Error updating memory: $e');
      emit(MemoryError('فشل في تعديل الذكرى: $e'));
    }
  }

  Future<void> deleteMemory(String childId, String memoryId) async {
    try {
      emit(MemoryLoading());
      print('Deleting memory: $memoryId for childId: $childId');
      await MemoryService.deleteMemory(childId, memoryId);
      print('Memory deleted successfully');
      // حذف الذكرى محليًا
      _memories.removeWhere((m) => m.id == memoryId);
      print('Updated memories: ${_memories.length} items');
      _memories.forEach((memory) => print('Memory: ${memory.description}, ID: ${memory.id}'));
      emit(MemoryLoaded(_memories));
      emit(MemorySuccess('تم حذف الذكرى بنجاح'));
    } catch (e) {
      print('Error deleting memory: $e');
      emit(MemoryError('فشل في حذف الذكرى: $e'));
    }
  }

  Future<void> toggleFavorite(String childId, String memoryId) async {
    try {
      emit(MemoryLoading());
      print('Toggling favorite for memory: $memoryId for childId: $childId');
      final updatedMemory = await MemoryService.toggleFavorite(childId, memoryId);
      print('Favorite toggled successfully: ${updatedMemory.id}, isFavorite: ${updatedMemory.isFavorite}');
      // تحديث الذكرى محليًا
      final index = _memories.indexWhere((m) => m.id == memoryId);
      if (index != -1) {
        _memories[index] = updatedMemory;
      }
      print('Updated memories: ${_memories.length} items');
      _memories.forEach((memory) => print('Memory: ${memory.description}, ID: ${memory.id}'));
      emit(MemoryLoaded(_memories));
      emit(MemorySuccess(updatedMemory.isFavorite ? 'تمت الإضافة إلى المفضلة' : 'تمت الإزالة من المفضلة'));
    } catch (e) {
      print('Error toggling favorite: $e');
      emit(MemoryError('فشل في تبديل المفضلة: $e'));
    }
  }
}

abstract class MemoryState {}

class MemoryInitial extends MemoryState {}

class MemoryLoading extends MemoryState {}

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