import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/widgets/custom_add_button.dart';
import 'package:rental_management_system_flutter/widgets/custom_app_bar.dart';

class ReadingsPage extends StatefulWidget {
  @override
  ReadingsPageState createState() => ReadingsPageState();
}

class ReadingsPageState extends State<ReadingsPage> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  // Mock rooms data: 5 rooms
  final List<Map<String, dynamic>> rooms = [
    {"id": 1, "name": "Room A"},
    {"id": 2, "name": "Room B"},
    {"id": 3, "name": "Room C"},
    {"id": 4, "name": "Room D"},
    {"id": 5, "name": "Room E"},
  ];

  // Mock tenants data: 5 tenants, including one tenant assigned to multiple rooms
  final List<Map<String, dynamic>> tenants = [
    {"id": 1, "name": "John Doe", "room_id": 1},
    {"id": 2, "name": "Jane Smith", "room_id": 2},
    {"id": 3, "name": "Alice Johnson", "room_id": 3},
    {"id": 4, "name": "Bob Williams", "room_id": 4},
    // Tenant with multiple rooms (simulate by multiple tenant-room links)
    {"id": 5, "name": "Charlie Brown", "room_id": 5},
    {
      "id": 6,
      "name": "Charlie Brown 2",
      "room_id": 3,
    }, // same tenant different room
  ];

  // Mock readings data: 3 readings each, sorted by latest month first (newest first)
  // For tenant 5 with multiple rooms, 3 readings per room
  List<Map<String, dynamic>> readings = [
    // Tenant 1, Room 1
    {
      "id": 1,
      "tenant_id": 1,
      "room_id": 1,
      "prev_reading": 1000,
      "curr_reading": 1100,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 10)),
    },
    {
      "id": 2,
      "tenant_id": 1,
      "room_id": 1,
      "prev_reading": 900,
      "curr_reading": 1000,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 40)),
    },
    {
      "id": 3,
      "tenant_id": 1,
      "room_id": 1,
      "prev_reading": 800,
      "curr_reading": 900,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 70)),
    },

    // Tenant 2, Room 2
    {
      "id": 4,
      "tenant_id": 2,
      "room_id": 2,
      "prev_reading": 800,
      "curr_reading": 900,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 5)),
    },
    {
      "id": 5,
      "tenant_id": 2,
      "room_id": 2,
      "prev_reading": 700,
      "curr_reading": 800,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 35)),
    },
    {
      "id": 6,
      "tenant_id": 2,
      "room_id": 2,
      "prev_reading": 600,
      "curr_reading": 700,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 65)),
    },

    // Tenant 3, Room 3
    {
      "id": 7,
      "tenant_id": 3,
      "room_id": 3,
      "prev_reading": 1200,
      "curr_reading": 1300,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 15)),
    },
    {
      "id": 8,
      "tenant_id": 3,
      "room_id": 3,
      "prev_reading": 1100,
      "curr_reading": 1200,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 45)),
    },
    {
      "id": 9,
      "tenant_id": 3,
      "room_id": 3,
      "prev_reading": 1000,
      "curr_reading": 1100,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 75)),
    },

    // Tenant 4, Room 4
    {
      "id": 10,
      "tenant_id": 4,
      "room_id": 4,
      "prev_reading": 1300,
      "curr_reading": 1400,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 8)),
    },
    {
      "id": 11,
      "tenant_id": 4,
      "room_id": 4,
      "prev_reading": 1200,
      "curr_reading": 1300,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 38)),
    },
    {
      "id": 12,
      "tenant_id": 4,
      "room_id": 4,
      "prev_reading": 1100,
      "curr_reading": 1200,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 68)),
    },

    // Tenant 5, Room 5
    {
      "id": 13,
      "tenant_id": 5,
      "room_id": 5,
      "prev_reading": 900,
      "curr_reading": 1000,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 12)),
    },
    {
      "id": 14,
      "tenant_id": 5,
      "room_id": 5,
      "prev_reading": 800,
      "curr_reading": 900,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 42)),
    },
    {
      "id": 15,
      "tenant_id": 5,
      "room_id": 5,
      "prev_reading": 700,
      "curr_reading": 800,
      "consumption": 100,
      "created_at": DateTime.now().subtract(Duration(days: 72)),
    },

    // Tenant 5, Room 1 (multiple rooms for same tenant)
    {
      "id": 16,
      "tenant_id": 6,
      "room_id": 3,
      "prev_reading": 1100,
      "curr_reading": 1150,
      "consumption": 50,
      "created_at": DateTime.now().subtract(Duration(days: 7)),
    },
    {
      "id": 17,
      "tenant_id": 6,
      "room_id": 3,
      "prev_reading": 1050,
      "curr_reading": 1100,
      "consumption": 50,
      "created_at": DateTime.now().subtract(Duration(days: 37)),
    },
    {
      "id": 18,
      "tenant_id": 6,
      "room_id": 3,
      "prev_reading": 1000,
      "curr_reading": 1050,
      "consumption": 50,
      "created_at": DateTime.now().subtract(Duration(days: 67)),
    },
  ];

  int? _filterRoomId;
  int? _filterTenantId;

  final _prevReadingController = TextEditingController();
  final _currReadingController = TextEditingController();

  int? _selectedRoomId;
  int? _selectedTenantId;

  List<Map<String, dynamic>> get _filteredTenants {
    if (_selectedRoomId == null) return tenants;
    return tenants.where((t) => t['room_id'] == _selectedRoomId).toList();
  }

  List<Map<String, dynamic>> get _filteredReadings {
    return readings.where((r) {
      final matchesRoom =
          _filterRoomId == null || r['room_id'] == _filterRoomId;
      final matchesTenant =
          _filterTenantId == null || r['tenant_id'] == _filterTenantId;
      return matchesRoom && matchesTenant;
    }).toList();
  }

  Map<String, dynamic>? _findById(List<Map<String, dynamic>> list, int id) {
    try {
      return list.firstWhere((item) => item['id'] == id);
    } catch (_) {
      return null;
    }
  }

  String _getTenantName(int tenantId) {
    final tenant = _findById(tenants, tenantId);
    return tenant != null ? tenant['name'] : 'Unknown Tenant';
  }

  String _getRoomName(int roomId) {
    final room = _findById(rooms, roomId);
    return room != null ? room['name'] : 'Unknown Room';
  }

  /// Returns the latest reading for given tenant & room or null if none
  Map<String, dynamic>? _getLatestReading(int roomId, int tenantId) {
    final filtered =
        readings
            .where((r) => r['room_id'] == roomId && r['tenant_id'] == tenantId)
            .toList();
    if (filtered.isEmpty) return null;
    filtered.sort((a, b) => b['created_at'].compareTo(a['created_at']));
    return filtered.first;
  }

  void _addOrEditReadingDialog({Map<String, dynamic>? reading}) {
    if (reading != null) {
      // Edit mode
      _selectedRoomId = reading['room_id'];
      _selectedTenantId = reading['tenant_id'];
      _prevReadingController.text = reading['prev_reading'].toString();
      _currReadingController.text = reading['curr_reading'].toString();
    } else {
      // Add mode
      _selectedRoomId = _filterRoomId;
      _selectedTenantId = _filterTenantId;

      if (_selectedRoomId != null && _selectedTenantId != null) {
        final latest = _getLatestReading(_selectedRoomId!, _selectedTenantId!);
        _prevReadingController.text =
            latest != null ? latest['curr_reading'].toString() : '';
      } else {
        _prevReadingController.clear();
      }
      _currReadingController.clear();
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Text(
                    reading == null ? 'Add New Reading' : 'Edit Reading',
                  ),
                  content: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Select Room',
                              hintText: 'Choose a room',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            value: _selectedRoomId,
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                enabled:
                                    false, // Disable selecting "Select Room" once a room is chosen
                                child: Text('Select Room'),
                              ),
                              ...rooms.map(
                                (room) => DropdownMenuItem<int>(
                                  value: room['id'],
                                  child: Text(room['name']),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                _selectedRoomId = value;

                                if (_selectedTenantId != null) {
                                  Map<String, dynamic>? tenant;
                                  try {
                                    tenant = tenants.firstWhere(
                                      (t) => t['id'] == _selectedTenantId,
                                    );
                                  } catch (_) {
                                    tenant = null;
                                  }
                                  if (tenant == null ||
                                      tenant['room_id'] != _selectedRoomId) {
                                    _selectedTenantId = null;
                                  }
                                }

                                if (reading == null &&
                                    _selectedRoomId != null &&
                                    _selectedTenantId != null) {
                                  final latest = _getLatestReading(
                                    _selectedRoomId!,
                                    _selectedTenantId!,
                                  );
                                  _prevReadingController.text =
                                      latest != null
                                          ? latest['curr_reading'].toString()
                                          : '';
                                } else if (reading == null) {
                                  _prevReadingController.clear();
                                }
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          DropdownButtonFormField<int>(
                            decoration: InputDecoration(
                              labelText: 'Select Tenant',
                              hintText: 'Choose a tenant',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                            value: _selectedTenantId,
                            items: [
                              DropdownMenuItem<int>(
                                value: null,
                                enabled: false,
                                child: Text('Select Tenant'),
                              ),
                              ..._filteredTenants.map(
                                (tenant) => DropdownMenuItem<int>(
                                  value: tenant['id'],
                                  child: Text(tenant['name']),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                _selectedTenantId = value;

                                if (_selectedTenantId != null) {
                                  final tenantRoomId =
                                      tenants.firstWhere(
                                        (t) => t['id'] == _selectedTenantId,
                                      )['room_id'];
                                  if (_selectedRoomId != tenantRoomId) {
                                    _selectedRoomId = tenantRoomId;
                                  }
                                }

                                if (reading == null &&
                                    _selectedRoomId != null &&
                                    _selectedTenantId != null) {
                                  final latest = _getLatestReading(
                                    _selectedRoomId!,
                                    _selectedTenantId!,
                                  );
                                  _prevReadingController.text =
                                      latest != null
                                          ? latest['curr_reading'].toString()
                                          : '';
                                } else if (reading == null) {
                                  _prevReadingController.clear();
                                }
                              });
                            },
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _prevReadingController,
                            decoration: InputDecoration(
                              labelText: 'Previous Reading',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            enabled: reading != null,
                            style:
                                reading == null
                                    ? TextStyle(color: Colors.grey.shade600)
                                    : null,
                          ),
                          SizedBox(height: 16),
                          TextField(
                            controller: _currReadingController,
                            decoration: InputDecoration(
                              labelText: 'Current Reading',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade800,
                        padding: EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      onPressed: () {
                        final prevReading = int.tryParse(
                          _prevReadingController.text,
                        );
                        final currReading = int.tryParse(
                          _currReadingController.text,
                        );

                        if (_selectedRoomId == null ||
                            _selectedTenantId == null ||
                            prevReading == null ||
                            currReading == null ||
                            currReading < prevReading) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please select valid room, tenant and readings (current >= previous).',
                              ),
                            ),
                          );
                          return;
                        }

                        setState(() {
                          if (reading == null) {
                            readings.add({
                              'id': readings.length + 1,
                              'room_id': _selectedRoomId,
                              'tenant_id': _selectedTenantId,
                              'prev_reading': prevReading,
                              'curr_reading': currReading,
                              'consumption': currReading - prevReading,
                              'created_at': DateTime.now(),
                            });
                          } else {
                            reading['room_id'] = _selectedRoomId;
                            reading['tenant_id'] = _selectedTenantId;
                            reading['prev_reading'] = prevReading;
                            reading['curr_reading'] = currReading;
                            reading['consumption'] = currReading - prevReading;
                          }
                        });

                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              reading == null
                                  ? 'Reading added'
                                  : 'Reading updated',
                            ),
                          ),
                        );
                      },
                      child: Text(reading == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteReading(int id) {
    setState(() {
      readings.removeWhere((r) => r['id'] == id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Reading deleted')));
  }

  void _showReadingDetailsDialog(Map<String, dynamic> reading) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth:
                  400, // Set a max width for better centering and readability
            ),
            child: Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 12,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reading Details',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 16),
                    _buildDetailRow(
                      'Tenant',
                      _getTenantName(reading['tenant_id']),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('Room', _getRoomName(reading['room_id'])),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Previous Reading',
                      reading['prev_reading'].toString(),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Current Reading',
                      reading['curr_reading'].toString(),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Consumption',
                      reading['consumption'].toString(),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Date',
                      _dateFormat.format(reading['created_at']),
                    ),
                    SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue.shade800,
                          padding: EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(
                          'Close',
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 140,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Electricity Readings'),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Room',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      value: _filterRoomId,
                      items: [
                        DropdownMenuItem(value: null, child: Text('All Rooms')),
                        ...rooms.map(
                          (room) => DropdownMenuItem(
                            value: room['id'],
                            child: Text(room['name']),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterRoomId = value;
                          if (_filterRoomId == null) {
                            _filterTenantId = null;
                          } else if (_filterTenantId != null) {
                            final tenant = _findById(tenants, _filterTenantId!);
                            if (tenant == null ||
                                tenant['room_id'] != _filterRoomId) {
                              _filterTenantId = null;
                            }
                          }
                        });
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Tenant',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      value: _filterTenantId,
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text('All Tenants'),
                        ),
                        ...tenants
                            .where(
                              (t) =>
                                  _filterRoomId == null ||
                                  t['room_id'] == _filterRoomId,
                            )
                            .map(
                              (tenant) => DropdownMenuItem(
                                value: tenant['id'],
                                child: Text(tenant['name']),
                              ),
                            ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterTenantId = value;
                          if (value != null) {
                            final tenantRoomId =
                                tenants.firstWhere(
                                  (t) => t['id'] == value,
                                )['room_id'];
                            if (_filterRoomId != tenantRoomId) {
                              _filterRoomId = tenantRoomId;
                            }
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12),

            Expanded(
              child:
                  _filteredReadings.isEmpty
                      ? Center(
                        child: Text(
                          'No readings found for the selected filters.',
                        ),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn(label: Text('Room')),
                            DataColumn(label: Text('Tenant')),
                            DataColumn(label: Text('Prev Reading')),
                            DataColumn(label: Text('Curr Reading')),
                            DataColumn(label: Text('Consumption')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows:
                              _filteredReadings.map((reading) {
                                return DataRow(
                                  onSelectChanged: (_) {
                                    _showReadingDetailsDialog(reading);
                                  },
                                  cells: [
                                    DataCell(
                                      Text(_getRoomName(reading['room_id'])),
                                    ),
                                    DataCell(
                                      Text(
                                        _getTenantName(reading['tenant_id']),
                                      ),
                                    ),
                                    DataCell(
                                      Text(reading['prev_reading'].toString()),
                                    ),
                                    DataCell(
                                      Text(reading['curr_reading'].toString()),
                                    ),
                                    DataCell(
                                      Text(reading['consumption'].toString()),
                                    ),
                                    DataCell(
                                      Text(
                                        _dateFormat.format(
                                          reading['created_at'],
                                        ),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed:
                                                () => _addOrEditReadingDialog(
                                                  reading: reading,
                                                ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _deleteReading(
                                                  reading['id'],
                                                ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                        ),
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: CustomAddButton(
        onPressed: () => _addOrEditReadingDialog(),
        label: 'New Reading',
      ),
    );
  }
}
