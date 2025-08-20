import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:m18_residences_admin/models/tenant.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TenantService {
  static final String baseUrl = '${dotenv.env['API_URL']}/tenants';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<List<Tenant>> fetchTenants() async {
    try {
      final response = await http.get(Uri.parse(baseUrl), headers: await _getAuthHeaders());
      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((json) => Tenant.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load tenants: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error fetching tenants: $e');
      rethrow;
    }
  }

  Future<Tenant> createTenant(String name, int roomId, DateTime joinDate) async {
    final dateTimeString = DateFormat('yyyy-MM-ddTHH:mm:ss').format(joinDate);
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: await _getAuthHeaders(),
        body: json.encode({'name': name, 'room_id': roomId, 'join_date': dateTimeString}),
      );

      if (response.statusCode == 201) {
        return Tenant.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create tenant: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error creating tenant: $e');
      rethrow;
    }
  }

  Future<Tenant> updateTenant(int id, String name, int roomId, DateTime joinDate, bool isActive) async {
    final dateTimeString = DateFormat('yyyy-MM-ddTHH:mm:ss').format(joinDate);
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/$id'),
        headers: await _getAuthHeaders(),
        body: json.encode({'name': name, 'room_id': roomId, 'join_date': dateTimeString, 'is_active': isActive}),
      );

      if (response.statusCode == 200) {
        return Tenant.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update tenant: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error updating tenant: $e');
      rethrow;
    }
  }

  Future<void> deleteTenant(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await _getAuthHeaders());

      if (response.statusCode != 204) {
        throw Exception('Failed to delete tenant: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error deleting tenant: $e');
      rethrow;
    }
  }
}
