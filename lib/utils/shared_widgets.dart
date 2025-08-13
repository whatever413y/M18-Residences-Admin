import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_event.dart';
import 'package:rental_management_system_flutter/features/auth/auth_state.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';

Widget buildActiveToggleFilter({
  required bool showActiveOnly,
  required ValueChanged<bool> onChanged,
  Color activeColor = Colors.white,
  TextStyle labelStyle = const TextStyle(color: Colors.white),
}) {
  return Row(children: [Text('Show Active Only', style: labelStyle), Switch(value: showActiveOnly, onChanged: onChanged, activeColor: activeColor)]);
}

Widget buildRoomFilter({
  required List<Room> rooms,
  required List<Tenant> tenants,
  required int? selectedRoomId,
  required int? selectedTenantId,
  required void Function(int? roomId, int? tenantId) onFilterChanged,
  String? label,
}) {
  return CustomDropdownForm<int>(
    label: label ?? 'Filter by Room',
    items: [
      const DropdownMenuItem(value: null, child: Text('All Rooms')),
      ...rooms.map((room) => DropdownMenuItem(value: room.id, child: Text(room.name))),
    ],
    value: selectedRoomId,
    onChanged: (value) {
      int? newRoomId = value;
      int? newTenantId = selectedTenantId;

      if (newRoomId == null) {
        newTenantId = null;
      } else if (newTenantId != null) {
        final tenant = tenants.firstWhereOrNull((t) => t.id == newTenantId);
        if (tenant == null || tenant.roomId != newRoomId) {
          newTenantId = null;
        }
      }
      onFilterChanged(newRoomId, newTenantId);
    },
  );
}

Widget buildTenantFilter({
  required List<Tenant> tenants,
  required List<Reading> readings,
  required int? selectedRoomId,
  required int? selectedTenantId,
  required bool showActiveOnly,
  required void Function(int? tenantId, int? roomId) onFilterChanged,
  String? label,
}) {
  final filteredTenants =
      tenants.where((t) {
        final matchesRoom = selectedRoomId == null || t.roomId == selectedRoomId;
        final matchesActive = !showActiveOnly || t.isActive;
        return matchesRoom && matchesActive;
      }).toList();

  return CustomDropdownForm<int>(
    label: label ?? 'Filter by Tenant',
    hint: 'Choose a tenant',
    items: [
      const DropdownMenuItem(value: null, enabled: false, child: Text('Choose a tenant')),
      ...filteredTenants.map((tenant) => DropdownMenuItem(value: tenant.id, child: Text(tenant.name))),
    ],
    value: selectedTenantId,
    onChanged: (value) {
      int? newTenantId = value;
      int? newRoomId = selectedRoomId;

      if (newTenantId != null) {
        final tenant = tenants.firstWhere((t) => t.id == newTenantId);
        if (newRoomId != tenant.roomId) {
          newRoomId = tenant.roomId;
        }
      }

      onFilterChanged(newTenantId, newRoomId);
    },
    validator: (value) => value == null ? 'Please choose a tenant' : null,
  );
}

Widget buildYearFilter({required List<Reading> readings, required int? selectedYear, required ValueChanged<int?> onYearChanged}) {
  final years = readings.map((r) => r.createdAt!.year).toSet().toList()..sort();

  return CustomDropdownForm<int>(
    label: 'Filter by Year',
    items: [
      const DropdownMenuItem(value: null, child: Text('All Years')),
      ...years.map((year) => DropdownMenuItem(value: year, child: Text(year.toString()))),
    ],
    value: selectedYear,
    onChanged: onYearChanged,
  );
}

Widget buildMonthFilter({required List<Reading> readings, required int? selectedMonth, required ValueChanged<int?> onMonthChanged}) {
  final months = readings.map((r) => r.createdAt!.month).toSet().toList()..sort();

  return CustomDropdownForm<int>(
    label: 'Filter by Month',
    items: [
      const DropdownMenuItem(value: null, child: Text('All Months')),
      ...months.map((month) {
        final monthName = DateFormat.MMMM().format(DateTime(0, month));
        return DropdownMenuItem(value: month, child: Text(monthName));
      }),
    ],
    value: selectedMonth,
    onChanged: onMonthChanged,
  );
}

Widget buildReceipt(BuildContext context, String? tenantName, String? receiptUrl) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: InkWell(
      onTap: () {
        if (tenantName != null) {
          context.read<AuthBloc>().add(FetchReceiptUrl(tenantName, receiptUrl));
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: SizedBox(
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is ReceiptUrlLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ReceiptUrlLoaded) {
                        return InteractiveViewer(
                          child: Image.network(
                            state.url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) {
                              return const Padding(padding: EdgeInsets.all(20), child: Text('Failed to load image'));
                            },
                          ),
                        );
                      } else if (state is ReceiptUrlError) {
                        return Center(child: Text('Error loading receipt: ${state.message}'));
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              );
            },
          );
        }
      },
      child: Text(Uri.parse(receiptUrl!).pathSegments.last, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
    ),
  );
}
