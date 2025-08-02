import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/widgets/custom_add_button.dart';
import 'package:rental_management_system_flutter/widgets/custom_app_bar.dart';

class BillingsPage extends StatefulWidget {
  @override
  BillingsPageState createState() => BillingsPageState();
}

class BillingsPageState extends State<BillingsPage> {
  // Mock data: rooms, tenants, readings, bills
  final List<Map<String, dynamic>> rooms = [
    {'id': 1, 'name': 'Room A', 'room_charges': 5000.0},
    {'id': 2, 'name': 'Room B', 'room_charges': 4800.0},
    // Add more rooms
  ];
  final List<Map<String, dynamic>> tenants = [
    {'id': 1, 'name': 'John Doe', 'room_id': 1},
    {'id': 2, 'name': 'Jane Smith', 'room_id': 2},
    // Add more tenants
  ];

  List<Map<String, dynamic>> readings = [
    // sample readings with consumption for electricity charges
    {
      'tenant_id': 1,
      'room_id': 1,
      'consumption': 100,
      'created_at': DateTime(2025, 8, 1),
    },
    {
      'tenant_id': 1,
      'room_id': 1,
      'consumption': 120,
      'created_at': DateTime(2025, 7, 1),
    },
    // More readings...
  ];

  final List<Map<String, dynamic>> bills = [
    {
      'id': 1,
      'room_id': 1,
      'tenant_id': 1,
      'room_charges': 5000.00,
      'electric_charges': 1200.50,
      'additional_charges': 300.00,
      'additional_description': 'Internet and water charges',
      'total_amount': 6500.50,
      'created_at': DateTime(2025, 8, 1, 10, 30),
    },
    {
      'id': 2,
      'room_id': 2,
      'tenant_id': 2,
      'room_charges': 4800.00,
      'electric_charges': 900.75,
      'additional_charges': 0.00,
      'additional_description': '',
      'total_amount': 5700.75,
      'created_at': DateTime(2025, 7, 15, 14, 45),
    },
    {
      'id': 3,
      'room_id': 1,
      'tenant_id': 1,
      'room_charges': 5000.00,
      'electric_charges': 1100.00,
      'additional_charges': 150.00,
      'additional_description': 'Maintenance fee',
      'total_amount': 6250.00,
      'created_at': DateTime(2024, 12, 30, 9, 15),
    },
    {
      'id': 4,
      'room_id': 3,
      'tenant_id': 3,
      'room_charges': 4500.00,
      'electric_charges': 1000.00,
      'additional_charges': 200.00,
      'additional_description': 'Cleaning service',
      'total_amount': 5700.00,
      'created_at': DateTime(2025, 1, 10, 11, 0),
    },
    {
      'id': 5,
      'room_id': 2,
      'tenant_id': 2,
      'room_charges': 4800.00,
      'electric_charges': 950.00,
      'additional_charges': 100.00,
      'additional_description': '',
      'total_amount': 5850.00,
      'created_at': DateTime(2023, 11, 25, 16, 20),
    },
  ];

  // Filters
  int? _filterRoomId;
  int? _filterTenantId;
  int? _filterYear;

  List<Map<String, dynamic>> get _filteredBills {
    return bills.where((bill) {
      final matchRoom =
          _filterRoomId == null || bill['room_id'] == _filterRoomId;
      final matchTenant =
          _filterTenantId == null || bill['tenant_id'] == _filterTenantId;
      final matchYear =
          _filterYear == null || bill['created_at'].year == _filterYear;
      return matchRoom && matchTenant && matchYear;
    }).toList();
  }

  String _getTenantName(int tenantId) {
    final tenant = _findById(tenants, tenantId);
    return tenant != null ? tenant['name'] : 'Unknown Tenant';
  }

  String _getRoomName(int roomId) {
    final room = _findById(rooms, roomId);
    return room != null ? room['name'] : 'Unknown Room';
  }

  // Fetch tenants filtered by room for filter dropdown
  List<Map<String, dynamic>> get _filteredTenants {
    if (_filterRoomId == null) return tenants;
    return tenants.where((t) => t['room_id'] == _filterRoomId).toList();
  }

  // Find room or tenant by id helper
  Map<String, dynamic>? _findById(List<Map<String, dynamic>> list, int id) {
    try {
      return list.firstWhere((e) => e['id'] == id);
    } catch (e) {
      return null;
    }
  }

  // Calculate electric charges for room and tenant for current year
  double _calculateElectricCharges(int roomId, int tenantId, int year) {
    // Sum consumption * unit price (example unit price = 10)
    const unitPrice = 10.0;
    final filteredReadings = readings.where(
      (r) =>
          r['room_id'] == roomId &&
          r['tenant_id'] == tenantId &&
          (r['created_at'] as DateTime).year == year,
    );
    final totalConsumption = filteredReadings.fold<double>(
      0,
      (sum, r) => sum + (r['consumption'] as num).toDouble(),
    );
    return totalConsumption * unitPrice;
  }

