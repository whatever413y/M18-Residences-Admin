import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Room {
  final int id;
  final String name;
  final double rent;

  Room({required this.id, required this.name, required this.rent});

  factory Room.fromJson(Map<String, dynamic> json) => Room(
    id: json['id'],
    name: json['name'],
    rent: (json['rent'] as num).toDouble(),
  );

  Map<String, dynamic> toJson() => {'name': name, 'rent': rent};
}

class RoomService {
  static final String baseUrl = '${dotenv.env['API_URL']}/rooms';

  Future<List<Room>> fetchRooms() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      return data.map((json) => Room.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load rooms');
    }
  }

  Future<Room> createRoom(String name, double rent) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'rent': rent}),
    );

    if (response.statusCode == 201) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to create room');
    }
  }

  Future<Room> updateRoom(int id, String name, double rent) async {
    final response = await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'name': name, 'rent': rent}),
    );

    if (response.statusCode == 200) {
      return Room.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to update room');
    }
  }

  Future<void> deleteRoom(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    if (response.statusCode != 204) {
      throw Exception('Failed to delete room');
    }
  }
}
