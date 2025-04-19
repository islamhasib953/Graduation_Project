import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:segma/models/doctor_model.dart';
import 'package:segma/models/appointment_model.dart';
import 'package:segma/services/auth_service.dart';

class DoctorService {
  static const String baseUrl = 'https://graduation-projectgmabackend.vercel.app';

  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('Authentication token is missing. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> getDoctors(String childId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/$childId');
      print('DoctorService: Fetching doctors from: $url');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: getDoctors response status: ${response.statusCode}');
      print('DoctorService: getDoctors response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'status': 'fail', 'message': 'No doctors found', 'data': []};
      } else {
        throw Exception('Failed to load doctors: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in getDoctors: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getDoctorDetails(String childId, String doctorId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/$childId/$doctorId');
      print('DoctorService: Fetching doctor details from: $url');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: getDoctorDetails response status: ${response.statusCode}');
      print('DoctorService: getDoctorDetails response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'status': 'fail', 'message': 'Doctor not found', 'data': null};
      } else {
        throw Exception('Failed to load doctor details: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in getDoctorDetails: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getUserAppointments(String childId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/appointments/user/$childId');
      print('DoctorService: Fetching user appointments from: $url');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: getUserAppointments response status: ${response.statusCode}');
      print('DoctorService: getUserAppointments response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'status': 'fail', 'message': 'No appointments found', 'data': {}};
      } else {
        throw Exception('Failed to load appointments: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in getUserAppointments: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> bookAppointment(String childId, String doctorId, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/$childId/$doctorId/book');
      print('DoctorService: Booking appointment at: $url');
      print('DoctorService: Request body: ${jsonEncode(data)}');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: bookAppointment response status: ${response.statusCode}');
      print('DoctorService: bookAppointment response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to book appointment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in bookAppointment: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> rescheduleAppointment(String childId, String appointmentId, Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/appointments/$childId/$appointmentId');
      print('DoctorService: Rescheduling appointment at: $url');
      print('DoctorService: Request body: ${jsonEncode(data)}');
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: rescheduleAppointment response status: ${response.statusCode}');
      print('DoctorService: rescheduleAppointment response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to reschedule appointment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in rescheduleAppointment: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> cancelAppointment(String childId, String appointmentId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/appointments/$childId/$appointmentId');
      print('DoctorService: Cancelling appointment at: $url');
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: cancelAppointment response status: ${response.statusCode}');
      print('DoctorService: cancelAppointment response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to cancel appointment: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in cancelAppointment: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> toggleFavorite(String childId, String doctorId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/$childId/$doctorId/favorite');
      print('DoctorService: Toggling favorite at: $url');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: toggleFavorite response status: ${response.statusCode}');
      print('DoctorService: toggleFavorite response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to toggle favorite: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in toggleFavorite: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> removeFavorite(String childId, String doctorId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/$childId/$doctorId/favorite');
      print('DoctorService: Removing favorite at: $url');
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: removeFavorite response status: ${response.statusCode}');
      print('DoctorService: removeFavorite response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to remove favorite: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in removeFavorite: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getFavoriteDoctors(String childId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/favorites/$childId');
      print('DoctorService: Fetching favorite doctors from: $url');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: getFavoriteDoctors response status: ${response.statusCode}');
      print('DoctorService: getFavoriteDoctors response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'status': 'fail', 'message': 'No favorite doctors found', 'data': []};
      } else {
        throw Exception('Failed to load favorite doctors: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in getFavoriteDoctors: $e');
      rethrow;
    }
  }

  static Future<bool> isDoctorFavorite(String childId, String doctorId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/favorites/$childId');
      print('DoctorService: Checking favorite status at: $url');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: isDoctorFavorite response status: ${response.statusCode}');
      print('DoctorService: isDoctorFavorite response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> favorites = data['data'] ?? [];
        return favorites.any((doctor) => doctor['_id'] == doctorId);
      } else if (response.statusCode == 404) {
        return false;
      } else {
        throw Exception('Failed to check favorite status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in isDoctorFavorite: $e');
      return false;
    }
  }

  static Future<Map<String, dynamic>> getDoctorUpcomingAppointments() async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/appointments/upcoming');
      print('DoctorService: Fetching upcoming appointments from: $url');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: getDoctorUpcomingAppointments response status: ${response.statusCode}');
      print('DoctorService: getDoctorUpcomingAppointments response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'status': 'fail', 'message': 'No upcoming appointments found', 'data': {'doctor': {}, 'appointments': []}};
      } else {
        throw Exception('Failed to load upcoming appointments: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in getDoctorUpcomingAppointments: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateAppointmentStatus(String appointmentId, String newStatus) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/appointments/$appointmentId/status');
      print('DoctorService: Updating appointment status at: $url');
      print('DoctorService: Request body: ${jsonEncode({'status': newStatus})}');
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'status': newStatus}),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: updateAppointmentStatus response status: ${response.statusCode}');
      print('DoctorService: updateAppointmentStatus response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update appointment status: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in updateAppointmentStatus: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateDoctorProfile(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/profile');
      print('DoctorService: Updating doctor profile at: $url');
      print('DoctorService: Request body: ${jsonEncode(data)}');
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: updateDoctorProfile response status: ${response.statusCode}');
      print('DoctorService: updateDoctorProfile response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update doctor profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in updateDoctorProfile: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getDoctorProfile() async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/profile');
      print('DoctorService: Fetching doctor profile from: $url');
      final response = await http.get(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: getDoctorProfile response status: ${response.statusCode}');
      print('DoctorService: getDoctorProfile response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'status': 'fail', 'message': 'Doctor profile not found', 'data': null};
      } else {
        throw Exception('Failed to load doctor profile: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in getDoctorProfile: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> logoutDoctor() async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/logout');
      print('DoctorService: Logging out doctor at: $url');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: logoutDoctor response status: ${response.statusCode}');
      print('DoctorService: logoutDoctor response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to logout doctor: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in logoutDoctor: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getChildRecords(String childId) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/child/records');
      print('DoctorService: Fetching child records from: $url');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: jsonEncode({'childId': childId}),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: getChildRecords response status: ${response.statusCode}');
      print('DoctorService: getChildRecords response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode == 404) {
        return {'status': 'fail', 'message': 'No records found', 'data': {'medicalHistory': [], 'growthRecords': []}};
      } else {
        throw Exception('Failed to load child records: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in getChildRecords: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> deleteDoctorAccount() async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/profile');
      print('DoctorService: Deleting doctor account at: $url');
      final response = await http.delete(
        url,
        headers: await _getHeaders(),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: deleteDoctorAccount response status: ${response.statusCode}');
      print('DoctorService: deleteDoctorAccount response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to delete doctor account: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in deleteDoctorAccount: $e');
      rethrow;
    }
  }


// لإضافة دالة تحديث المواعيد
  static Future<Map<String, dynamic>> updateDoctorAvailability(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl/api/doctors/availability');
      print('DoctorService: Updating availability at: $url');
      print('DoctorService: Request body: ${jsonEncode(data)}');
      final response = await http.patch(
        url,
        headers: await _getHeaders(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10), onTimeout: () {
        throw Exception('Request timed out after 10 seconds');
      });
      print('DoctorService: updateDoctorAvailability response status: ${response.statusCode}');
      print('DoctorService: updateDoctorAvailability response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update availability: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DoctorService: Error in updateDoctorAvailability: $e');
      rethrow;
    }
  }
}
