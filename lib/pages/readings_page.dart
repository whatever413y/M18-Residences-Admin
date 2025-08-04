import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'package:rental_management_system_flutter/widgets/custom_add_button.dart';
import 'package:rental_management_system_flutter/widgets/custom_app_bar.dart';

class ReadingsPage extends StatefulWidget {
  @override
  ReadingsPageState createState() => ReadingsPageState();
}

class ReadingsPageState extends State<ReadingsPage> {
  final TenantService _tenantService = TenantService();
  final RoomService _roomService = RoomService();
  final ReadingService _readingService = ReadingService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  List<Room> rooms = [];
  List<Tenant> tenants = [];
  List<Reading> readings = [];

  int? _filterRoomId;
  int? _filterTenantId;
  int? _selectedRoomId;
  int? _selectedTenantId;

  final _prevReadingController = TextEditingController();
  final _currReadingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final fetchedTenants = await _tenantService.fetchTenants();
      final fetchedRooms = await _roomService.fetchRooms();
      final fetchedReadings = await _readingService.fetchReadings();
      setState(() {
        tenants = fetchedTenants;
        rooms = fetchedRooms;
        readings = fetchedReadings;
      });
    } catch (e) {
      debugPrint('Error loading data: $e');
      _showSnackBar('Failed to load data');
    }
  }

  List<Reading> get _filteredReadings =>
      readings.where((r) {
        final matchRoom = _filterRoomId == null || r.roomId == _filterRoomId;
        final matchTenant =
            _filterTenantId == null || r.tenantId == _filterTenantId;
        return matchRoom && matchTenant;
      }).toList();

  Room? _findRoomById(int id) => rooms.firstWhereOrNull((r) => r.id == id);
  Tenant? _findTenantById(int id) =>
      tenants.firstWhereOrNull((t) => t.id == id);

  String _getRoomName(int id) => _findRoomById(id)?.name ?? 'Unknown Room';
  String _getTenantName(int id) =>
      _findTenantById(id)?.name ?? 'Unknown Tenant';

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _deleteReading(int id) async {
    await _readingService.deleteReading(id);
    setState(() => readings.removeWhere((r) => r.id == id));
    _showSnackBar('Reading deleted');
  }

  Reading? _getLatestReading(int roomId, int tenantId) {
    final filtered =
        readings
            .where((r) => r.roomId == roomId && r.tenantId == tenantId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.isNotEmpty ? filtered.first : null;
  }

  void _addOrEditReadingDialog({Reading? reading}) {
    if (reading != null) {
      _selectedRoomId = reading.roomId;
      _selectedTenantId = reading.tenantId;
      _prevReadingController.text = reading.prevReading.toString();
      _currReadingController.text = reading.currReading.toString();
    } else {
      _selectedRoomId = _filterRoomId;
      _selectedTenantId = _filterTenantId;

      if (_selectedRoomId != null && _selectedTenantId != null) {
        final latest = _getLatestReading(_selectedRoomId!, _selectedTenantId!);
        _prevReadingController.text = latest?.currReading.toString() ?? '0';
      } else {
        _prevReadingController.text = '0';
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
                                child: Text('All Rooms'),
                              ),
                              ...rooms.map(
                                (room) => DropdownMenuItem<int>(
                                  value: room.id,
                                  child: Text(room.name),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                _selectedRoomId = value;

                                if (_selectedTenantId != null) {
                                  final tenant = tenants.firstWhereOrNull(
                                    (t) => t.id == _selectedTenantId,
                                  );
                                  if (tenant == null ||
                                      tenant.roomId != _selectedRoomId) {
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
                                      latest?.currReading.toString() ?? '0';
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
                                child: Text('Choose a tenant'),
                              ),
                              ...tenants
                                  .where(
                                    (t) =>
                                        _selectedRoomId == null ||
                                        t.roomId == _selectedRoomId,
                                  )
                                  .map(
                                    (tenant) => DropdownMenuItem<int>(
                                      value: tenant.id,
                                      child: Text(tenant.name),
                                    ),
                                  ),
                            ],
                            onChanged: (value) {
                              setStateDialog(() {
                                _selectedTenantId = value;

                                if (_selectedTenantId != null) {
                                  final tenantRoomId =
                                      tenants
                                          .firstWhere(
                                            (t) => t.id == _selectedTenantId,
                                          )
                                          .roomId;
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
                                          ? latest.currReading.toString()
                                          : '0';
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
                      onPressed: () async {
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

                        try {
                          if (reading == null) {
                            final newReading = await _readingService
                                .createReading(
                                  roomId: _selectedRoomId!,
                                  tenantId: _selectedTenantId!,
                                  prevReading: prevReading,
                                  currReading: currReading,
                                );
                            setState(() => readings.add(newReading));
                            _showSnackBar('Reading added');
                          } else {
                            final updatedReading = await _readingService
                                .updateReading(
                                  id: reading.id,
                                  roomId: _selectedRoomId!,
                                  tenantId: _selectedTenantId!,
                                  prevReading: prevReading,
                                  currReading: currReading,
                                );
                            setState(() {
                              final index = readings.indexWhere(
                                (r) => r.id == updatedReading.id,
                              );
                              if (index != -1) readings[index] = updatedReading;
                            });
                            _showSnackBar('Reading updated');
                          }

                          Navigator.of(context).pop();
                        } catch (e) {
                          _showSnackBar('Error saving reading: $e');
                        }
                      },

                      child: Text(reading == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _showReadingDetailsDialog(Reading reading) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 400),
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
                    _buildDetailRow('Tenant', _getTenantName(reading.tenantId)),
                    SizedBox(height: 12),
                    _buildDetailRow('Room', _getRoomName(reading.roomId)),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Previous Reading',
                      '${reading.prevReading} kWh',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Current Reading',
                      '${reading.currReading} kWh',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Consumption',
                      '${reading.consumption} kWh',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Date',
                      _dateFormat.format(reading.createdAt),
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
                            value: room.id,
                            child: Text(room.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterRoomId = value;
                          if (_filterRoomId == null) {
                            _filterTenantId = null;
                          } else if (_filterTenantId != null) {
                            final tenant = _findTenantById(_filterTenantId!);

                            if (tenant == null ||
                                tenant.roomId != _filterRoomId) {
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
                        hintText: 'Choose a tenant',
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
                          enabled: false,
                          child: Text('Choose a tenant'),
                        ),
                        ...tenants
                            .where(
                              (t) =>
                                  _filterRoomId == null ||
                                  t.roomId == _filterRoomId,
                            )
                            .map(
                              (tenant) => DropdownMenuItem(
                                value: tenant.id,
                                child: Text(tenant.name),
                              ),
                            ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _filterTenantId = value;
                          if (value != null) {
                            final tenant = tenants.firstWhere(
                              (t) => t.id == value,
                            );
                            if (_filterRoomId != tenant.roomId) {
                              _filterRoomId = tenant.roomId;
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
                            DataColumn(label: Text('Previous (kWh)')),
                            DataColumn(label: Text('Current (kWh)')),
                            DataColumn(label: Text('Consumption (kWh)')),
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
                                      Text(_getRoomName(reading.roomId)),
                                    ),
                                    DataCell(
                                      Text(_getTenantName(reading.tenantId)),
                                    ),
                                    DataCell(
                                      Text(reading.prevReading.toString()),
                                    ),
                                    DataCell(
                                      Text(reading.currReading.toString()),
                                    ),
                                    DataCell(
                                      Text(reading.consumption.toString()),
                                    ),
                                    DataCell(
                                      Text(
                                        _dateFormat.format(reading.createdAt),
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
                                                () =>
                                                    _deleteReading(reading.id),
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
        onPressed: () => _addOrEditReadingDialog(reading: null),
        label: 'New Reading',
      ),
    );
  }
}
