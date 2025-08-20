import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';
import 'package:m18_residences_admin/features/auth/auth_bloc.dart';
import 'package:m18_residences_admin/features/auth/auth_event.dart';
import 'package:m18_residences_admin/features/auth/auth_state.dart';
import 'package:m18_residences_admin/models/reading.dart';
import 'package:m18_residences_admin/models/room.dart';
import 'package:m18_residences_admin/models/tenant.dart';
import 'package:m18_residences_admin/features/reading/bloc/reading_bloc.dart';
import 'package:m18_residences_admin/features/reading/bloc/reading_event.dart';
import 'package:m18_residences_admin/features/reading/bloc/reading_state.dart';
import 'package:m18_residences_admin/features/reading/widgets/reading_details_dialog.dart';
import 'package:m18_residences_admin/features/reading/widgets/reading_form_dialog.dart';
import 'package:m18_residences_admin/theme.dart';
import 'package:m18_residences_admin/utils/confirmation_action.dart';
import 'package:m18_residences_admin/utils/custom_add_button.dart';
import 'package:m18_residences_admin/utils/custom_app_bar.dart';
import 'package:m18_residences_admin/utils/custom_snackbar.dart';
import 'package:m18_residences_admin/utils/error_widget.dart';
import 'package:m18_residences_admin/utils/shared_widgets.dart';

class ReadingsPage extends StatefulWidget {
  const ReadingsPage({super.key});

  @override
  ReadingsPageState createState() => ReadingsPageState();
}

class ReadingsPageState extends State<ReadingsPage> {
  late AuthBloc authBloc;
  late ReadingBloc readingBloc;
  final DateFormat _dateFormat = DateFormat('MMM d, yyyy');
  bool _showActiveOnly = true;

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

  List<Reading> _applyFilters(List<Reading> readings, int? filterRoomId, int? filterYear, int? filterMonth, int? filterTenantId) {
    return readings.where((r) {
      final matchRoom = filterRoomId == null || r.roomId == filterRoomId;
      final matchYear = filterYear == null || r.createdAt!.year == filterYear;
      final matchMonth = filterMonth == null || r.createdAt!.month == filterMonth;
      final matchTenant = filterTenantId == null || r.tenantId == filterTenantId;
      return matchRoom && matchYear && matchMonth && matchTenant;
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
            showActiveOnly: _showActiveOnly,
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
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isNarrow = screenWidth < 600;
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
          actions: [
            buildActiveToggleFilter(
              showActiveOnly: _showActiveOnly,
              onChanged: (val) {
                setState(() {
                  _showActiveOnly = val;
                  readingBloc.add(LoadReadings());
                });
              },
            ),
            const SizedBox(width: 8),
          ],
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
                    authBloc.add(CheckAuthStatus());
                    return buildErrorWidget(context: context, message: state.message, onRetry: () => readingBloc.add(LoadReadings()));
                  }

                  if (state is ReadingLoaded) {
                    final filteredReadings = _applyFilters(state.readings, _filterRoomId, _filterYear, _filterMonth, _filterTenantId);
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            if (isNarrow)
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: _buildRoomFilter(state.rooms, state.tenants)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildTenantFilter(state.tenants, state.readings)),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(child: _buildMonthFilter(state.readings)),
                                      const SizedBox(width: 12),
                                      Expanded(child: _buildYearFilter(state.readings)),
                                    ],
                                  ),
                                ],
                              )
                            else
                              Row(
                                children: [
                                  Expanded(child: _buildRoomFilter(state.rooms, state.tenants)),
                                  const SizedBox(width: 12),
                                  Expanded(child: _buildTenantFilter(state.tenants, state.readings)),
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
    return buildRoomFilter(
      rooms: rooms,
      tenants: tenants,
      selectedRoomId: _filterRoomId,
      selectedTenantId: _filterTenantId,
      onFilterChanged: (roomId, tenantId) {
        setState(() {
          _filterRoomId = roomId;
          _filterTenantId = tenantId;
        });
      },
    );
  }

  Widget _buildTenantFilter(List<Tenant> tenants, List<Reading> readings) {
    return buildTenantFilter(
      tenants: tenants,
      readings: readings,
      selectedRoomId: _filterRoomId,
      selectedTenantId: _filterTenantId,
      showActiveOnly: _showActiveOnly,
      onFilterChanged: (tenantId, roomId) {
        setState(() {
          _filterTenantId = tenantId;
          _filterRoomId = roomId;
        });
      },
    );
  }

  Widget _buildYearFilter(List<Reading> readings) {
    return buildYearFilter(
      readings: readings,
      selectedYear: _filterYear,
      onYearChanged: (val) {
        setState(() {
          _filterYear = val;
        });
      },
    );
  }

  Widget _buildMonthFilter(List<Reading> readings) {
    return buildMonthFilter(
      readings: readings,
      selectedMonth: _filterMonth,
      onMonthChanged: (val) {
        setState(() {
          _filterMonth = val;
        });
      },
    );
  }

  Widget _buildReadingsTable(List<Reading> readings, List<Room> rooms, List<Tenant> tenants) {
    final filteredReadings =
        readings.where((reading) {
          if (!_showActiveOnly) return true;

          try {
            final tenant = tenants.firstWhere((t) => t.id == reading.tenantId);
            return tenant.isActive;
          } catch (e) {
            return false;
          }
        }).toList();

    if (filteredReadings.isEmpty) {
      return const Center(child: Text('No readings found for the selected filters.'));
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        showCheckboxColumn: false,
        columns: const [
          DataColumn(label: Text('Actions')),
          DataColumn(label: Text('Room')),
          DataColumn(label: Text('Tenant')),
          DataColumn(label: Text('Previous (kWh)')),
          DataColumn(label: Text('Current (kWh)')),
          DataColumn(label: Text('Consumption (kWh)')),
          DataColumn(label: Text('Date')),
        ],
        rows:
            filteredReadings.map((reading) {
              return DataRow(
                onSelectChanged: (_) => _showReadingDetailsDialog(reading, rooms, tenants),
                cells: [
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
                  DataCell(Text(_getRoomName(rooms, reading.roomId))),
                  DataCell(Text(_getTenantName(tenants, reading.tenantId))),
                  DataCell(Text(reading.prevReading.toString())),
                  DataCell(Text(reading.currReading.toString())),
                  DataCell(Text(reading.consumption.toString())),
                  DataCell(Text(_dateFormat.format(reading.createdAt!))),
                ],
              );
            }).toList(),
      ),
    );
  }
}
