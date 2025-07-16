import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:segma/models/sensor_data_model.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'package:segma/services/auth_service.dart'; // Import AuthService

class SensorService {
  static const String baseUrl = 'http://35.173.178.21:8000';
  static late IO.Socket socket;
  static ValueNotifier<SensorDataModel?> latestSensorData = ValueNotifier(null);
  static ValueNotifier<dynamic> latestActivityData = ValueNotifier(null); // لـ BabyActivity
  static ValueNotifier<dynamic> latestSleepData = ValueNotifier(null); // لـ SleepQuality

  static void initializeSocket(String childId) {
    socket = IO.io(baseUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.on('connect', (_) {
      print('Connected to WebSocket server');
      socket.emit('joinRoom', childId);
    });

    socket.on('validatedSensorData', (data) {
      print('Received validated sensor data: $data');
      latestSensorData.value = SensorDataModel.fromJson(data);
    });

    socket.on('babyActivityUpdate', (data) {
      print('Received baby activity data: $data');
      latestActivityData.value = data;
    });

    socket.on('sleepQualityUpdate', (data) {
      print('Received sleep quality data: $data');
      latestSleepData.value = data;
    });

    socket.on('connect_error', (error) {
      print('WebSocket connection error: $error');
    });

    socket.connect();
  }

  static Future<List<SensorDataModel>> getSensorDataHistory(String childId) async {
    final url = Uri.parse('$baseUrl/api/sensor-data/$childId');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => SensorDataModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load sensor data history');
    }
  }

  static Future<List<SensorDataModel>> getSensorDataByType(String childId, String type) async {
    final url = Uri.parse('$baseUrl/api/sensor-data/$childId/$type');
    final response = await http.get(url, headers: await _getHeaders());

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body)['data'];
      return data.map((json) => SensorDataModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load $type data');
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final String? token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}