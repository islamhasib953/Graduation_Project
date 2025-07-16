
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:segma/models/medication_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:segma/services/auth_service.dart';

class MedicationCubit extends Cubit<List<Medication>> {
  Medication? _medicationToEdit;
  String? _error;
  static const String baseUrl = 'https://graduation-projectgmabackend.vercel.app/api';

  MedicationCubit() : super([]);

  Future<void> fetchMedications(String childId) async {
    try {
      final headers = await AuthService.getHeaders();
      print('📋 Headers for Fetch Medications: $headers');
      if (!headers.containsKey('Authorization')) {
        _error = 'Authentication token not found. Please log in again.';
        emit([]);
        return;
      }

      final response = await http.get(
        Uri.parse('$baseUrl/medicines/$childId'),
        headers: headers,
      );

      print('Fetch Medications Response: ${response.statusCode} - ${response.body}');
      print('Child ID: $childId');

      if (response.statusCode == 200) {
        // تحويل الـ response body لـ Map<String, dynamic>
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        // استخراج الـ List<dynamic> من مفتاح "data"
        final List<dynamic> data = responseData['data'] ?? [];
        // تحويل الـ List<dynamic> لـ List<Medication>
        final medications = data.map((json) => Medication.fromJson(json)).toList();
        emit(medications);
        _error = null;
      } else {
        _error = 'Failed to fetch medications: ${response.statusCode} - ${response.body}';
        emit([]);
      }
    } catch (e) {
      _error = e.toString();
      emit([]);
      print('Error fetching medications: $e');
    }
  }

  Future<void> addMedication(Medication medication, {required String childId}) async {
    try {
      final headers = await AuthService.getHeaders();
      print('📋 Headers for Add Medication: $headers');
      if (!headers.containsKey('Authorization')) {
        _error = 'Authentication token not found. Please log in again.';
        return;
      }

      final response = await http.post(
        Uri.parse('$baseUrl/medicines/$childId'),
        headers: headers,
        body: jsonEncode({
          'name': medication.name,
          'description': medication.description,
          'days': medication.days,
          'times': medication.times.map((time) => time.toIso8601String()).toList(),
          'date': medication.date.toIso8601String(),
        }),
      );

      print('Add Medication Response: ${response.statusCode} - ${response.body}');
      print('Child ID: $childId');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final updatedList = List<Medication>.from(state);
        final newMedication = Medication(
          id: jsonDecode(response.body)['_id'] ?? '',
          name: medication.name,
          description: medication.description,
          days: medication.days,
          times: medication.times,
          date: medication.date,
        );
        updatedList.add(newMedication);
        emit(updatedList);
        _error = null;
      } else {
        _error = 'Failed to add medication: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      _error = e.toString();
      print('Error adding medication: $e');
    }
  }

  Future<void> deleteMedication(int index, {String? childId}) async {
    if (childId == null || childId.isEmpty) {
      _error = 'Child ID is required to delete medication';
      return;
    }

    final medication = state[index];
    final medicineId = medication.id;

    try {
      final headers = await AuthService.getHeaders();
      print('📋 Headers for Delete Medication: $headers');
      if (!headers.containsKey('Authorization')) {
        _error = 'Authentication token not found. Please log in again.';
        return;
      }

      final response = await http.delete(
        Uri.parse('$baseUrl/medicines/$childId/$medicineId'),
        headers: headers,
      );

      print('Delete Medication Response: ${response.statusCode} - ${response.body}');
      print('Child ID: $childId');

      if (response.statusCode == 200 || response.statusCode == 204) {
        final updatedList = List<Medication>.from(state);
        updatedList.removeAt(index);
        emit(updatedList);
        _error = null;
      } else {
        _error = 'Failed to delete medication: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      _error = e.toString();
      print('Error deleting medication: $e');
    }
  }

  Future<void> updateMedication(int index, Medication updatedMedication, {required String childId}) async {
    final medicineId = state[index].id;

    try {
      final headers = await AuthService.getHeaders();
      print('📋 Headers for Update Medication: $headers');
      if (!headers.containsKey('Authorization')) {
        _error = 'Authentication token not found. Please log in again.';
        return;
      }

      final response = await http.patch(
        Uri.parse('$baseUrl/medicines/$childId/$medicineId'),
        headers: headers,
        body: jsonEncode({
          'name': updatedMedication.name,
          'description': updatedMedication.description,
          'days': updatedMedication.days,
          'times': updatedMedication.times.map((time) => time.toIso8601String()).toList(),
          'date': updatedMedication.date.toIso8601String(),
        }),
      );

      print('Update Medication Response: ${response.statusCode} - ${response.body}');
      print('Child ID: $childId');

      if (response.statusCode == 200) {
        final updatedList = List<Medication>.from(state);
        updatedList[index] = updatedMedication;
        emit(updatedList);
        _medicationToEdit = null;
        _error = null;
      } else {
        _error = 'Failed to update medication: ${response.statusCode} - ${response.body}';
      }
    } catch (e) {
      _error = e.toString();
      print('Error updating medication: $e');
    }
  }

  void setMedicationToEdit(Medication? medication) {
    _medicationToEdit = medication;
  }

  Medication? get medicationToEdit => _medicationToEdit;

  String? get error => _error;

  void clearError() {
    _error = null;
  }
}