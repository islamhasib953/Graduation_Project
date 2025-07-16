import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segma/models/memory_model.dart';
import 'package:segma/services/auth_service.dart';
import 'package:flutter/foundation.dart';
import 'package:universal_io/io.dart' as io;

class MemoryService {
  static const String baseUrl = 'http://35.173.178.21:8000/api';

  static Future<List<Memory>> getMemories(String childId, {int page = 1, int limit = 10}) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/memory/$childId?page=$page&limit=$limit');
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

  static Future<List<Memory>> getFavoriteMemories(String childId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/memory/favorites/$childId');
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

  static Future<Map<String, dynamic>> addMemory(String childId, Memory memory, dynamic image) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        return {'status': 'error', 'message': 'You must log in'};
      }

      var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/memory/$childId'))
        ..headers.addAll(await AuthService.getHeaders(token))
        ..fields['description'] = memory.description
        ..fields['date'] = memory.date.toIso8601String()
        ..fields['time'] = memory.time
        ..fields['isFavorite'] = memory.isFavorite.toString();

      if (image != null) {
        if (kIsWeb && image is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes('image', image, filename: 'memory_${DateTime.now().millisecondsSinceEpoch}.jpg'));
        } else if (image is io.File) {
          request.files.add(await http.MultipartFile.fromPath('image', image.path));
        }
      }

      print('\n📤 Add Memory Request:');
      print('├─ URL: ${request.url}');
      print('├─ Headers: ${request.headers}');
      print('└─ Fields: ${request.fields}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('\n📥 Add Memory Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(responseBody);
        if (data['status'] == 'success') {
          print('✅ Successfully added memory: ${data['data']['_id']}');
          return {
            'status': 'success',
            'message': 'Memory added successfully',
            'data': data['data'],
          };
        }
        return {'status': 'error', 'message': data['message'] ?? 'Failed to add memory'};
      }
      return {'status': 'error', 'message': 'Failed to add memory: ${response.statusCode}'};
    } catch (e) {
      return {'status': 'error', 'message': 'Technical error: Failed to add memory - $e'};
    }
  }

  static Future<Memory> updateMemory(String childId, String memoryId, Map<String, dynamic> updates, dynamic image) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No token found. Please log in again.');
      final url = Uri.parse('$baseUrl/memory/$childId/$memoryId');
      var request = http.MultipartRequest('PATCH', url)
        ..headers.addAll(await AuthService.getHeaders(token))
        ..fields['description'] = updates['description']
        ..fields['isFavorite'] = updates['isFavorite'].toString();

      if (image != null) {
        if (kIsWeb && image is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes('image', image, filename: 'memory_${DateTime.now().millisecondsSinceEpoch}.jpg'));
        } else if (image is io.File) {
          request.files.add(await http.MultipartFile.fromPath('image', image.path));
        }
      } else if (updates['image'] != null && updates['image'].isNotEmpty) {
        request.fields['image'] = updates['image'];
      }

      print('\n📤 Update Memory Request:');
      print('├─ URL: ${request.url}');
      print('├─ Headers: ${request.headers}');
      print('├─ Child ID: $childId');
      print('├─ Memory ID: $memoryId');
      print('└─ Fields: ${request.fields}');

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();
      print('\n📥 Update Memory Response:');
      print('├─ Status: ${response.statusCode}');
      print('└─ Body: $responseBody');

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
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

  static Future<void> deleteMemory(String childId, String memoryId) async {
    try {
      final token = await AuthService.getToken();
      if (token == null) throw Exception('No token found. Please log in again.');
      final url = Uri.parse('$baseUrl/memory/$childId/$memoryId');
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

  static Future<Memory> toggleFavorite(String childId, String memoryId) async {
    final token = await AuthService.getToken();
    final url = Uri.parse('$baseUrl/memory/favorites/$childId/$memoryId');
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