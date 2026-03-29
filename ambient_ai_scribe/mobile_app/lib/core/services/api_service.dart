import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

class ApiService {
  Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}/api/health'),
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
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}/api/consultations'),
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