import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';

class TenantService {
  static final String baseUrl = '${dotenv.env['API_URL']}/tenants';

  Future<List<Tenant>> fetchTenants() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Tenant.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load tenants');
    }
  }

  Future<Tenant> createTenant(
    String name,
    int roomId,
    DateTime joinDate,
  ) async {
    final dateOnly = DateFormat('yyyy-MM-dd').format(joinDate);
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'roomId': roomId, 'joinDate': dateOnly}),
    );

    if (response.statusCode == 201) {
      return Tenant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create tenant');
    }
  }

  Future<Tenant> updateTenant(
    int id,
    String name,
    int roomId,
    DateTime joinDate,
  ) async {
    final dateOnly = DateFormat('yyyy-MM-dd').format(joinDate);
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'roomId': roomId, 'joinDate': dateOnly}),
    );

    if (response.statusCode == 200) {
      return Tenant.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update tenant');
    }
  }

  Future<void> deleteTenant(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete tenant');
    }
  }
}
