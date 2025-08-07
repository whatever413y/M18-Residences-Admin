import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/features/billing/bloc/billing_bloc.dart';
import 'package:rental_management_system_flutter/features/billing/bloc/billing_event.dart';
import 'package:rental_management_system_flutter/features/billing/bloc/billing_state.dart';
import 'package:rental_management_system_flutter/features/billing/widgets/billing_details_dialog.dart';
import 'package:rental_management_system_flutter/features/billing/widgets/billing_form_dialog.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

class BillingsPage extends StatefulWidget {
  @override
  BillingsPageState createState() => BillingsPageState();
}

class BillingsPageState extends State<BillingsPage> {
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  int? _filterRoomId;
  int? _filterTenantId;
  int? _filterYear;

  BillingService get _billingService => context.read<BillingBloc>().billingService;

  @override
  void initState() {
    super.initState();
    context.read<BillingBloc>().add(LoadBills());
  }

  List<Bill> _applyFilters(List<Bill> bills, int? filterRoomId, int? filterTenantId, int? filterYear, List<Tenant> tenants) {
    return bills.where((bill) {
      final tenant = tenants.firstWhereOrNull((t) => t.id == bill.tenantId);
      final matchRoom = filterRoomId == null || tenant?.roomId == filterRoomId;
      final matchTenant = filterTenantId == null || bill.tenantId == filterTenantId;
      final matchYear = filterYear == null || bill.createdAt!.year == filterYear;
      return matchRoom && matchTenant && matchYear;
    }).toList();
  }

  Room? _findRoomById(List<Room> rooms, int id) => rooms.firstWhereOrNull((r) => r.id == id);

  Tenant? _findTenantById(List<Tenant> tenants, int id) => tenants.firstWhereOrNull((t) => t.id == id);

  Reading? _getLatestReading(List<Reading> readings, int roomId, int tenantId) {
    final filtered =
        readings.where((r) => r.roomId == roomId && r.tenantId == tenantId).toList()..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return filtered.isNotEmpty ? filtered.first : null;
  }

  Future<void> _showBillingDialog({Bill? bill, required List<Room> rooms, required List<Tenant> tenants, required List<Reading> readings}) async {
    final bloc = context.read<BillingBloc>();
    final state = bloc.state;

    if (state is! BillingLoaded) return;

    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder:
          (context) => BillingFormDialog(
            bill: bill,
            selectedRoomId: _filterRoomId,
            selectedTenantId: _filterTenantId,
            rooms: rooms,
            tenants: tenants,
            readings: readings,
            billingService: _billingService,
          ),
    );

    if (!mounted || result == null) return;

    CustomSnackbar.show(context, bill != null ? 'Updating...' : 'Creating...', type: SnackBarType.loading);

