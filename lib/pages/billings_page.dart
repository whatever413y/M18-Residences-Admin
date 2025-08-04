import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';

class BillingsPage extends StatefulWidget {
  @override
  BillingsPageState createState() => BillingsPageState();
}

class BillingsPageState extends State<BillingsPage> {
  final TenantService _tenantService = TenantService();
  final RoomService _roomService = RoomService();
  final ReadingService _readingService = ReadingService();
  final BillingService _billingService = BillingService();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  final int electricityRate = 17;

  List<Room> rooms = [];
  List<Tenant> tenants = [];
  List<Reading> readings = [];
  List<Bill> bills = [];

  int? _filterRoomId;
  int? _filterTenantId;
  int? _filterYear;
  int? _selectedRoomId;
  int? _selectedTenantId;

  final _roomChargesController = TextEditingController();
  final _electricChargesController = TextEditingController();
  final _additionalChargesController = TextEditingController(text: '0');
  final _additionalDescController = TextEditingController();

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
      final fetchedBills = await _billingService.fetchBills();
      setState(() {
        tenants = fetchedTenants;
        rooms = fetchedRooms;
        readings = fetchedReadings;
        bills = fetchedBills;
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

  void _deleteBill(int id) async {
    await _billingService.deleteBill(id);
    setState(() => bills.removeWhere((b) => b.id == id));
    _showSnackBar('Bill deleted');
  }

  List<Bill> get _filteredBills {
    return bills.where((bill) {
      final matchRoom =
          _filterRoomId == null || bill.roomCharges == _filterRoomId;
      final matchTenant =
          _filterTenantId == null || bill.tenantId == _filterTenantId;
      final matchYear =
          _filterYear == null || bill.createdAt.year == _filterYear;
      return matchRoom && matchTenant && matchYear;
    }).toList();
  }

  Room? _findRoomById(int id) => rooms.firstWhereOrNull((r) => r.id == id);
  Tenant? _findTenantById(int id) =>
      tenants.firstWhereOrNull((t) => t.id == id);

  String _getRoomName(int id) => _findRoomById(id)?.name ?? 'Unknown Room';
  String _getTenantName(int id) =>
      _findTenantById(id)?.name ?? 'Unknown Tenant';
  int? _getRoomIdByTenantId(int tenantId) {
    final tenant = _findTenantById(tenantId);
    return tenant?.roomId;
  }

  Reading? _getLatestReading(int roomId, int tenantId) {
    final filtered =
        readings
            .where((r) => r.roomId == roomId && r.tenantId == tenantId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.isNotEmpty ? filtered.first : null;
  }

  int _calculateElectricCharges(int roomId, int tenantId, int electricityRate) {
    final reading = _getLatestReading(roomId, tenantId);
    return reading != null ? reading.consumption * electricityRate : 0;
  }

  void _updateCharges() {
    if (_selectedRoomId != null && _selectedTenantId != null) {
      final room = _findRoomById(_selectedRoomId!);
      final roomCharges = room?.rent.toDouble() ?? 0;

      final electricCharges = _calculateElectricCharges(
        _selectedRoomId!,
        _selectedTenantId!,
        electricityRate,
      );

      _roomChargesController.text = roomCharges.toString();
      _electricChargesController.text = electricCharges.toString();
    } else {
      _roomChargesController.clear();
      _electricChargesController.clear();
    }
  }

  void _openBillDialog({Bill? bill}) {
    if (bill != null) {
      final roomId = _getRoomIdByTenantId(bill.tenantId);
      _selectedRoomId = roomId;
      _selectedTenantId = bill.tenantId;
      _roomChargesController.text = bill.roomCharges.toString();
      _electricChargesController.text = bill.electricCharges.toString();
      _additionalChargesController.text = bill.additionalCharges.toString();
      _additionalDescController.text = bill.additionalDescription ?? '';
    } else {
      _selectedRoomId = _filterRoomId;
      _selectedTenantId = _filterTenantId;
      _updateCharges();
    }

    showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder: (context, setStateDialog) {
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
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        value: _selectedRoomId,
                        items: [
                          DropdownMenuItem(
                            value: null,
                            child: Text('All Room'),
                          ),
                          ...rooms.map(
                            (room) => DropdownMenuItem(
                              value: room.id,
                              child: Text(room.name),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          setStateDialog(() {
                            _selectedRoomId = val;
                            if (_selectedTenantId != null) {
                              final tenant = tenants.firstWhereOrNull(
                                (t) => t.id == _selectedTenantId,
                              );
                              if (tenant == null ||
                                  tenant.roomId != _selectedRoomId) {
                                _selectedTenantId = null;
                              }
                            }
                            _updateCharges();
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

                        onChanged: (val) {
                          setStateDialog(() {
                            _selectedTenantId = val;
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
                          });
                          _updateCharges();
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _roomChargesController,
                        decoration: InputDecoration(
                          labelText: 'Room Charges',
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _electricChargesController,
                        decoration: InputDecoration(
                          labelText: 'Electric Charges',
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _additionalChargesController,
                        decoration: InputDecoration(
                          labelText: 'Additional Charges',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _additionalDescController,
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
                      _additionalChargesController.dispose();
                      _additionalDescController.dispose();
                      Navigator.pop(context);
                    },
                  ),
                  ElevatedButton(
                    child: Text('Generate Bill'),
                    onPressed: () async {
                      if (_selectedRoomId == null ||
                          _selectedTenantId == null) {
                        _showSnackBar('Please select room and tenant');
                        return;
                      }

                      final latestReading = _getLatestReading(
                        _selectedRoomId!,
                        _selectedTenantId!,
                      );

                      if (latestReading == null) {
                        _showSnackBar(
                          'No reading found for selected room and tenant',
                        );
                        return;
                      }

                      int additionalCharges =
                          int.tryParse(_additionalChargesController.text) ?? 0;

                      try {
                        if (bill == null) {
                          final newBill = await _billingService.createBill(
                            readingId: latestReading.id,
                            tenantId: _selectedTenantId!,
                            roomCharges:
                                int.tryParse(_roomChargesController.text) ?? 0,
                            electricCharges:
                                int.tryParse(_electricChargesController.text) ??
                                0,
                            additionalCharges: additionalCharges,
                            additionalDescription:
                                _additionalDescController.text,
                          );
                          setState(() {
                            bills.add(newBill);
                          });
                          _showSnackBar('Bill generated successfully');
                        } else {
                          final updatedBill = await _billingService.updateBill(
                            id: bill.id,
                            tenantId: _selectedTenantId!,
                            readingId: latestReading.id,
                            roomCharges:
                                int.tryParse(_roomChargesController.text) ?? 0,
                            electricCharges:
                                int.tryParse(_electricChargesController.text) ??
                                0,
                            additionalCharges: additionalCharges,
                            additionalDescription:
                                _additionalDescController.text,
                          );
                          setState(() {
                            final index = bills.indexWhere(
                              (b) => b.id == updatedBill.id,
                            );
                            if (index != -1) bills[index] = updatedBill;
                          });
                          _showSnackBar('Bill updated successfully');
                        }
                        _additionalChargesController.clear();
                        _additionalDescController.clear();

                        Navigator.of(context).pop();
                      } catch (e) {
                        _showSnackBar('Failed to generate bill: $e');
                      }
                    },
                  ),
                ],
              );
            },
          ),
    );
  }

  void _showBillingDetailsDialog(Bill bill) {
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
                    _buildDetailRow('Tenant', _getTenantName(bill.tenantId)),
                    SizedBox(height: 12),
                    _buildDetailRow('Room', _getRoomName(bill.tenantId)),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Consumption',
                      '${_getLatestReading(_getRoomIdByTenantId(bill.tenantId)!, bill.tenantId)?.consumption} kWh',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Electric Charges',
                      '₱${(bill.electricCharges).toString()}',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Room Charges',
                      '₱${(bill.roomCharges).toString()}',
                    ),
                    if (bill.additionalCharges! > 0) ...[
                      SizedBox(height: 12),
                      _buildDetailRow(
                        'Additional Charges',
                        '₱${(bill.additionalCharges).toString()}',
                      ),
                    ],
                    if ((bill.additionalDescription ?? '').isNotEmpty) ...[
                      SizedBox(height: 12),
                      _buildDetailRow('Notes', bill.additionalDescription!),
                    ],
                    SizedBox(height: 12),
                    Divider(color: Colors.grey.shade300, thickness: 1),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Total Amount',
                      '₱${(bill.totalAmount).toString()}',
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      'Date',
                      DateFormat('yyyy-MM-dd').format(bill.createdAt),
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
    final years = bills.map((b) => b.createdAt.year).toSet().toList()..sort();

    return Scaffold(
      appBar: CustomAppBar(title: 'Billing'),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
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
                    padding: const EdgeInsets.only(left: 8),
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
                        DropdownMenuItem<int>(
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
                              (tenant) => DropdownMenuItem<int>(
                                value: tenant.id,
                                child: Text(tenant.name),
                              ),
                            ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _filterTenantId = val;
                          if (val != null) {
                            final tenantRoomId =
                                tenants.firstWhere((t) => t.id == val).roomId;
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
                        hintText: 'Choose a year',
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
                          enabled: false,
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
                            DataColumn(label: Text('Consumption (kWh)')),
                            DataColumn(label: Text('Electric Charges (₱)')),
                            DataColumn(label: Text('Room Charges (₱)')),
                            DataColumn(label: Text('Additional Charges (₱)')),
                            DataColumn(label: Text('Notes')),
                            DataColumn(label: Text('Total (₱)')),
                            DataColumn(label: Text('Date')),
                            DataColumn(label: Text('Actions')),
                          ],
                          rows:
                              _filteredBills.map((bill) {
                                final roomId = _getRoomIdByTenantId(
                                  bill.tenantId,
                                );
                                return DataRow(
                                  onSelectChanged: (_) {
                                    _showBillingDetailsDialog(bill);
                                  },
                                  cells: [
                                    DataCell(Text(_getRoomName(roomId!))),
                                    DataCell(
                                      Text(_getTenantName(bill.tenantId)),
                                    ),
                                    DataCell(
                                      Text(
                                        _getLatestReading(
                                              roomId,
                                              bill.tenantId,
                                            )?.consumption.toString() ??
                                            '0',
                                      ),
                                    ),
                                    DataCell(
                                      Text(bill.electricCharges.toString()),
                                    ),
                                    DataCell(Text(bill.roomCharges.toString())),
                                    DataCell(
                                      Text(
                                        bill.additionalCharges! > 0
                                            ? bill.additionalCharges.toString()
                                            : '-',
                                      ),
                                    ),
                                    DataCell(
                                      Text(
                                        (bill
                                                    .additionalDescription
                                                    ?.isNotEmpty ??
                                                false)
                                            ? bill.additionalDescription!
                                            : '-',
                                      ),
                                    ),
                                    DataCell(Text(bill.totalAmount.toString())),
                                    DataCell(
                                      Text(_dateFormat.format(bill.createdAt)),
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
                                                () =>
                                                    _openBillDialog(bill: bill),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                            onPressed:
                                                () => _deleteBill(bill.id),
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
        onPressed: () => _openBillDialog(bill: null),
        label: 'Generate New Bill',
      ),
    );
  }
}
