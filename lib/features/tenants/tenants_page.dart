import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_state.dart';
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
import 'package:rental_management_system_flutter/utils/error_widget.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  late AuthBloc authBloc;
  late TenantBloc tenantBloc;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    tenantBloc = context.read<TenantBloc>();
  }

  Future<void> _showTenantDialog({Tenant? tenant, required List<Room> rooms}) async {
    final result = await showDialog<Map<String, dynamic>?>(context: context, builder: (_) => TenantFormDialog(tenant: tenant, rooms: rooms));

    if (!mounted) return;
    if (result == null) return;

    final newTenant = Tenant(
      id: tenant?.id,
      name: result['name'] as String,
      roomId: result['roomId'] as int,
      joinDate: result['joinDate'] as DateTime,
    );

    if (tenant != null) {
      tenantBloc.add(UpdateTenantEvent(newTenant));
    } else {
      tenantBloc.add(AddTenant(newTenant));
    }
  }

  Future<void> _confirmDelete(Tenant tenant) async {
    final messenger = ScaffoldMessenger.of(context);
    await showConfirmationAction(
      context: context,
      messenger: messenger,
      confirmTitle: 'Confirm Deletion',
      confirmContent: 'Are you sure you want to delete this tenant?',
      onConfirmed: () async {
        await _deleteTenant(tenant.id!);
      },
    );
  }

  Future<void> _deleteTenant(int id) async {
    final completer = Completer<void>();
    tenantBloc.add(DeleteTenant(id, onComplete: completer));
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;

    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is Unauthenticated) {
          return buildErrorWidget(context: context, message: authState.message);
        }

        return Theme(
          data: theme,
          child: Scaffold(
            appBar: const CustomAppBar(title: 'Tenants'),
            body: BlocListener<TenantBloc, TenantState>(
              listener: (context, state) {
                if (state is TenantError) {
                  CustomSnackbar.show(context, state.message, type: SnackBarType.error);
                } else if (state is AddSuccess) {
                  CustomSnackbar.show(context, 'Tenant created', type: SnackBarType.success);
                } else if (state is UpdateSuccess) {
                  CustomSnackbar.show(context, 'Tenant updated', type: SnackBarType.success);
                } else if (state is DeleteSuccess) {
                  CustomSnackbar.show(context, 'Tenant deleted', type: SnackBarType.success);
                }
              },
              child: BlocBuilder<TenantBloc, TenantState>(
                builder: (context, state) {
                  if (state is TenantLoading || state is TenantInitial) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TenantError) {
                    return buildErrorWidget(context: context, message: state.message, onRetry: () => tenantBloc.add(LoadTenants()));
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
            ),
            floatingActionButton: CustomAddButton(
              onPressed: () {
                final state = tenantBloc.state;
                if (state is TenantLoaded) {
                  _showTenantDialog(rooms: state.rooms);
                }
              },
              label: 'New Tenant',
            ),
          ),
        );
      },
    );
  }
}
