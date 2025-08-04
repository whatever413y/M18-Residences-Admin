import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/pages/billing/widgets/billing_details_dialog.dart';
import 'package:rental_management_system_flutter/pages/billing/widgets/billing_form_dialog.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

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

  bool _isLoading = false;

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
      if (mounted) {
        CustomSnackbar.show(
          context,
          'Failed to load data',
          type: SnackBarType.error,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _deleteBill(int id) async {
    await _billingService.deleteBill(id);
    if (!mounted) return;
    setState(() => bills.removeWhere((b) => b.id == id));
    await _loadData();
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

  void _openBillDialog({Bill? bill}) {
    showDialog(
      context: context,
      builder: (context) {
        return BillingFormDialog(
          selectedRoomId: _filterRoomId,
          selectedTenantId: _filterTenantId,
          bill: bill,
          rooms: rooms,
          tenants: tenants,
          readings: readings,
          billingService: _billingService,
          onSubmit: (updated) {
            if (mounted) {
              CustomSnackbar.show(
                context,
                bill != null ? 'Updating...' : 'Creating...',
                type: SnackBarType.loading,
                dismissPrevious: true,
              );
            }
            setState(() {
              if (bill == null) {
                bills.add(updated);
                CustomSnackbar.show(
                  context,
                  'Bill generated successfully',
                  type: SnackBarType.success,
                );
              } else {
                final index = bills.indexWhere((b) => b.id == updated.id);
                if (index != -1) bills[index] = updated;
                CustomSnackbar.show(
                  context,
                  'Bill updated',
                  type: SnackBarType.success,
                );
              }
            });
          },
        );
      },
    );
  }

  void _showBillingDetailsDialog(Bill bill) {
    final tenantName = _getTenantName(bill.tenantId);
    final roomName = _getRoomName(bill.tenantId);
    final consumption =
        _getLatestReading(
          _getRoomIdByTenantId(bill.tenantId)!,
          bill.tenantId,
        )?.consumption.toString() ??
        '0';

    final date = DateFormat('yyyy-MM-dd').format(bill.createdAt);

    showDialog(
      context: context,
      builder:
          (_) => BillingDetailsDialog(
            bill: bill,
            tenantName: tenantName,
            roomName: roomName,
            consumption: consumption,
            date: date,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isNarrow = screenWidth < 500;
    final horizontalPadding = screenWidth * 0.05;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(title: 'Billing'),
        body: RefreshIndicator(
          onRefresh: _loadData,
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 16,
              ),
              child:
                  _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : Column(
                        children: [
                          isNarrow
                              ? Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: _buildFiltersChildren(isNarrow),
                              )
                              : Row(children: _buildFiltersChildren(isNarrow)),
                          const SizedBox(height: 12),
                          Expanded(child: _buildBillTable()),
                        ],
                      ),
            ),
          ),
        ),
        floatingActionButton: CustomAddButton(
          onPressed: () => _openBillDialog(bill: null),
          label: 'Generate New Bill',
        ),
      ),
    );
  }

  List<Widget> _buildFiltersChildren(bool isNarrow) {
    if (isNarrow) {
      return [
        _buildRoomFilter(padding: const EdgeInsets.only(bottom: 12)),
        _buildTenantFilter(padding: const EdgeInsets.only(bottom: 12)),
        _buildYearFilter(padding: EdgeInsets.zero),
      ];
    } else {
      return [
        Expanded(
          child: _buildRoomFilter(padding: const EdgeInsets.only(left: 8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTenantFilter(padding: const EdgeInsets.only(left: 8)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildYearFilter(padding: const EdgeInsets.only(left: 8)),
        ),
      ];
    }
  }

  Widget _buildRoomFilter({EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Filter by Room',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        value: _filterRoomId,
        items: [
          const DropdownMenuItem<int>(value: null, child: Text('All Rooms')),
          ...rooms.map(
            (room) => DropdownMenuItem(value: room.id, child: Text(room.name)),
          ),
        ],
        onChanged: (value) {
          setState(() {
            _filterRoomId = value;
            if (_filterRoomId == null) {
              _filterTenantId = null;
            } else if (_filterTenantId != null) {
              final tenant = _findTenantById(_filterTenantId!);
              if (tenant == null || tenant.roomId != _filterRoomId) {
                _filterTenantId = null;
              }
            }
          });
        },
      ),
    );
  }

  Widget _buildTenantFilter({EdgeInsetsGeometry? padding}) {
    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Filter by Tenant',
          hintText: 'Choose a tenant',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        value: _filterTenantId,
        items: [
          const DropdownMenuItem<int>(
            value: null,
            enabled: false,
            child: Text('Choose a tenant'),
          ),
          ...tenants
              .where((t) => _filterRoomId == null || t.roomId == _filterRoomId)
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
    );
  }

  Widget _buildYearFilter({EdgeInsetsGeometry? padding}) {
    final years = bills.map((b) => b.createdAt.year).toSet().toList()..sort();

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: DropdownButtonFormField<int>(
        decoration: const InputDecoration(
          labelText: 'Filter by Year',
          hintText: 'Choose a year',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
        value: _filterYear,
        items: [
          const DropdownMenuItem<int>(
            value: null,
            enabled: false,
            child: Text('All Years'),
          ),
          ...years.map(
            (y) => DropdownMenuItem(value: y, child: Text(y.toString())),
          ),
        ],
        onChanged: (val) {
          setState(() {
            _filterYear = val;
          });
        },
      ),
    );
  }

  Widget _buildBillTable() {
    if (_filteredBills.isEmpty) {
      return const Center(child: Text('No bills found for selected filters'));
    }

    return SingleChildScrollView(
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
              final roomId = _getRoomIdByTenantId(bill.tenantId);
              return DataRow(
                onSelectChanged: (_) => _showBillingDetailsDialog(bill),
                cells: [
                  DataCell(Text(_getRoomName(roomId!))),
                  DataCell(Text(_getTenantName(bill.tenantId))),
                  DataCell(
                    Text(
                      _getLatestReading(
                            roomId,
                            bill.tenantId,
                          )?.consumption.toString() ??
                          '0',
                    ),
                  ),
                  DataCell(Text(bill.electricCharges.toString())),
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
                      (bill.additionalDescription?.isNotEmpty ?? false)
                          ? bill.additionalDescription!
                          : '-',
                    ),
                  ),
                  DataCell(Text(bill.totalAmount.toString())),
                  DataCell(Text(_dateFormat.format(bill.createdAt))),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _openBillDialog(bill: bill),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBill(bill.id),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }
}
