import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';

import 'package:rental_management_system_flutter/pages/reading/bloc/reading_bloc.dart';
import 'package:rental_management_system_flutter/pages/reading/bloc/reading_event.dart';
import 'package:rental_management_system_flutter/pages/reading/bloc/reading_state.dart';

import 'package:rental_management_system_flutter/pages/reading/widgets/reading_details_dialog.dart';
import 'package:rental_management_system_flutter/pages/reading/widgets/reading_form_dialog.dart';

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
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  int? _filterRoomId;
  int? _filterTenantId;

  @override
  void initState() {
    super.initState();
    context.read<ReadingBloc>().add(LoadReadings());
  }

  List<Reading> _applyFilters(
    List<Reading> readings,
    int? filterRoomId,
    int? filterTenantId,
  ) {
    return readings.where((r) {
      final matchRoom = filterRoomId == null || r.roomId == filterRoomId;
      final matchTenant =
          filterTenantId == null || r.tenantId == filterTenantId;
      return matchRoom && matchTenant;
    }).toList();
  }

  Room? _findRoomById(List<Room> rooms, int id) =>
      rooms.firstWhereOrNull((r) => r.id == id);

  Tenant? _findTenantById(List<Tenant> tenants, int id) =>
      tenants.firstWhereOrNull((t) => t.id == id);

  String _getRoomName(List<Room> rooms, int id) =>
      _findRoomById(rooms, id)?.name ?? 'Unknown Room';

  String _getTenantName(List<Tenant> tenants, int id) =>
      _findTenantById(tenants, id)?.name ?? 'Unknown Tenant';

  void _deleteReading(int id) {
    context.read<ReadingBloc>().add(DeleteReading(id));
  }

  Future<void> _showReadingDialog({Reading? reading}) async {
    final bloc = context.read<ReadingBloc>();
    final state = bloc.state;

    if (state is! ReadingLoaded) return;

    final rooms = state.rooms;
    final tenants = state.tenants;
    final readings = state.readings;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder:
          (context) => ReadingFormDialog(
            selectedRoomId: _filterRoomId,
            selectedTenantId: _filterTenantId,
            reading: reading,
            rooms: rooms,
            tenants: tenants,
            readings: readings,
            readingService: bloc.readingService,
          ),
    );

    if (!mounted || result == null) return;

    CustomSnackbar.show(
      context,
      reading != null ? 'Updating...' : 'Creating...',
      type: SnackBarType.loading,
    );

    try {
      if (reading != null) {
        bloc.add(
          UpdateReading(
            Reading(
              id: reading.id,
              roomId: result['roomId'] as int,
              tenantId: result['tenantId'] as int,
              currReading: result['currReading'] as int,
              prevReading: result['prevReading'] as int,
            ),
          ),
        );
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          'Reading updated',
          type: SnackBarType.success,
        );
      } else {
        bloc.add(
          AddReading(
            Reading(
              roomId: result['roomId'] as int,
              tenantId: result['tenantId'] as int,
              currReading: result['currReading'] as int,
              prevReading: result['prevReading'] as int,
            ),
          ),
        );
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          'Reading added',
          type: SnackBarType.success,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        'Operation failed',
        type: SnackBarType.error,
      );
    }
  }

  void _showReadingDetailsDialog(
    Reading reading,
    List<Room> rooms,
    List<Tenant> tenants,
  ) {
    showDialog(
      context: context,
      builder:
          (context) => ReadingDetailsDialog(
            reading: reading,
            getTenantName: (id) => _getTenantName(tenants, id),
            getRoomName: (id) => _getRoomName(rooms, id),
            dateFormat: _dateFormat,
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
        appBar: const CustomAppBar(title: 'Electricity Readings'),
        body: BlocBuilder<ReadingBloc, ReadingState>(
          builder: (context, state) {
            if (state is ReadingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ReadingError) {
              return Center(child: Text(state.message));
            }

            if (state is ReadingLoaded) {
              final filteredReadings = _applyFilters(
                state.readings,
                _filterRoomId,
                _filterTenantId,
              );

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<ReadingBloc>().add(LoadReadings());
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 16,
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        isNarrow
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildRoomFilter(state.rooms, state.tenants),
                                const SizedBox(height: 12),
                                _buildTenantFilter(state.tenants),
                              ],
                            )
                            : Row(
                              children: [
                                Expanded(
                                  child: _buildRoomFilter(
                                    state.rooms,
                                    state.tenants,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildTenantFilter(state.tenants),
                                ),
                              ],
                            ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: _buildReadingsTable(
                            filteredReadings,
                            state.rooms,
                            state.tenants,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: BlocBuilder<ReadingBloc, ReadingState>(
          builder: (context, state) {
            if (state is ReadingLoaded) {
              return CustomAddButton(
                onPressed: () => _showReadingDialog(reading: null),
                label: 'New Reading',
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRoomFilter(List<Room> rooms, List<Tenant> tenants) {
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
              final tenant = _findTenantById(tenants, _filterTenantId!);

              if (tenant == null || tenant.roomId != _filterRoomId) {
                _filterTenantId = null;
              }
            }
          });
        },
      ),
    );
  }

  Widget _buildTenantFilter(List<Tenant> tenants) {
    final filteredTenants =
        tenants
            .where((t) => _filterRoomId == null || t.roomId == _filterRoomId)
            .toList();

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
          ...filteredTenants.map(
            (tenant) =>
                DropdownMenuItem(value: tenant.id, child: Text(tenant.name)),
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

  Widget _buildReadingsTable(
    List<Reading> readings,
    List<Room> rooms,
    List<Tenant> tenants,
  ) {
    if (readings.isEmpty) {
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
            readings.map((reading) {
              return DataRow(
                onSelectChanged:
                    (_) => _showReadingDetailsDialog(reading, rooms, tenants),
                cells: [
                  DataCell(Text(_getRoomName(rooms, reading.roomId))),
                  DataCell(Text(_getTenantName(tenants, reading.tenantId))),
                  DataCell(Text(reading.prevReading.toString())),
                  DataCell(Text(reading.currReading.toString())),
                  DataCell(Text(reading.consumption.toString())),
                  DataCell(Text(_dateFormat.format(reading.createdAt!))),
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
                              messenger: ScaffoldMessenger.of(context),
                              confirmTitle: 'Confirm Deletion',
                              confirmContent:
                                  'Are you sure you want to delete this reading?',
                              loadingMessage: 'Deleting...',
                              successMessage: 'Reading deleted',
                              failureMessage: 'Failed to delete reading',
                              onConfirmed: () async {
                                _deleteReading(reading.id!);
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
