import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

class BillingFormDialog extends StatefulWidget {
  final Bill? bill;
  final List<Room> rooms;
  final List<Tenant> tenants;
  final List<Reading> readings;
  final BillingService billingService;
  final void Function(Bill) onSubmit;
  final int? selectedRoomId;
  final int? selectedTenantId;

  const BillingFormDialog({
    super.key,
    required this.bill,
    required this.rooms,
    required this.tenants,
    required this.readings,
    required this.billingService,
    required this.onSubmit,
    required this.selectedRoomId,
    required this.selectedTenantId,
  });

  @override
  State<BillingFormDialog> createState() => _BillingFormDialogState();
}

class _BillingFormDialogState extends State<BillingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomChargesController = TextEditingController();
  final _electricChargesController = TextEditingController();
  final _additionalChargesController = TextEditingController();
  final _additionalDescController = TextEditingController();

  static const int electricityRate = 17;
  int? _selectedRoomId;
  int? _selectedTenantId;

  @override
  void initState() {
    super.initState();
    final bill = widget.bill;
    if (bill != null) {
      final tenant = widget.tenants.firstWhere((t) => t.id == bill.tenantId);
      _selectedTenantId = tenant.id;
      _selectedRoomId = tenant.roomId;
      _roomChargesController.text = bill.roomCharges.toString();
      _electricChargesController.text = bill.electricCharges.toString();
      _additionalChargesController.text = bill.additionalCharges.toString();
      _additionalDescController.text = bill.additionalDescription ?? '';
    } else {
      _selectedRoomId = widget.selectedRoomId;
      _selectedTenantId = widget.selectedTenantId;
      _roomChargesController.clear();
      _electricChargesController.clear();
      _additionalChargesController.clear();
      _additionalDescController.clear();
      _updateCharges();
    }
  }

  @override
  void dispose() {
    _roomChargesController.dispose();
    _electricChargesController.dispose();
    _additionalChargesController.dispose();
    _additionalDescController.dispose();
    super.dispose();
  }

  Reading? _getLatestReading(int? roomId, int? tenantId) {
    if (roomId == null || tenantId == null) return null;

    final readings =
        widget.readings
            .where((r) => r.roomId == roomId && r.tenantId == tenantId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return readings.isNotEmpty ? readings.first : null;
  }

  void _updateCharges() {
    if (_selectedRoomId == null || _selectedTenantId == null) {
      _roomChargesController.text = '';
      _electricChargesController.text = '';
      return;
    }

    final room = widget.rooms.firstWhere(
      (r) => r.id == _selectedRoomId,
      orElse: () => Room(id: 0, name: '', rent: 0),
    );

    final roomCharges = room.rent.toInt();

    final electricConsumption =
        _getLatestReading(_selectedRoomId, _selectedTenantId)?.consumption ?? 0;

    final electricCharges = electricConsumption * electricityRate;

    _roomChargesController.text = roomCharges.toString();
    _electricChargesController.text = electricCharges.toString();
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }
    if (_selectedRoomId == null || _selectedTenantId == null) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          'Please select room and tenant',
          type: SnackBarType.error,
        );
      }
      return;
    }

    final reading = _getLatestReading(_selectedRoomId, _selectedTenantId);
    if (reading == null) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          'No reading found for this tenant',
          type: SnackBarType.error,
        );
      }
      return;
    }

    try {
      final bill =
          widget.bill == null
              ? await widget.billingService.createBill(
                readingId: reading.id,
                tenantId: _selectedTenantId!,
                roomCharges: int.tryParse(_roomChargesController.text) ?? 0,
                electricCharges:
                    int.tryParse(_electricChargesController.text) ?? 0,
                additionalCharges:
                    int.tryParse(_additionalChargesController.text) ?? 0,
                additionalDescription: _additionalDescController.text,
              )
              : await widget.billingService.updateBill(
                id: widget.bill!.id,
                readingId: reading.id,
                tenantId: _selectedTenantId!,
                roomCharges: int.tryParse(_roomChargesController.text) ?? 0,
                electricCharges:
                    int.tryParse(_electricChargesController.text) ?? 0,
                additionalCharges:
                    int.tryParse(_additionalChargesController.text) ?? 0,
                additionalDescription: _additionalDescController.text,
              );

      if (!mounted) return;
      widget.onSubmit(bill);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, 'Error: $e', type: SnackBarType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bill == null ? 'Generate Bill' : 'Update Bill'),
      content: _buildContent(),
      actions: _buildActions(context, widget.bill != null),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildRoomDropdown(),
          const SizedBox(height: 16),
          _buildTenantDropdown(),
          const SizedBox(height: 16),
          _buildRoomChargesField(),
          const SizedBox(height: 16),
          _buildElectricChargesField(),
          const SizedBox(height: 16),
          _buildAdditionalChargesField(),
          const SizedBox(height: 16),
          _buildAdditionalDescField(),
        ],
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isEditing) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _submitForm,
        child: Text(widget.bill == null ? 'Generate Bill' : 'Update Bill'),
      ),
    ];
  }

  Widget _buildRoomDropdown() {
    return CustomDropdownForm<int?>(
      label: 'Select Room',
      value: _selectedRoomId,
      items: [
        const DropdownMenuItem<int?>(value: null, child: Text('All Rooms')),
        ...widget.rooms.map(
          (room) =>
              DropdownMenuItem<int?>(value: room.id, child: Text(room.name)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedRoomId = value;

          if (_selectedTenantId != null) {
            final tenant = widget.tenants.firstWhereOrNull(
              (t) => t.id == _selectedTenantId,
            );
            if (tenant == null || tenant.roomId != _selectedRoomId) {
              _selectedTenantId = null;
            }
          }
          _updateCharges();
        });
      },
    );
  }

  Widget _buildTenantDropdown() {
    return CustomDropdownForm<int?>(
      label: 'Select Tenant',
      hint: 'Choose a tenant',
      value: _selectedTenantId,
      items: [
        const DropdownMenuItem<int?>(
          value: null,
          enabled: false,
          child: Text('Choose a tenant'),
        ),
        ...widget.tenants
            .where(
              (t) => _selectedRoomId == null || t.roomId == _selectedRoomId,
            )
            .map(
              (tenant) => DropdownMenuItem<int?>(
                value: tenant.id,
                child: Text(tenant.name),
              ),
            ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedTenantId = value;

          if (_selectedTenantId != null) {
            final tenantRoomId =
                widget.tenants
                    .firstWhere((t) => t.id == _selectedTenantId)
                    .roomId;
            if (_selectedRoomId != tenantRoomId) {
              _selectedRoomId = tenantRoomId;
            }
          }
          _updateCharges();
        });
      },
      validator: (value) => value == null ? 'Please choose a tenant' : null,
    );
  }

  Widget _buildRoomChargesField() {
    return CustomTextFormField(
      controller: _roomChargesController,
      labelText: 'Room Charges',
      enabled: false,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          '₱',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildElectricChargesField() {
    return CustomTextFormField(
      controller: _electricChargesController,
      labelText: 'Electric Charges',
      enabled: false,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          '₱',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAdditionalChargesField() {
    return CustomTextFormField(
      controller: _additionalChargesController,
      labelText: 'Additional Charges',
      keyboardType: TextInputType.number,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text(
          '₱',
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return null;

        final parsed = int.tryParse(value);
        if (parsed == null || parsed < 0) {
          return 'Enter a valid number';
        }
        return null;
      },
    );
  }

  Widget _buildAdditionalDescField() {
    return CustomTextFormField(
      controller: _additionalDescController,
      labelText: 'Additional Description',
      keyboardType: TextInputType.text,
      prefixIcon: const Icon(Icons.description),
      validator: (value) {
        if (value != null && value.trim().isNotEmpty && value.length > 200) {
          return 'Description too long';
        }
        return null;
      },
    );
  }
}
