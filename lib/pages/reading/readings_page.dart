import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/pages/reading/widgets/reading_details_dialog.dart';
import 'package:rental_management_system_flutter/pages/reading/widgets/reading_form_dialog.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

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

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
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

  void _deleteReading(int id) async {
    await _readingService.deleteReading(id);
    if (!mounted) return;
    setState(() => readings.removeWhere((r) => r.id == id));
    await _loadData();
  }

  void _showReadingDialog({Reading? reading}) {
    showDialog(
      context: context,
      builder:
          (context) => ReadingFormDialog(
            reading: reading,
            rooms: rooms,
            tenants: tenants,
            readings: readings,
            readingService: _readingService,
            onSubmit: (updated) {
              if (mounted) {
                CustomSnackbar.show(
                  context,
                  reading != null ? 'Updating...' : 'Creating...',
                  type: SnackBarType.loading,
                  dismissPrevious: true,
                );
              }
              setState(() {
                if (reading == null) {
                  readings.add(updated);
                  CustomSnackbar.show(
                    context,
                    'Reading added',
                    type: SnackBarType.success,
                  );
                } else {
                  final index = readings.indexWhere((r) => r.id == updated.id);
                  if (index != -1) readings[index] = updated;
                  CustomSnackbar.show(
                    context,
                    'Reading updated',
                    type: SnackBarType.success,
                  );
                }
              });
            },
          ),
    );
  }

  void _showReadingDetailsDialog(Reading reading) {
    showDialog(
      context: context,
      builder:
          (context) => ReadingDetailsDialog(
            reading: reading,
            getTenantName: _getTenantName,
            getRoomName: _getRoomName,
            dateFormat: _dateFormat,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width;

    final bool isNarrow = screenWidth < 500;
    final horizontalPadding = screenWidth * 0.05; // 5% padding on sides

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Electricity Readings'),
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
                                ],
                              )
                              : Row(
                                children: [
                                  Expanded(child: _buildRoomFilter()),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTenantFilter()),
                                ],
                              ),
                          const SizedBox(height: 12),
                          Expanded(child: _buildReadingsTable()),
                        ],
                      ),
            ),
          ),
        ),
        floatingActionButton: CustomAddButton(
          onPressed: () => _showReadingDialog(reading: null),
          label: 'New Reading',
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

  Widget _buildReadingsTable() {
    if (_filteredReadings.isEmpty) {
      return const Center(
        child: Text('No readings found for the selected filters.'),
      );
    }

    return SingleChildScrollView(
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
                onSelectChanged: (_) => _showReadingDetailsDialog(reading),
                cells: [
                  DataCell(Text(_getRoomName(reading.roomId))),
                  DataCell(Text(_getTenantName(reading.tenantId))),
                  DataCell(Text(reading.prevReading.toString())),
                  DataCell(Text(reading.currReading.toString())),
                  DataCell(Text(reading.consumption.toString())),
                  DataCell(Text(_dateFormat.format(reading.createdAt))),
                  DataCell(
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () => _showReadingDialog(reading: reading),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await showConfirmationAction(
                              context: context,
                              confirmTitle: 'Confirm Deletion',
                              confirmContent:
                                  'Are you sure you want to delete this tenant?',
                              loadingMessage: 'Deleting...',
                              successMessage: 'Tenant deleted',
                              failureMessage: 'Failed to delete tenant',
                              onConfirmed: () async {
                                _deleteReading(reading.id);
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
