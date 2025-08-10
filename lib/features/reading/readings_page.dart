import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_event.dart';
import 'package:rental_management_system_flutter/features/auth/auth_state.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/features/reading/bloc/reading_bloc.dart';
import 'package:rental_management_system_flutter/features/reading/bloc/reading_event.dart';
import 'package:rental_management_system_flutter/features/reading/bloc/reading_state.dart';
import 'package:rental_management_system_flutter/features/reading/widgets/reading_details_dialog.dart';
import 'package:rental_management_system_flutter/features/reading/widgets/reading_form_dialog.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';
import 'package:rental_management_system_flutter/utils/error_widget.dart';

class ReadingsPage extends StatefulWidget {
  const ReadingsPage({super.key});

  @override
  ReadingsPageState createState() => ReadingsPageState();
}

class ReadingsPageState extends State<ReadingsPage> {
  late AuthBloc authBloc;
  late ReadingBloc readingBloc;
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');

  int? _filterRoomId;
  int? _filterTenantId;
  int? _filterYear;
  int? _filterMonth;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthStatus());
    readingBloc = context.read<ReadingBloc>();
    readingBloc.add(LoadReadings());
  }

  List<Reading> _applyFilters(List<Reading> readings, int? filterRoomId, int? filterTenantId) {
    return readings.where((r) {
      final matchRoom = filterRoomId == null || r.roomId == filterRoomId;
      final matchTenant = filterTenantId == null || r.tenantId == filterTenantId;
      return matchRoom && matchTenant;
    }).toList();
  }

  Room? _findRoomById(List<Room> rooms, int id) => rooms.firstWhereOrNull((r) => r.id == id);

  Tenant? _findTenantById(List<Tenant> tenants, int id) => tenants.firstWhereOrNull((t) => t.id == id);

  String _getRoomName(List<Room> rooms, int id) => _findRoomById(rooms, id)?.name ?? 'Unknown Room';

  String _getTenantName(List<Tenant> tenants, int id) => _findTenantById(tenants, id)?.name ?? 'Unknown Tenant';

  Future<void> _deleteReading(int id) async {
    final completer = Completer<void>();
    readingBloc.add(DeleteReading(id, onComplete: completer));
    return completer.future;
  }

  Future<void> _showReadingDialog({Reading? reading}) async {
    final state = readingBloc.state;
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
            readingService: readingBloc.readingService,
          ),
    );

    if (!mounted || result == null) return;

    final newReading = Reading(
      id: reading?.id,
      roomId: result['roomId'] as int,
      tenantId: result['tenantId'] as int,
      currReading: result['currReading'] as int,
      prevReading: result['prevReading'] as int,
    );

    if (reading != null) {
      readingBloc.add(UpdateReading(newReading));
    } else {
      readingBloc.add(AddReading(newReading));
    }
  }

  void _showReadingDetailsDialog(Reading reading, List<Room> rooms, List<Tenant> tenants) {
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
  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 500;
    final horizontalPadding = screenWidth * 0.05;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: CustomAppBar(
          title: 'Electricity Readings',
          showRefresh: true,
          onRefresh: () {
            readingBloc.add(LoadReadings());
          },
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Unauthenticated) {
              return buildErrorWidget(context: context, message: authState.message);
            }

            return BlocListener<ReadingBloc, ReadingState>(
              listener: (context, state) {
                if (state is ReadingError) {
                  CustomSnackbar.show(context, state.message, type: SnackBarType.error);
                } else if (state is AddSuccess) {
                  CustomSnackbar.show(context, 'Reading created', type: SnackBarType.success);
                } else if (state is UpdateSuccess) {
                  CustomSnackbar.show(context, 'Reading updated', type: SnackBarType.success);
                } else if (state is DeleteSuccess) {
                  CustomSnackbar.show(context, 'Reading deleted', type: SnackBarType.success);
                }
              },
              child: BlocBuilder<ReadingBloc, ReadingState>(
                builder: (context, state) {
                  if (state is ReadingLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is ReadingError) {
                    return buildErrorWidget(context: context, message: state.message, onRetry: () => readingBloc.add(LoadReadings()));
                  }

                  if (state is ReadingLoaded) {
                    final filteredReadings = _applyFilters(state.readings, _filterRoomId, _filterTenantId);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isNarrow)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildRoomFilter(state.rooms, state.tenants),
                                  const SizedBox(height: 12),
                                  _buildTenantFilter(state.tenants),
                                  const SizedBox(height: 12),
                                  _buildYearFilter(state.readings),
                                  const SizedBox(height: 12),
                                  _buildMonthFilter(state.readings),
                                ],
                              )
                            else
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Expanded(child: _buildRoomFilter(state.rooms, state.tenants)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTenantFilter(state.tenants)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildYearFilter(state.readings)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildMonthFilter(state.readings)),
                                ],
                              ),
                            const SizedBox(height: 12),
                            Expanded(
                              child: RefreshIndicator(
                                onRefresh: () async {
                                  readingBloc.add(LoadReadings());
                                  await readingBloc.stream.firstWhere((s) => s is! ReadingLoading);
                                },
                                child: SingleChildScrollView(
                                  physics: const AlwaysScrollableScrollPhysics(),
                                  child: _buildReadingsTable(filteredReadings, state.rooms, state.tenants),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            );
          },
        ),
        floatingActionButton: BlocBuilder<ReadingBloc, ReadingState>(
          builder: (context, state) {
            if (state is ReadingLoaded) {
              return CustomAddButton(onPressed: () => _showReadingDialog(), label: 'New Reading');
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildRoomFilter(List<Room> rooms, List<Tenant> tenants) {
    return CustomDropdownForm<int>(
      label: 'Filter by Room',
      items: [
        DropdownMenuItem(value: null, child: Text('All Rooms')),
        ...rooms.map((room) => DropdownMenuItem(value: room.id, child: Text(room.name))),
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
    );
  }

  Widget _buildTenantFilter(List<Tenant> tenants) {
    final filteredTenants = tenants.where((t) => _filterRoomId == null || t.roomId == _filterRoomId).toList();

    return CustomDropdownForm<int>(
      label: 'Filter by Tenant',
      hint: 'Choose a tenant',
      items: [
        DropdownMenuItem(value: null, enabled: false, child: Text('Choose a tenant')),
        ...filteredTenants.map((tenant) => DropdownMenuItem(value: tenant.id, child: Text(tenant.name))),
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
    );
  }

  Widget _buildYearFilter(List<Reading> readings) {
    final years = readings.map((b) => b.createdAt!.year).toSet().toList()..sort();

    return CustomDropdownForm<int>(
      label: 'Filter by Year',
      items: [
        const DropdownMenuItem(value: null, child: Text('All Years')),
        ...years.map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))),
      ],
      value: _filterYear,
      onChanged: (val) {
        setState(() {
          _filterYear = val;
        });
      },
    );
  }

  Widget _buildMonthFilter(List<Reading> readings) {
    final months = readings.map((b) => b.createdAt!.month).toSet().toList()..sort();

    return CustomDropdownForm<int>(
      label: 'Filter by Month',
      items: [
        const DropdownMenuItem(value: null, child: Text('All Months')),
        ...months.map((month) {
          final monthName = DateFormat.MMMM().format(DateTime(0, month));
          return DropdownMenuItem(value: month, child: Text(monthName));
        }),
      ],
      value: _filterMonth,
      onChanged: (val) {
        setState(() {
          _filterMonth = val;
        });
      },
    );
  }

  Widget _buildReadingsTable(List<Reading> readings, List<Room> rooms, List<Tenant> tenants) {
    if (readings.isEmpty) {
      return const Center(child: Text('No readings found for the selected filters.'));
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
                onSelectChanged: (_) => _showReadingDetailsDialog(reading, rooms, tenants),
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
                        IconButton(icon: const Icon(Icons.edit, color: Colors.blue), onPressed: () => _showReadingDialog(reading: reading)),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            await showConfirmationAction(
                              context: context,
                              messenger: ScaffoldMessenger.of(context),
                              confirmTitle: 'Confirm Deletion',
                              confirmContent: 'Are you sure you want to delete this reading?',
                              onConfirmed: () async {
                                await _deleteReading(reading.id!);
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
