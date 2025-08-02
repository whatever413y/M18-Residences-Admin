import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/widgets/custom_add_button.dart';
import 'package:rental_management_system_flutter/widgets/custom_app_bar.dart';
import '../services/room_service.dart';

class RoomsPage extends StatefulWidget {
  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final RoomService _roomService = RoomService();
  List<Room> _rooms = [];

  final _roomNameController = TextEditingController();
  final _rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRooms();
  }

  Future<void> _loadRooms() async {
    try {
      final rooms = await _roomService.fetchRooms();
      setState(() {
        _rooms = rooms;
      });
    } catch (e) {
      _showSnackBar('Failed to load rooms');
    }
  }

  void _showRoomDialog({Room? room}) {
    final isEditing = room != null;

    _roomNameController.text = isEditing ? room.name : '';
    _rentController.text = isEditing ? room.rent.toString() : '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _roomNameController,
                decoration: const InputDecoration(labelText: 'Room Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _rentController,
                decoration: const InputDecoration(labelText: 'Rent'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = _roomNameController.text.trim();
                final rent = double.tryParse(_rentController.text);

                if (name.isNotEmpty && rent != null) {
                  try {
                    if (isEditing) {
                      await _roomService.updateRoom(room.id, name, rent);
                      _showSnackBar('Room updated');
                    } else {
                      await _roomService.createRoom(name, rent);
                      _showSnackBar('Room "$name" added');
                    }
                    await _loadRooms();
                    Navigator.pop(context);
                  } catch (e) {
                    _showSnackBar('Operation failed');
                  }
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text(isEditing ? 'Save' : 'Add'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteRoom(int id) async {
    try {
      await _roomService.deleteRoom(id);
      _showSnackBar('Room deleted');
      await _loadRooms();
    } catch (e) {
      _showSnackBar('Failed to delete room');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildRoomTile(Room room) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          room.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('Rent: ₱${room.rent.toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showRoomDialog(room: room),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRoom(room.id),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Rooms'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            _rooms.isEmpty
                ? const Center(child: Text('No rooms available.'))
                : ListView.builder(
                  itemCount: _rooms.length,
                  itemBuilder:
                      (context, index) => _buildRoomTile(_rooms[index]),
                ),
      ),
      floatingActionButton: CustomAddButton(
        onPressed: () => _showRoomDialog(),
        label: 'New Room',
      ),
    );
  }
}
