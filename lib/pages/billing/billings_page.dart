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
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';
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
          _filterRoomId == null ||
          _getRoomIdByTenantId(bill.tenantId) == _filterRoomId;
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

  void _showBillDialog({Bill? bill}) {
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
        appBar: const CustomAppBar(title: 'Billing'),
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
                                children: [
                                  _buildRoomFilter(),
                                  const SizedBox(height: 12),
                                  _buildTenantFilter(),
                                  const SizedBox(height: 12),
                                  _buildYearFilter(),
                                ],
                              )
                              : Row(
                                children: [
                                  Expanded(child: _buildRoomFilter()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTenantFilter()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildYearFilter()),
                                ],
                              ),
                          const SizedBox(height: 12),
                          Expanded(child: _buildBillTable()),
                        ],
                      ),
            ),
          ),
        ),
        floatingActionButton: CustomAddButton(
          onPressed: () => _showBillDialog(bill: null),
          label: 'Generate New Bill',
        ),
      ),
    );
  }

  Widget _buildRoomFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomDropdownForm<int>(
        label: 'Filter by Room',
        items: [
          DropdownMenuItem(value: null, child: Text('All Rooms')),
          ...rooms.map(
            (room) => DropdownMenuItem(value: room.id, child: Text(room.name)),
          ),
        ],
        value: _filterRoomId,
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

  Widget _buildTenantFilter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomDropdownForm<int>(
        label: 'Filter by Tenant',
        hint: 'Choose a tenant',
        items: [
          DropdownMenuItem(
            value: null,
            enabled: false,
            child: Text('Choose a tenant'),
          ),
          ...tenants
              .where((t) => _filterRoomId == null || t.roomId == _filterRoomId)
              .map(
                (tenant) => DropdownMenuItem(
                  value: tenant.id,
                  child: Text(tenant.name),
                ),
              ),
        ],
        value: _filterTenantId,
        onChanged: (value) {
          setState(() {
            _filterTenantId = value;
            if (value != null) {
              final tenant = tenants.firstWhere((t) => t.id == value);
              if (_filterRoomId != tenant.roomId) {
                _filterRoomId = tenant.roomId;
              }
            }
          });
        },
      ),
    );
  }

  Widget _buildYearFilter() {
    final years = bills.map((b) => b.createdAt.year).toSet().toList()..sort();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: CustomDropdownForm<int>(
        label: 'Filter by Year',
        items: [
          const DropdownMenuItem<int>(value: null, child: Text('All Years')),
          ...years.map(
            (y) => DropdownMenuItem(value: y, child: Text(y.toString())),
          ),
        ],
        value: _filterYear,
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
                          onPressed: () => _showBillDialog(bill: bill),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await showConfirmationAction(
                              context: context,
                              messenger: ScaffoldMessenger.of(context),
                              confirmTitle: 'Confirm Deletion',
                              confirmContent:
                                  'Are you sure you want to delete this bill?',
                              loadingMessage: 'Deleting...',
                              successMessage: 'Bill deleted',
                              failureMessage: 'Failed to delete bill',
                              onConfirmed: () async {
                                _deleteBill(bill.id);
                              },
                            );
                          },
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
