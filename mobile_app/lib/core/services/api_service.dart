import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  // Debug log for API base URL resolution
  static final String _resolvedBaseUrl = AppConstants.apiBaseUrl;
  
  static void _logBaseUrl() {
    print('Resolved API Base URL: $_resolvedBaseUrl');
  }

  Future<Map<String, dynamic>> checkHealth() async {
    _logBaseUrl();
    try {
      final response = await http.get(
        Uri.parse('$_resolvedBaseUrl/api/health'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to check health: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Health check failed: $e');
    }
  }

  Future<Map<String, dynamic>> createConsultation(Map<String, dynamic> data) async {
    _logBaseUrl();
    try {
      print("🌐 URL: $_resolvedBaseUrl/api/consultations");
      print("📤 Payload: $data");

      final response = await http.post(
        Uri.parse('$_resolvedBaseUrl/api/consultations'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to create consultation: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Consultation creation failed: $e');
    }
  }
}