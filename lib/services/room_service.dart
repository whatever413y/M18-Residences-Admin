import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoomService {
  static final String baseUrl = '${String.fromEnvironment('API_URL')}/rooms';

  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {'Content-Type': 'application/json', if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token'};
  }

  Future<List<Room>> fetchRooms() async {
    final response = await http.get(Uri.parse(baseUrl), headers: await _getAuthHeaders());
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<Room> createRoom(String name, int rent) async {
    final response = await http.post(Uri.parse(baseUrl), headers: await _getAuthHeaders(), body: json.encode({'name': name, 'rent': rent}));

    if (response.statusCode == 201) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create room');
    }
  }

  Future<Room> updateRoom(int id, String name, int rent) async {
    final response = await http.put(Uri.parse('$baseUrl/$id'), headers: await _getAuthHeaders(), body: json.encode({'name': name, 'rent': rent}));

    if (response.statusCode == 200) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update room');
    }
  }

  Future<void> deleteRoom(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'), headers: await _getAuthHeaders());

    if (response.statusCode != 204) {
      throw Exception('Failed to delete room');
    }
  }
}
