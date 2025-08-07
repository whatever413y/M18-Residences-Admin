import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/features/tenants/bloc/tenant_bloc.dart';
import 'package:rental_management_system_flutter/features/tenants/bloc/tenant_event.dart';
import 'package:rental_management_system_flutter/features/tenants/bloc/tenant_state.dart';
import 'package:rental_management_system_flutter/features/tenants/widgets/tenant_card.dart';
import 'package:rental_management_system_flutter/features/tenants/widgets/tenant_form_dialog.dart';
import 'package:rental_management_system_flutter/theme.dart';
import 'package:rental_management_system_flutter/utils/confirmation_action.dart';
import 'package:rental_management_system_flutter/utils/custom_add_button.dart';
import 'package:rental_management_system_flutter/utils/custom_app_bar.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

class TenantsPage extends StatefulWidget {
  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  Future<void> _showTenantDialog({Tenant? tenant, required List<Room> rooms}) async {
    final result = await showDialog<Map<String, dynamic>?>(context: context, builder: (_) => TenantFormDialog(tenant: tenant, rooms: rooms));

    if (!mounted) return;

    if (result == null) return;

    final bloc = context.read<TenantBloc>();

    CustomSnackbar.show(context, tenant != null ? 'Updating...' : 'Creating...', type: SnackBarType.loading);

    try {
      final newTenant = Tenant(
        id: tenant?.id,
        name: result['name'] as String,
        roomId: result['roomId'] as int,
        joinDate: result['joinDate'] as DateTime,
      );
      if (tenant != null) {
        bloc.add(UpdateTenantEvent(newTenant));
        if (!mounted) return;
        CustomSnackbar.show(context, 'Tenant updated', type: SnackBarType.success);
      } else {
        bloc.add(AddTenant(newTenant));
        if (!mounted) return;
        CustomSnackbar.show(context, 'Tenant "${result['name']}" added', type: SnackBarType.success);
      }
    } catch (_) {
      if (!mounted) return;
      CustomSnackbar.show(context, 'Operation failed', type: SnackBarType.error);
    }
  }

  Future<void> _confirmDelete(Tenant tenant) async {
    final messenger = ScaffoldMessenger.of(context);
    await showConfirmationAction(
      context: context,
      messenger: messenger,
      confirmTitle: 'Confirm Deletion',
      confirmContent: 'Are you sure you want to delete this tenant?',
      loadingMessage: 'Deleting...',
      successMessage: 'Tenant deleted',
      failureMessage: 'Failed to delete tenant',
      onConfirmed: () async {
        await _deleteTenant(tenant.id!);
      },
    );
  }

  Future<void> _deleteTenant(int id) async {
    final completer = Completer<void>();

    context.read<TenantBloc>().add(DeleteTenant(id, onComplete: completer));

    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Tenants'),
        body: BlocBuilder<TenantBloc, TenantState>(
          builder: (context, state) {
            if (state is TenantLoading || state is TenantInitial) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is TenantError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message, style: const TextStyle(color: Colors.red), textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.read<TenantBloc>().add(LoadTenants());
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh'),
                    ),
                  ],
                ),
              );
            } else if (state is TenantLoaded) {
              final tenants = state.tenants;
              final rooms = state.rooms;

              if (tenants.isEmpty) {
                return const Center(child: Text('No tenants available.'));
              }

              return LayoutBuilder(
                builder: (context, constraints) {
                  final maxWidth = MediaQuery.of(context).size.width * 0.6;

                  return Center(
                    child: Container(
                      width: maxWidth,
                      padding: const EdgeInsets.all(16),
                      child: ListView.builder(
                        itemCount: tenants.length,
                        itemBuilder: (context, index) {
                          final tenant = tenants[index];
                          final room = rooms.firstWhere((r) => r.id == tenant.roomId, orElse: () => Room(id: -1, name: 'Unknown', rent: 0));

                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: TenantCard(
                              tenant: tenant,
                              room: room,
                              onEdit: () => _showTenantDialog(tenant: tenant, rooms: rooms),
                              onDelete: () => _confirmDelete(tenant),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            }

            return const SizedBox();
          },
        ),

        floatingActionButton: CustomAddButton(
          onPressed: () {
            final state = context.read<TenantBloc>().state;
            if (state is TenantLoaded) {
              _showTenantDialog(rooms: state.rooms);
            }
          },
          label: 'New Tenant',
        ),
      ),
    );
  }
}
