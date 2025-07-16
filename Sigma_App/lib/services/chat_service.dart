import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:segma/services/auth_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

class ChatService {
  static const String baseUrl = 'http://35.173.178.21:8000'; // نفس الـ URL زي SensorService
  static late IO.Socket socket;
  static ValueNotifier<List<Map<String, dynamic>>> messages = ValueNotifier([]);
  static String? _currentChildId;
  static String? _currentDoctorId;

  static void initializeSocket(String childId, String doctorId) {
    if (_currentChildId == childId && _currentDoctorId == doctorId && socket.connected) {
      print('Already connected to chat room: $childId-$doctorId');
      return;
    }
    _currentChildId = childId;
    _currentDoctorId = doctorId;

    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      print('Connected to WebSocket server for chat');
      socket.emit('joinRoom', {'childId': childId, 'doctorId': doctorId});
    });

    socket.on('newMessage', (data) {
      print('Received new message: $data');
      if (data is Map<String, dynamic>) {
        final List<Map<String, dynamic>> updatedMessages = List.from(messages.value);
        updatedMessages.add(data);
        messages.value = updatedMessages;
      } else {
        print('Invalid message format: $data');
      }
    });

    socket.on('connect_error', (error) {
      print('WebSocket connection error: $error');
    });

    socket.on('disconnect', (_) {
      print('WebSocket disconnected for room: $childId-$doctorId');
    });

    socket.connect();
  }

  static Future<void> sendMessage(String childId, String doctorId, String message, {XFile? file, String sender = 'child'}) async {
    if (childId.isEmpty || doctorId.isEmpty || !socket.connected) {
      print('Error: Invalid IDs or not connected. Status: ${socket.connected}');
      if (!socket.connected) initializeSocket(childId, doctorId); // إعادة الاتصال
      return;
    }

    try {
      if (file != null) {
        var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/api/chats/$childId/$doctorId/upload'))
          ..headers.addAll({'Authorization': 'Bearer ${await AuthService.getToken()}'});

        dynamic uploadData;
        if (file.path.startsWith('blob:')) {
          final blob = html.window.document.getElementById(file.path.split('/').last) as html.Blob?;
          if (blob != null) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(blob);
            await reader.onLoad.first;
            uploadData = reader.result as Uint8List;
          }
        } else {
          uploadData = File(file.path);
        }

        if (uploadData is File) {
          request.files.add(await http.MultipartFile.fromPath('media', uploadData.path));
        } else if (uploadData is Uint8List) {
          request.files.add(http.MultipartFile.fromBytes('media', uploadData, filename: 'uploaded_image.jpg'));
        }

        final response = await request.send();
        final resp = await response.stream.bytesToString();
        if (response.statusCode == 200) {
          final data = jsonDecode(resp);
          final mediaUrl = data['data']?['mediaUrl'];
          if (mediaUrl != null) {
            final messageData = {
              'childId': childId,
              'doctorId': doctorId,
              'sender': sender,
              'media': mediaUrl,
              'timestamp': DateTime.now().toIso8601String(),
            };
            socket.emit('sendMessage', messageData);
            _updateLocalMessages(messageData);
          }
        }
      } else if (message.isNotEmpty) {
        final messageData = {
          'childId': childId,
          'doctorId': doctorId,
          'sender': sender,
          'content': message,
          'timestamp': DateTime.now().toIso8601String(),
        };
        socket.emit('sendMessage', messageData);
        _updateLocalMessages(messageData);
      }
    } catch (e) {
      print('Send message error: $e');
    }
  }

  // استبدال getMessages باستخدام ValueNotifier مباشرة
  static ValueNotifier<List<Map<String, dynamic>>> getMessagesNotifier() {
    return messages;
  }

  static void disconnect() {
    socket.disconnect();
    _currentChildId = null;
    _currentDoctorId = null;
    print('Disconnected from WebSocket');
  }

  static Future<List<Map<String, dynamic>>> getChatHistory(String childId, String doctorId) async {
    if (childId.isEmpty || doctorId.isEmpty) {
      print('Error: childId or doctorId is empty');
      return [];
    }
    try {
      final token = await AuthService.getToken();
      if (token == null) {
        print('Error: No token available for fetching history');
        return [];
      }
      final response = await http.get(
        Uri.parse('$baseUrl/api/chats/$childId/$doctorId/history'),
        headers: {'Authorization': 'Bearer $token'},
      );
      print('History API response status: ${response.statusCode}, Body: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'success' && data['data'] != null && data['data']['messages'] != null) {
          return List<Map<String, dynamic>>.from(data['data']['messages']);
        }
      }
      return [];
    } catch (e) {
      print('History fetch error: $e');
      return [];
    }
  }

  static void _updateLocalMessages(Map<String, dynamic> message) {
    final List<Map<String, dynamic>> updatedMessages = List<Map<String, dynamic>>.from(messages.value); // تحديد النوع صراحة
    updatedMessages.add(message);
    messages.value = updatedMessages;
  }
}