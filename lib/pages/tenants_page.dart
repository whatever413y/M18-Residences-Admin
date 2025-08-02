import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/widgets/custom_add_button.dart';
import 'package:rental_management_system_flutter/widgets/custom_app_bar.dart';

class TenantsPage extends StatefulWidget {
  @override
  TenantsPageState createState() => TenantsPageState();
}

class TenantsPageState extends State<TenantsPage> {
  final List<Map<String, dynamic>> tenants = [
    {
      "id": 1,
      "name": "John Doe",
      "room": "Room A",
      "joined_date": DateTime(2023, 3, 15),
    },
    {
      "id": 2,
      "name": "Jane Smith",
      "room": "Room B",
      "joined_date": DateTime(2023, 4, 10),
    },
  ];

  final _tenantNameController = TextEditingController();
  final _roomNameController = TextEditingController();
  DateTime? _selectedJoinDate;

  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  void _showTenantDialog({Map<String, dynamic>? tenant}) {
    final isEditing = tenant != null;
    _tenantNameController.text = tenant?['name'] ?? '';
    _roomNameController.text = tenant?['room'] ?? '';
    _selectedJoinDate = tenant?['joined_date'];

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
                  TextField(
                    controller: _roomNameController,
                    decoration: const InputDecoration(labelText: 'Room Name'),
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
                  onPressed: () {
                    final tenantName = _tenantNameController.text.trim();
                    final roomName = _roomNameController.text.trim();

                    if (tenantName.isEmpty ||
                        roomName.isEmpty ||
                        _selectedJoinDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please fill all fields and pick a join date',
                          ),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (isEditing) {
                        tenant['name'] = tenantName;
                        tenant['room'] = roomName;
                        tenant['joined_date'] = _selectedJoinDate;
                      } else {
                        tenants.add({
                          'id': tenants.length + 1,
                          'name': tenantName,
                          'room': roomName,
                          'joined_date': _selectedJoinDate,
                        });
                      }
                    });

                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Tenant updated'
                              : 'Tenant "$tenantName" added',
                        ),
                      ),
                    );
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

  void _deleteTenant(int id) {
    setState(() {
      tenants.removeWhere((tenant) => tenant['id'] == id);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Tenant deleted')));
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
                    return Card(
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          tenant['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          'Room: ${tenant['room']}\nJoined: ${tenant['joined_date'] != null ? _dateFormat.format(tenant['joined_date']) : "N/A"}',
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
                              onPressed: () => _deleteTenant(tenant['id']),
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
