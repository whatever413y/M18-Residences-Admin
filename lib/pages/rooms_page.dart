import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/widgets/custom_add_button.dart';
import 'package:rental_management_system_flutter/widgets/custom_app_bar.dart';

class RoomsPage extends StatefulWidget {
  @override
  State<RoomsPage> createState() => _RoomsPageState();
}

class _RoomsPageState extends State<RoomsPage> {
  final List<Map<String, dynamic>> _rooms = [
    {"id": 1, "name": "Room A", "rent": 500.00},
    {"id": 2, "name": "Room B", "rent": 600.00},
  ];

  final _roomNameController = TextEditingController();
  final _rentController = TextEditingController();

  void _showRoomDialog({Map<String, dynamic>? room}) {
    final isEditing = room != null;

    _roomNameController.text = isEditing ? room['name'] : '';
    _rentController.text = isEditing ? room['rent'].toString() : '';

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
              onPressed: () {
                final name = _roomNameController.text.trim();
                final rent = double.tryParse(_rentController.text);

                if (name.isNotEmpty && rent != null) {
                  setState(() {
                    if (isEditing) {
                      room['name'] = name;
                      room['rent'] = rent;
                      _showSnackBar('Room updated');
                    } else {
                      _rooms.add({
                        'id': _rooms.length + 1,
                        'name': name,
                        'rent': rent,
                      });
                      _showSnackBar('Room "$name" added');
                    }
                  });
                  Navigator.pop(context);
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

  void _deleteRoom(int id) {
    setState(() {
      _rooms.removeWhere((room) => room['id'] == id);
    });
    _showSnackBar('Room deleted');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Widget _buildRoomTile(Map<String, dynamic> room) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          room['name'],
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        subtitle: Text('Rent: ₱${room['rent'].toStringAsFixed(2)}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _showRoomDialog(room: room),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteRoom(room['id']),
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
