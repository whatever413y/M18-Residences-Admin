import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rental_management_system_flutter/models/admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = '${String.fromEnvironment('API_URL')}/auth';
  static const _tokenKey = 'auth_token';
  static const _adminIdKey = 'admin_id';

  Admin? _cachedAdmin;

  Admin? get cachedAdmin => _cachedAdmin;

  Future<String?> adminLogin(String username, String password) async {
    final url = Uri.parse('$baseUrl/admin-login');

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
      final response = await http.get(Uri.parse('$baseUrl/validate-token'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error validating token: $e');
    }
  }

  Future<String?> fetchReceiptUrl(String tenantName, String filename) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$baseUrl/receipts/$tenantName/$filename');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String?;
    } else {
      throw Exception('Failed to fetch receipt URL: ${response.body}');
    }
  }
}
