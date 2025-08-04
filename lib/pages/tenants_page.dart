import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';

class TenantsPage extends StatefulWidget {
  @override
  TenantsPageState createState() => TenantsPageState();
}

class TenantsPageState extends State<TenantsPage> {
  final TenantService _tenantService = TenantService();
  final RoomService _roomService = RoomService();

  List<Tenant> tenants = [];
  List<Room> rooms = [];

  final _tenantNameController = TextEditingController();
  String? _selectedRoomId;
  DateTime? _selectedJoinDate;

  final DateFormat _dateFormat = DateFormat('MMMM d, y');

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedTenants = await _tenantService.fetchTenants();
      final fetchedRooms = await _roomService.fetchRooms();
      setState(() {
        tenants = fetchedTenants;
        rooms = fetchedRooms;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      _showSnackBar('Failed to load data');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showTenantDialog({Tenant? tenant}) {
    final isEditing = tenant != null;
    _tenantNameController.text = tenant?.name ?? '';
    _selectedRoomId = tenant?.roomId.toString();
    _selectedJoinDate = tenant?.joinDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Tenant' : 'Add New Tenant'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _tenantNameController,
                    decoration: const InputDecoration(labelText: 'Tenant Name'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedRoomId,
                    items:
                        rooms.map((room) {
                          return DropdownMenuItem<String>(
                            value: room.id.toString(),
                            child: Text(room.name),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setStateDialog(() {
                        _selectedRoomId = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Room'),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _selectedJoinDate == null
                              ? 'Select Join Date'
                              : 'Joined: ${_dateFormat.format(_selectedJoinDate!)}',
                        ),
                      ),
                      TextButton(
                        onPressed: () async {
                          final now = DateTime.now();
                          final initialDate = _selectedJoinDate ?? now;
                          final pickedDate = await showDatePicker(
                            context: context,
                            initialDate: initialDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(now.year + 5),
                          );
                          if (pickedDate != null) {
                            setStateDialog(() {
                              _selectedJoinDate = pickedDate;
                            });
                          }
                        },
                        child: const Text('Pick Date'),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                  ),
                  onPressed: () async {
                    final tenantName = _tenantNameController.text.trim();
                    final roomId = _selectedRoomId;
                    final joinDate = _selectedJoinDate;

                    if (tenantName.isEmpty ||
                        roomId == null ||
                        joinDate == null) {
                      _showSnackBar('Please fill all fields');
                      return;
                    }

                    try {
                      if (isEditing) {
                        await _tenantService.updateTenant(
                          tenant.id,
                          tenantName,
                          int.parse(roomId),
                          joinDate,
                        );
                      } else {
                        await _tenantService.createTenant(
                          tenantName,
                          int.parse(roomId),
                          joinDate,
                        );
                      }

                      Navigator.of(context).pop();
                      await _loadData();

                      _showSnackBar(
                        isEditing ? 'Tenant updated' : 'Tenant added',
                      );
                    } catch (e) {
                      debugPrint('Error saving tenant: $e');
                      _showSnackBar('Failed to save tenant');
                    }
                  },
                  child: Text(isEditing ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _deleteTenant(int id) async {
    try {
      await _tenantService.deleteTenant(id);
      await _loadData();
      _showSnackBar('Tenant deleted');
    } catch (e) {
      debugPrint('Error deleting tenant: $e');
      _showSnackBar('Failed to delete tenant');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Tenants'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            tenants.isEmpty
                ? const Center(child: Text('No tenants available.'))
                : ListView.builder(
                  itemCount: tenants.length,
                  itemBuilder: (context, index) {
                    final tenant = tenants[index];
                    final room = rooms.firstWhere(
                      (r) => r.id == tenant.roomId,
                      orElse: () => Room(id: -1, name: 'Unknown', rent: 0),
                    );

                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          tenant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Room: ${room.name}\nJoined: ${_dateFormat.format(tenant.joinDate)}',
                        ),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed:
                                  () => _showTenantDialog(tenant: tenant),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteTenant(tenant.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
      floatingActionButton: CustomAddButton(
        onPressed: () => _showTenantDialog(),
        label: "New Tenant",
      ),
    );
  }
}
