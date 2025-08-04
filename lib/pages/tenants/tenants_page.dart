import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/pages/tenants/widgets/tenant_card.dart';
import 'package:rental_management_system_flutter/pages/tenants/widgets/tenant_form_dialog.dart';
import 'package:rental_management_system_flutter/services/room_service.dart';
import 'package:rental_management_system_flutter/services/tenant_service.dart';
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
  final TenantService _tenantService = TenantService();
  final RoomService _roomService = RoomService();

  List<Tenant> _tenants = [];
  List<Room> _rooms = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final tenants = await _tenantService.fetchTenants();
      final rooms = await _roomService.fetchRooms();
      if (!mounted) return;
      setState(() {
        _tenants = tenants;
        _rooms = rooms;
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

  void _showTenantDialog({Tenant? tenant}) {
    showDialog(
      context: context,
      builder:
          (_) => TenantFormDialog(
            tenant: tenant,
            rooms: _rooms,
            onSubmit: (name, roomId, joinDate) async {
              try {
                if (mounted) {
                  CustomSnackbar.show(
                    context,
                    tenant != null ? 'Updating...' : 'Creating...',
                    type: SnackBarType.loading,
                    dismissPrevious: true,
                  );
                }
                if (tenant != null) {
                  await _tenantService.updateTenant(
                    tenant.id,
                    name,
                    roomId,
                    joinDate,
                  );
                  if (mounted) {
                    CustomSnackbar.show(
                      context,
                      'Tenant updated',
                      type: SnackBarType.success,
                    );
                  }
                } else {
                  await _tenantService.createTenant(name, roomId, joinDate);
                  if (mounted) {
                    CustomSnackbar.show(
                      context,
                      'Tenant "$name" added',
                      type: SnackBarType.success,
                    );
                  }
                }
                await _loadData();
              } catch (e) {
                if (mounted) {
                  CustomSnackbar.show(
                    context,
                    'Operation failed',
                    type: SnackBarType.error,
                  );
                }
              } finally {
                if (mounted) CustomSnackbar.hide(context);
              }
            },
          ),
    );
  }

  Future<void> _deleteTenant(int id) async {
    await _tenantService.deleteTenant(id);
    if (!mounted) return;
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.lightTheme;
    return Theme(
      data: theme,
      child: Scaffold(
        appBar: const CustomAppBar(title: 'Tenants'),
        body:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxWidth =
                        constraints.maxWidth > 600 ? 600 : constraints.maxWidth;
                    return Center(
                      child: Container(
                        width: maxWidth,
                        padding: const EdgeInsets.all(16),
                        child:
                            _tenants.isEmpty
                                ? _buildNoTenantsMessage()
                                : _buildTenantList(),
                      ),
                    );
                  },
                ),
        floatingActionButton: CustomAddButton(
          onPressed: () => _showTenantDialog(),
          label: 'New Tenant',
        ),
      ),
    );
  }

  Widget _buildNoTenantsMessage() {
    return const Center(child: Text('No tenants available.'));
  }

  Widget _buildTenantList() {
    return ListView.builder(
      itemCount: _tenants.length,
      itemBuilder: (context, index) {
        final tenant = _tenants[index];
        final room = _rooms.firstWhere(
          (r) => r.id == tenant.roomId,
          orElse: () => Room(id: -1, name: 'Unknown', rent: 0),
        );
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TenantCard(
            tenant: tenant,
            room: room,
            onEdit: () => _showTenantDialog(tenant: tenant),
            onDelete: () async {
              await showConfirmationAction(
                context: context,
                confirmTitle: 'Confirm Deletion',
                confirmContent: 'Are you sure you want to delete this tenant?',
                loadingMessage: 'Deleting...',
                successMessage: 'Tenant deleted',
                failureMessage: 'Failed to delete tenant',
                onConfirmed: () async {
                  await _deleteTenant(tenant.id);
                },
              );
            },
          ),
        );
      },
    );
  }
}
