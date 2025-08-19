import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:rental_management_system_flutter/models/admin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static final String baseUrl = String.fromEnvironment('API_URL');
  static const _tokenKey = 'auth_token';
  static const _adminIdKey = 'admin_id';

  Admin? _cachedAdmin;

  Admin? get cachedAdmin => _cachedAdmin;

  Future<String?> adminLogin(String username, String password) async {
    try {
      final url = Uri.parse('$baseUrl/auth/admin-login');
      final response = await http
          .post(url, headers: {'Content-Type': 'application/json'}, body: jsonEncode({'username': username, 'password': password}))
          .timeout(const Duration(seconds: 120));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final token = data['token'] as String?;
        final username = data['username'] as String?;

        if (token == null || token.isEmpty || username == null || username.isEmpty) {
          return null;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_adminIdKey, username);

        _cachedAdmin = Admin(username: username);
        return token;
      }

      return null;
    } on TimeoutException {
      throw TimeoutException('Request timed out.');
    } on SocketException {
      throw SocketException('No internet connection');
    } catch (e) {
      throw Exception('Unexpected error: $e');
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
      final response = await http.post(Uri.parse('$baseUrl/auth/validate-token'), headers: headers);
      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error validating token: $e');
    }
  }

  Future<String?> fetchReceiptUrl(String tenantName, String filename) async {
    final headers = await _getAuthHeaders();
    final url = Uri.parse('$baseUrl/signed-urls/receipts/$tenantName/$filename');
    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'] as String?;
    } else {
      throw Exception('Failed to fetch receipt URL: ${response.body}');
    }
  }
}
