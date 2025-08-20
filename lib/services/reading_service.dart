import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:m18_residences_admin/models/reading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReadingService {
  static final String baseUrl = '${dotenv.env['API_URL']}/electricity-readings';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<List<Reading>> fetchReadings() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: await _getAuthHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Reading.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load readings: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching readings: $e');
      rethrow;
    }
  }

  Future<Reading> createReading({required int roomId, required int tenantId, required int prevReading, required int currReading}) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getAuthHeaders(),
        body: json.encode({'room_id': roomId, 'tenant_id': tenantId, 'prev_reading': prevReading, 'curr_reading': currReading}),
      );

      if (response.statusCode == 201) {
        return Reading.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create reading: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating reading: $e');
      rethrow;
    }
  }

  Future<Reading> updateReading({
    required int id,
    required int roomId,
    required int tenantId,
    required int prevReading,
    required int currReading,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
        body: json.encode({'room_id': roomId, 'tenant_id': tenantId, 'prev_reading': prevReading, 'curr_reading': currReading}),
      );

      if (response.statusCode == 200) {
        return Reading.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update reading: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating reading: $e');
      rethrow;
    }
  }

  Future<void> deleteReading(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await _getAuthHeaders());
      if (response.statusCode != 204) {
        throw Exception('Failed to delete reading: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting reading: $e');
      rethrow;
    }
  }
}