    try {
      final newBill = Bill(
        id: bill?.id,
        tenantId: result['tenantId'] as int,
        readingId: result['readingId'] as int,
        roomCharges: result['roomCharges'] as int,
        electricCharges: result['electricCharges'] as int,
        additionalCharges: result['additionalCharges'] as int? ?? 0,
        additionalDescription: result['additionalDescription'] as String?,
      );

      if (bill != null) {
        bloc.add(UpdateBill(newBill));
        if (!mounted) return;
        CustomSnackbar.show(context, 'Bill updated', type: SnackBarType.success);
      } else {
        bloc.add(AddBill(newBill));
        if (!mounted) return;
        CustomSnackbar.show(
          context,
          'Bill for tenant "${_findTenantById(tenants, newBill.tenantId)?.name ?? 'Tenant'}" added',
          type: SnackBarType.success,
        );
      }
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(context, 'Operation failed', type: SnackBarType.error);
    }
  }

  Future<void> _deleteBill(int id) async {
    final completer = Completer<void>();

    context.read<BillingBloc>().add(DeleteBill(id, onComplete: completer));

    return completer.future;
  }

  void _showBillingDetailsDialog(Bill bill, List<Room> rooms, List<Tenant> tenants, List<Reading> readings) {
    final tenant = _findTenantById(tenants, bill.tenantId);
    final room = tenant != null ? _findRoomById(rooms, tenant.roomId) : null;

    final consumption = _getLatestReading(readings, tenant?.roomId ?? 0, bill.tenantId)?.consumption.toString() ?? '0';

    final date = _dateFormat.format(bill.createdAt!);

    showDialog(
      context: context,
      builder:
          (_) => BillingDetailsDialog(
            bill: bill,
            tenantName: tenant?.name ?? 'Unknown Tenant',
            roomName: room?.name ?? 'Unknown Room',
            consumption: consumption,
            date: date,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final horizontalPadding = screenWidth * 0.05;
    final isNarrow = screenWidth < 500;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Billing'),
        body: BlocBuilder<BillingBloc, BillingState>(
          builder: (context, state) {
            if (state is BillingLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is BillingError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<BillingBloc>().add(LoadBills());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            }

            if (state is BillingLoaded) {
              final rooms = state.rooms;
              final tenants = state.tenants;
              final readings = state.readings;
              final bills = _applyFilters(state.bills, _filterRoomId, _filterTenantId, _filterYear, tenants);

              return RefreshIndicator(
                onRefresh: () async => context.read<BillingBloc>().add(LoadBills()),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
                  child: Column(
                    children: [
                      isNarrow
                          ? Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildRoomFilter(rooms, tenants),
                              const SizedBox(height: 12),
                              _buildTenantFilter(tenants),
                              const SizedBox(height: 12),
                              _buildYearFilter(state.bills),
                            ],
                          )
                          : Row(
                            children: [
                              Expanded(child: _buildRoomFilter(rooms, tenants)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildTenantFilter(tenants)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildYearFilter(state.bills)),
                            ],
                          ),
                      const SizedBox(height: 12),
                      Expanded(
                        child:
                            bills.isEmpty
                                ? const Center(child: Text('No bills found'))
                                : SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: DataTable(
                                    showCheckboxColumn: false,
                                    columns: const [
                                      DataColumn(label: Text('Room')),
                                      DataColumn(label: Text('Tenant')),
                                      DataColumn(label: Text('Consumption')),
                                      DataColumn(label: Text('Electric Charges')),
                                      DataColumn(label: Text('Room Charges')),
                                      DataColumn(label: Text('Additional')),
                                      DataColumn(label: Text('Notes')),
                                      DataColumn(label: Text('Total')),
                                      DataColumn(label: Text('Date')),
                                      DataColumn(label: Text('Actions')),
                                    ],
                                    rows:
                                        bills.map((bill) {
                                          final tenant = _findTenantById(tenants, bill.tenantId);
                                          final room = tenant != null ? _findRoomById(rooms, tenant.roomId) : null;

                                          return DataRow(
                                            onSelectChanged: (_) => _showBillingDetailsDialog(bill, rooms, tenants, readings),
                                            cells: [
                                              DataCell(Text(room?.name ?? '-')),
                                              DataCell(Text(tenant?.name ?? '-')),
                                              DataCell(
                                                Text(_getLatestReading(readings, tenant?.roomId ?? 0, bill.tenantId)?.consumption.toString() ?? '0'),
                                              ),
                                              DataCell(Text(bill.electricCharges.toString())),
                                              DataCell(Text(bill.roomCharges.toString())),
                                              DataCell(Text(bill.additionalCharges?.toString() ?? '-')),
                                              DataCell(Text(bill.additionalDescription?.isNotEmpty == true ? bill.additionalDescription! : '-')),
                                              DataCell(Text(bill.totalAmount.toString())),
                                              DataCell(Text(_dateFormat.format(bill.createdAt!))),
                                              DataCell(
                                                Row(
                                                  children: [
                                                    IconButton(
                                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                                      onPressed:
                                                          () => _showBillingDialog(bill: bill, rooms: rooms, tenants: tenants, readings: readings),
                                                    ),
                                                    IconButton(
                                                      icon: const Icon(Icons.delete, color: Colors.red),
                                                      onPressed:
                                                          () => showConfirmationAction(
                                                            context: context,
                                                            messenger: ScaffoldMessenger.of(context),
                                                            confirmTitle: 'Delete Bill',
                                                            confirmContent: 'Are you sure you want to delete this bill?',
                                                            loadingMessage: 'Deleting...',
                                                            successMessage: 'Bill deleted',
                                                            failureMessage: 'Failed to delete bill',
                                                            onConfirmed: () async {
                                                              await _deleteBill(bill.id!);
                                                            },
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
              );
            }

            return const SizedBox(); // fallback
          },
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            final state = context.read<BillingBloc>().state;
            if (state is BillingLoaded) {
              _showBillingDialog(bill: null, rooms: state.rooms, tenants: state.tenants, readings: state.readings);
            }
          },
          label: const Text('Generate New Bill'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildRoomFilter(List<Room> rooms, List<Tenant> tenants) {
    return CustomDropdownForm<int>(
      label: 'Filter by Room',
      items: [
        const DropdownMenuItem(value: null, child: Text('All Rooms')),
        ...rooms.map((room) => DropdownMenuItem(value: room.id, child: Text(room.name))),
      ],
      value: _filterRoomId,
      onChanged: (value) {
        setState(() {
          _filterRoomId = value;
          if (_filterRoomId == null) {
            _filterTenantId = null;
          } else if (_filterTenantId != null) {
            final tenant = tenants.firstWhereOrNull((t) => t.id == _filterTenantId);
            if (tenant == null || tenant.roomId != _filterRoomId) {
              _filterTenantId = null;
            }
          }
        });
      },
    );
  }

  Widget _buildTenantFilter(List<Tenant> tenants) {
    return CustomDropdownForm<int>(
      label: 'Filter by Tenant',
      hint: 'Choose a tenant',
      items: [
        DropdownMenuItem(value: null, enabled: false, child: Text('Choose a tenant')),
        ...tenants.map((tenant) => DropdownMenuItem(value: tenant.id, child: Text(tenant.name))),
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

  Widget _buildYearFilter(List<Bill> bills) {
    final years = bills.map((b) => b.createdAt!.year).toSet().toList()..sort();

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
}