  void _openGenerateBillDialog() {
    int? selectedRoomId = _filterRoomId;
    int? selectedTenantId = _filterTenantId;
    double roomCharges = 0;
    double electricCharges = 0;
    final additionalChargesController = TextEditingController(text: '0');
    final additionalDescController = TextEditingController();

    Map<String, dynamic>? safeFirstWhere(
      List<Map<String, dynamic>> list,
      bool Function(Map<String, dynamic>) test,
    ) {
      for (final item in list) {
        if (test(item)) return item;
      }
      return null;
    }

    void updateTenantAndCharges() {
      if (selectedRoomId == null || selectedTenantId == null) {
        roomCharges = 0.0;
        electricCharges = 0.0;
        return;
      }

      final room = safeFirstWhere(rooms, (r) => r['id'] == selectedRoomId);
      final tenant = safeFirstWhere(
        tenants,
        (t) => t['id'] == selectedTenantId,
      );

      roomCharges = room != null ? (room['room_charges'] ?? 0.0) : 0.0;

      if (room != null && tenant != null) {
        electricCharges = _calculateElectricCharges(
          selectedRoomId!,
          selectedTenantId!,
          DateTime.now().year,
        );
      } else {
        electricCharges = 0.0;
      }
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
              // Initialize charges when dialog opens or selections change
              updateTenantAndCharges();

              return AlertDialog(
                title: Text('Generate New Bill'),
                content: SingleChildScrollView(
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
                        value: selectedRoomId,
                        items: [
                          DropdownMenuItem<int>(
                            value: null,
                            enabled: false,
                            child: Text('Select Room'),
                          ),
                          ...rooms.map(
                            (room) => DropdownMenuItem<int>(
                              value: room['id'],
                              child: Text(room['name']),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setStateDialog(() {
                            selectedRoomId = val;

                            // Reset tenant if tenant not in selected room
                            if (selectedTenantId != null) {
                              final tenant = safeFirstWhere(
                                tenants,
                                (t) => t['id'] == selectedTenantId,
                              );
                              if (tenant == null ||
                                  tenant['room_id'] != selectedRoomId) {
                                selectedTenantId = null;
                              }
                            }

                            updateTenantAndCharges();
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
                        value: selectedTenantId,
                        items:
                            selectedRoomId == null
                                ? [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    enabled: false,
                                    child: Text('Select Tenant'),
                                  ),
                                ]
                                : [
                                  DropdownMenuItem<int>(
                                    value: null,
                                    enabled: false,
                                    child: Text('Select Tenant'),
                                  ),
                                  ...tenants
                                      .where(
                                        (t) => t['room_id'] == selectedRoomId,
                                      )
                                      .map(
                                        (tenant) => DropdownMenuItem<int>(
                                          value: tenant['id'],
                                          child: Text(tenant['name']),
                                        ),
                                      )
                                      .toList(),
                                ],
                        onChanged: (val) {
                          setStateDialog(() {
                            selectedTenantId = val;

                            if (selectedTenantId != null) {
                              final tenantRoomId =
                                  safeFirstWhere(
                                    tenants,
                                    (t) => t['id'] == selectedTenantId,
                                  )?['room_id'];

                              if (selectedRoomId != tenantRoomId) {
                                selectedRoomId = tenantRoomId;
                              }
                            }

                            updateTenantAndCharges();
                          });
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Room Charges',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: roomCharges.toStringAsFixed(2),
                        enabled: false,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Electric Charges',
                          border: OutlineInputBorder(),
                        ),
                        initialValue: electricCharges.toStringAsFixed(2),
                        enabled: false,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: additionalChargesController,
                        decoration: InputDecoration(
                          labelText: 'Additional Charges',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                          signed: false,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: additionalDescController,
                        decoration: InputDecoration(
                          labelText: 'Additional Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      additionalChargesController.dispose();
                      additionalDescController.dispose();
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    child: Text('Generate Bill'),
                    onPressed: () {
                      if (selectedRoomId == null || selectedTenantId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Please select room and tenant'),
                          ),
                        );
                        return;
                      }

                      double additionalCharges =
                          double.tryParse(additionalChargesController.text) ??
                          0;

                      final newBill = {
                        'id': bills.length + 1,
                        'room_id': selectedRoomId,
                        'tenant_id': selectedTenantId,
                        'room_charges': roomCharges,
                        'electric_charges': electricCharges,
                        'additional_charges': additionalCharges,
                        'additional_description': additionalDescController.text,
                        'total_amount':
                            roomCharges + electricCharges + additionalCharges,
                        'created_at': DateTime.now(),
                      };

                      setState(() {
                        bills.add(newBill);
                      });

                      additionalChargesController.dispose();
                      additionalDescController.dispose();
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Bill generated successfully')),
                      );
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showBillingDetailsDialog(Map<String, dynamic> bill) {
    showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 400, // Set max width for nice centering and readability
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
                      'Billing Details',
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
                      _getTenantName(bill['tenant_id']),
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow('Room', _getRoomName(bill['room_id'])),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Room Charges',
                      '₱${(bill['room_charges'] as double).toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Electric Charges',
                      '₱${(bill['electric_charges'] as double).toStringAsFixed(2)}',
                    ),
                    if ((bill['additional_charges'] as double) > 0) ...[
                      SizedBox(height: 12),
                      _buildDetailRow(
                        'Additional Charges',
                        '₱${(bill['additional_charges'] as double).toStringAsFixed(2)}',
                      ),
                    ],
                    if ((bill['additional_description'] as String)
                        .isNotEmpty) ...[
                      SizedBox(height: 12),
                      _buildDetailRow('Notes', bill['additional_description']),
                    ],
                    SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Total Amount',
                      '₱${(bill['total_amount'] as double).toStringAsFixed(2)}',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Date',
                      DateFormat('yyyy-MM-dd').format(bill['created_at']),
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
    final years =
        bills.map((b) => (b['created_at'] as DateTime).year).toSet().toList()
          ..sort();

    return Scaffold(
      appBar: CustomAppBar(title: 'Billing'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Filters Row
            Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
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
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text('All Rooms'),
                        ),
                        ...rooms.map(
                          (room) => DropdownMenuItem(
                            value: room['id'],
                            child: Text(room['name']),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _filterRoomId = val;
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
                    padding: const EdgeInsets.only(left: 8),
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
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text('All Tenants'),
                        ),
                        ..._filteredTenants.map(
                          (tenant) => DropdownMenuItem(
                            value: tenant['id'],
                            child: Text(tenant['name']),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _filterTenantId = val;
                          if (val != null) {
                            final tenantRoomId =
                                tenants.firstWhere(
                                  (t) => t['id'] == val,
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
                SizedBox(width: 12),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'Filter by Year',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                      ),
                      value: _filterYear,
                      items: [
                        DropdownMenuItem<int>(
                          value: null,
                          child: Text('All Years'),
                        ),
                        ...years.map(
                          (y) => DropdownMenuItem(
                            value: y,
                            child: Text(y.toString()),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _filterYear = val;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 20),

            Expanded(
              child:
                  _filteredBills.isEmpty
                      ? Center(
                        child: Text('No bills found for selected filters'),
                      )
                      : SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: DataTable(
                          showCheckboxColumn: false,
                          columns: const [
                            DataColumn(label: Text('Room')),
                            DataColumn(label: Text('Tenant')),
                            DataColumn(label: Text('Room Charges')),
                            DataColumn(label: Text('Electric Charges')),
                            DataColumn(label: Text('Additional Charges')),
                            DataColumn(label: Text('Notes')),
                            DataColumn(label: Text('Total')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows:
                              _filteredBills.map((bill) {
                                final room = _findById(rooms, bill['room_id']);
                                final tenant = _findById(
                                  tenants,
                                  bill['tenant_id'],
                                );

                                return DataRow(
                                  onSelectChanged: (_) {
                                    _showBillingDetailsDialog(bill);
                                  },
                                  cells: [
                                    DataCell(
                                      Text(room?['name'] ?? 'Unknown Room'),
                                    ),
                                    DataCell(
                                      Text(tenant?['name'] ?? 'Unknown Tenant'),
                                    ),
                                    DataCell(
                                      Text(
                                        '₱${(bill['room_charges'] as double).toStringAsFixed(2)}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₱${(bill['electric_charges'] as double).toStringAsFixed(2)}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (bill['additional_charges'] as double) >
                                                0
                                            ? '₱${bill['additional_charges'].toStringAsFixed(2)}'
                                            : '-',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (bill['additional_description']
                                                    as String)
                                                .isNotEmpty
                                            ? bill['additional_description']
                                            : '-',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        '₱${(bill['total_amount'] as double).toStringAsFixed(2)}',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        DateFormat(
                                          'yyyy-MM-dd',
                                        ).format(bill['created_at']),
                                      ),
                                    ),
                                    DataCell(
                                      Row(
                                        children: [
                                          IconButton(
                                            tooltip: 'Edit Bill',
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.blue,
                                            ),
                                            onPressed: () {
                                              // Your edit handler here
                                            },
                                          ),
                                          IconButton(
                                            tooltip: 'Delete Bill',
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed: () {
                                              // Your delete handler here
                                            },
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
        onPressed: _openGenerateBillDialog,
        label: 'Generate New Bill',
      ),
    );
  }
}
