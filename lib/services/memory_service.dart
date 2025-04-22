import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segma/models/memory_model.dart';
import 'package:segma/services/auth_service.dart';

class MemoryService {
  // جلب كل الـ Memories مع Pagination
  static Future<List<Memory>> getMemories(String childId, {int page = 1, int limit = 10}) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${AuthService.baseUrl}/memory/$childId?page=$page&limit=$limit');
    final headers = await AuthService.getHeaders(token);
    print('\n📤 Get Memories Request:');
    print('├─ URL: $url');
    print('└─ Headers: $headers');

    final response = await http.get(url, headers: headers);
    print('\n📥 Get Memories Response:');
    print('├─ Status: ${response.statusCode}');
    print('└─ Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['data'] as List).map((json) => Memory.fromJson(json)).toList();
      }
      throw Exception('Failed to load memories: ${data['message']}');
    }
    throw Exception('Failed to load memories: ${response.statusCode}');
  }

  // جلب الـ Memories المفضلة
  static Future<List<Memory>> getFavoriteMemories(String childId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${AuthService.baseUrl}/memory/favorites/$childId');
    final headers = await AuthService.getHeaders(token);
    print('\n📤 Get Favorite Memories Request:');
    print('├─ URL: $url');
    print('└─ Headers: $headers');

    final response = await http.get(url, headers: headers);
    print('\n📥 Get Favorite Memories Response:');
    print('├─ Status: ${response.statusCode}');
    print('└─ Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return (data['data'] as List).map((json) => Memory.fromJson(json)).toList();
      }
      throw Exception('Failed to load favorite memories: ${data['message']}');
    }
    throw Exception('Failed to load favorite memories: ${response.statusCode}');
  }

  // إضافة Memory جديدة
  static Future<Memory> addMemory(String childId, Memory memory) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${AuthService.baseUrl}/memory/$childId');
    final headers = await AuthService.getHeaders(token);
    print('\n📤 Add Memory Request:');
    print('├─ URL: $url');
    print('├─ Headers: $headers');
    print('└─ Body: ${jsonEncode(memory.toJson())}');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(memory.toJson()),
    );
    print('\n📥 Add Memory Response:');
    print('├─ Status: ${response.statusCode}');
    print('└─ Body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return Memory.fromJson(data['data']);
      }
      throw Exception('Failed to add memory: ${data['message']}');
    }
    throw Exception('Failed to add memory: ${response.statusCode}');
  }

  // تعديل Memory
  static Future<Memory> updateMemory(String childId, String memoryId, Map<String, dynamic> updates) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. Please log in again.');
      }
      final url = Uri.parse('${AuthService.baseUrl}/memory/$childId/$memoryId');
      final headers = await AuthService.getHeaders(token);
      print('\n📤 Update Memory Request:');
      print('├─ URL: $url');
      print('├─ Headers: $headers');
      print('├─ Child ID: $childId');
      print('├─ Memory ID: $memoryId');
      print('└─ Body: ${jsonEncode(updates)}');

      final response = await http.patch(
        url,
        headers: headers,
        body: jsonEncode(updates),
      );
      print('\n📥 Update Memory Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print('✅ Successfully updated memory: ${data['data']['_id']}');
          return Memory.fromJson(data['data']);
        }
        throw Exception('Failed to update memory: ${data['message']}');
      }
      throw Exception('Failed to update memory: ${response.statusCode}');
    } catch (e) {
      print('🔥 Update Memory Error: $e');
      rethrow;
    }
  }

  // حذف Memory
  static Future<void> deleteMemory(String childId, String memoryId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('No token found. Please log in again.');
      }
      final url = Uri.parse('${AuthService.baseUrl}/memory/$childId/$memoryId');
      final headers = await AuthService.getHeaders(token);
      print('\n📤 Delete Memory Request:');
      print('├─ URL: $url');
      print('├─ Headers: $headers');
      print('├─ Child ID: $childId');
      print('└─ Memory ID: $memoryId');

      final response = await http.delete(url, headers: headers);
      print('\n📥 Delete Memory Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success') {
          print('✅ Successfully deleted memory');
          return;
        }
        throw Exception('Failed to delete memory: ${data['message']}');
      }
      throw Exception('Failed to delete memory: ${response.statusCode}');
    } catch (e) {
      print('🔥 Delete Memory Error: $e');
      rethrow;
    }
  }

  // تبديل حالة المفضلة
  static Future<Memory> toggleFavorite(String childId, String memoryId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('${AuthService.baseUrl}/memory/favorites/$childId/$memoryId');
    final headers = await AuthService.getHeaders(token);
    print('\n📤 Toggle Favorite Request:');
    print('├─ URL: $url');
    print('└─ Headers: $headers');

    final response = await http.patch(url, headers: headers);
    print('\n📥 Toggle Favorite Response:');
    print('├─ Status: ${response.statusCode}');
    print('└─ Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        return Memory.fromJson(data['data']);
      }
      throw Exception('Failed to toggle favorite: ${data['message']}');
    }
    throw Exception('Failed to toggle favorite: ${response.statusCode}');
  }
}