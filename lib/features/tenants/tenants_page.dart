import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_bloc.dart';
import 'package:rental_management_system_flutter/features/auth/auth_event.dart';
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
import 'package:rental_management_system_flutter/utils/shared_widgets.dart';

class TenantsPage extends StatefulWidget {
  const TenantsPage({super.key});

  @override
  State<TenantsPage> createState() => _TenantsPageState();
}

class _TenantsPageState extends State<TenantsPage> {
  late AuthBloc authBloc;
  late TenantBloc tenantBloc;
  bool _showActiveOnly = true;

  @override
  void initState() {
    super.initState();
    authBloc = context.read<AuthBloc>();
    authBloc.add(CheckAuthStatus());
    tenantBloc = context.read<TenantBloc>();
    tenantBloc.add(LoadTenants());
  }

  Future<void> _showTenantDialog({Tenant? tenant, required List<Room> rooms, bool isEditing = false}) async {
    final result = await showDialog<Map<String, dynamic>?>(
      context: context,
      builder: (_) => TenantFormDialog(tenant: tenant, rooms: rooms, isEditing: isEditing),
    );

    if (!mounted) return;
    if (result == null) return;

    final newTenant = Tenant(
      id: tenant?.id,
      name: result['name'] as String,
      roomId: result['roomId'] as int,
      joinDate: result['joinDate'] as DateTime,
      isActive: result['isActive'] as bool,
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
            appBar: CustomAppBar(
              title: 'Tenants',
              showRefresh: true,
              onRefresh: () {
                tenantBloc.add(LoadTenants());
              },
              actions: [
                buildActiveToggleFilter(
                  showActiveOnly: _showActiveOnly,
                  onChanged: (val) {
                    setState(() {
                      _showActiveOnly = val;
                      tenantBloc.add(LoadTenants());
                    });
                  },
                ),
                const SizedBox(width: 8),
              ],
            ),
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
                  }

                  if (state is TenantError) {
                    return buildErrorWidget(context: context, message: state.message, onRetry: () => tenantBloc.add(LoadTenants()));
                  }

                  if (state is TenantLoaded) {
                    return _buildTenantList(context, state.tenants, state.rooms);
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

  Widget _buildTenantList(BuildContext context, List<Tenant> tenants, List<Room> rooms) {
    if (tenants.isEmpty) {
      return const Center(child: Text('No tenants available.'));
    }

    final filteredTenants = _showActiveOnly ? tenants.where((tenant) => tenant.isActive).toList() : tenants;

    final maxWidth = MediaQuery.of(context).size.width * 0.6;

    return LayoutBuilder(
      builder:
          (context, constraints) => Center(
            child: Container(
              width: maxWidth,
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: () async {
                        tenantBloc.add(LoadTenants());
                        await tenantBloc.stream.firstWhere((state) => state is! TenantLoading);
                      },
                      child: ListView.separated(
                        itemCount: filteredTenants.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final tenant = filteredTenants[index];
                          final room = rooms.firstWhere((r) => r.id == tenant.roomId, orElse: () => Room(id: -1, name: 'Unknown', rent: 0));

                          return TenantCard(
                            tenant: tenant,
                            room: room,
                            onEdit: () => _showTenantDialog(tenant: tenant, rooms: rooms, isEditing: true),
                            onDelete: () => _confirmDelete(tenant),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
