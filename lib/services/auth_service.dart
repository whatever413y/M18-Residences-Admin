import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:rental_management_system_flutter/models/admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const _tokenKey = 'auth_token';
  static const _adminIdKey = 'admin_id';

  Admin? _cachedAdmin;

  Admin? get cachedAdmin => _cachedAdmin;

  Future<String?> adminLogin(String username, String password) async {
    final url = Uri.parse('${dotenv.env['API_URL']}/auth/admin-login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'] as String?;
      final userJson = data['user'] as Map<String, dynamic>;

      if (token == null || token.isEmpty) {
        throw Exception('Token missing from response');
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString(_adminIdKey, userJson['username']);

      _cachedAdmin = Admin.fromJson(userJson);
      return token;
    } else {
      throw Exception('Admin login failed: ${response.body}');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_adminIdKey);
    _cachedAdmin = null;
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<String?> getSavedToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<String?> getSavedAdminId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_adminIdKey);
  }

  Future<bool> isAuthenticated() async {
    final token = await getSavedToken();
    if (token == null || token.isEmpty) return false;
    final headers = await _getAuthHeaders();
    try {
      final response = await http.get(Uri.parse('${dotenv.env['API_URL']}/auth/validate-token'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error validating token: $e');
    }
  }
}
