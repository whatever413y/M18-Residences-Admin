import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';
import 'package:rental_management_system_flutter/utils/shared_widgets.dart';

class AdditionalChargeInput {
  int amount;
  String description;

  AdditionalChargeInput({this.amount = 0, this.description = ''});
}

class BillingFormDialog extends StatefulWidget {
  final Bill? bill;
  final List<Room> rooms;
  final List<Tenant> tenants;
  final List<Reading> readings;
  final BillingService billingService;
  final int? selectedRoomId;
  final int? selectedTenantId;
  final bool showActiveOnly;

  const BillingFormDialog({
    super.key,
    required this.bill,
    required this.rooms,
    required this.tenants,
    required this.readings,
    required this.billingService,
    required this.showActiveOnly,
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

  List<AdditionalChargeInput> _additionalCharges = [];
  List<TextEditingController> _additionalChargeControllers = [];
  List<TextEditingController> _additionalDescControllers = [];

  static const int electricityRate = 17;

  int? _selectedRoomId;
  int? _selectedTenantId;

  @override
  void initState() {
    super.initState();

    final bill = widget.bill;

    if (bill != null && bill.additionalCharges != null && bill.additionalCharges!.isNotEmpty) {
      _additionalCharges = bill.additionalCharges!.map((e) => AdditionalChargeInput(amount: e.amount, description: e.description)).toList();
    } else {
      _additionalCharges = [AdditionalChargeInput()];
    }

    _additionalChargeControllers = _additionalCharges.map((e) => TextEditingController(text: e.amount.toString())).toList();

    _additionalDescControllers = _additionalCharges.map((e) => TextEditingController(text: e.description)).toList();

    if (bill != null) {
      final tenant = widget.tenants.firstWhere((t) => t.id == bill.tenantId);
      _selectedTenantId = tenant.id;
      _selectedRoomId = tenant.roomId;
      _roomChargesController.text = bill.roomCharges.toString();
      _electricChargesController.text = bill.electricCharges.toString();
    } else {
      _selectedRoomId = widget.selectedRoomId;
      _selectedTenantId = widget.selectedTenantId;
      _updateCharges();
    }
  }

  @override
  void dispose() {
    _roomChargesController.dispose();
    _electricChargesController.dispose();

    for (final c in _additionalChargeControllers) {
      c.dispose();
    }
    for (final c in _additionalDescControllers) {
      c.dispose();
    }

    super.dispose();
  }

  Reading? _getLatestReading(int? roomId, int? tenantId) {
    if (roomId == null || tenantId == null) return null;

    final filteredReadings =
        widget.readings.where((r) => r.roomId == roomId && r.tenantId == tenantId).toList()..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));

    return filteredReadings.isNotEmpty ? filteredReadings.first : null;
  }

  void _updateCharges() {
    if (_selectedRoomId == null || _selectedTenantId == null) {
      _roomChargesController.clear();
      _electricChargesController.clear();
      return;
    }

    final room = widget.rooms.firstWhere((r) => r.id == _selectedRoomId, orElse: () => Room(id: 0, name: '', rent: 0));

    final roomCharges = room.rent.toInt();
    final electricConsumption = _getLatestReading(_selectedRoomId, _selectedTenantId)?.consumption ?? 0;
    final electricCharges = electricConsumption * electricityRate;

    _roomChargesController.text = roomCharges.toString();
    _electricChargesController.text = electricCharges.toString();
  }

  void _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final reading = _getLatestReading(_selectedRoomId, _selectedTenantId);
    if (reading == null) {
      if (context.mounted) {
        CustomSnackbar.show(context, 'No reading found for this tenant', type: SnackBarType.error);
      }
      return;
    }

    final additionalCharges = <Map<String, dynamic>>[];

    for (var i = 0; i < _additionalCharges.length; i++) {
      final amountText = _additionalChargeControllers[i].text.trim();
      if (amountText.isEmpty) continue;

      final amount = int.tryParse(amountText) ?? 0;
      final description = _additionalDescControllers[i].text.trim();

      additionalCharges.add({'amount': amount, 'description': description});
    }

    Navigator.of(context).pop({
      'readingId': reading.id,
      'tenantId': _selectedTenantId,
      'roomCharges': int.tryParse(_roomChargesController.text) ?? 0,
      'electricCharges': int.tryParse(_electricChargesController.text) ?? 0,
      'additionalCharges': additionalCharges,
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.6;

    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      title: Text(widget.bill == null ? 'Generate Bill' : 'Update Bill'),
      content: SizedBox(width: screenWidth, child: _buildContent()),
      actions: _buildActions(context, widget.bill != null),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRoomDropdown(),
            const SizedBox(height: 16),
            _buildTenantDropdown(),
            const SizedBox(height: 16),
            _buildRoomChargesField(),
            const SizedBox(height: 16),
            _buildElectricChargesField(),
            const SizedBox(height: 16),
            _buildAdditionalChargesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalChargesList() {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Column(
      children: [
        ...List.generate(_additionalCharges.length, (index) {
          final fields = [
            Expanded(
              flex: 3,
              child: CustomTextFormField(
                controller: _additionalChargeControllers[index],
                labelText: 'Additional Charge',
                keyboardType: const TextInputType.numberWithOptions(signed: false),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('₱', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                validator: (value) {
                  final amount = int.tryParse(value ?? '') ?? 0;
                  final description = _additionalDescControllers[index].text.trim();

                  if (amount < 0) {
                    return 'Enter a valid number';
                  }

                  if (amount > 0 && description.isEmpty) {
                    return 'Description is required';
                  }

                  if (description.isNotEmpty && amount <= 0) {
                    return 'Please fill in an amount';
                  }

                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 6,
              child: CustomTextFormField(
                controller: _additionalDescControllers[index],
                labelText: 'Description',
                keyboardType: TextInputType.text,
                validator: (value) {
                  final description = value?.trim() ?? '';
                  final amount = int.tryParse(_additionalChargeControllers[index].text) ?? 0;

                  if (description.isNotEmpty && amount <= 0) {
                    return 'Please fill in an amount';
                  }

                  if (amount > 0 && description.isEmpty) {
                    return 'Description is required';
                  }

                  if (description.length > 200) {
                    return 'Description too long';
                  }

                  return null;
                },
              ),
            ),

            const SizedBox(width: 8),
            if (_additionalCharges.length > 1)
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () {
                  setState(() {
                    _additionalCharges.removeAt(index);
                    _additionalChargeControllers[index].dispose();
                    _additionalDescControllers[index].dispose();
                    _additionalChargeControllers.removeAt(index);
                    _additionalDescControllers.removeAt(index);
                  });
                },
              ),
          ];

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child:
                isWide
                    ? Row(children: fields)
                    : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomTextFormField(
                          controller: _additionalChargeControllers[index],
                          labelText: 'Additional Charge',
                          keyboardType: const TextInputType.numberWithOptions(signed: false),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Text('₱', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
                          ),
                          validator: (value) {
                            final amount = int.tryParse(value ?? '') ?? 0;
                            final description = _additionalDescControllers[index].text.trim();

                            if (amount < 0) return 'Enter a valid number';
                            if (amount > 0 && description.isEmpty) return 'Description is required';
                            if (description.isNotEmpty && amount <= 0) return 'Please fill in an amount';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        CustomTextFormField(
                          controller: _additionalDescControllers[index],
                          labelText: 'Description',
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            final description = value?.trim() ?? '';
                            final amount = int.tryParse(_additionalChargeControllers[index].text) ?? 0;

                            if (description.isNotEmpty && amount <= 0) return 'Please fill in an amount';
                            if (amount > 0 && description.isEmpty) return 'Description is required';
                            if (description.length > 200) return 'Description too long';
                            return null;
                          },
                        ),
                        if (_additionalCharges.length > 1)
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _additionalCharges.removeAt(index);
                                  _additionalChargeControllers[index].dispose();
                                  _additionalDescControllers[index].dispose();
                                  _additionalChargeControllers.removeAt(index);
                                  _additionalDescControllers.removeAt(index);
                                });
                              },
                            ),
                          ),
                      ],
                    ),
          );
        }),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _additionalCharges.add(AdditionalChargeInput());
                _additionalChargeControllers.add(TextEditingController());
                _additionalDescControllers.add(TextEditingController());
              });
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Additional Charge'),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isEditing) {
    return [
      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
      ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(widget.bill == null ? 'Generate Bill' : 'Update Bill'),
      ),
    ];
  }

  Widget _buildRoomDropdown() {
    return buildRoomFilter(
      rooms: widget.rooms,
      tenants: widget.tenants,
      selectedRoomId: _selectedRoomId,
      selectedTenantId: _selectedTenantId,
      onFilterChanged: (roomId, tenantId) {
        setState(() {
          _selectedRoomId = roomId;
          _selectedTenantId = tenantId;
          _updateCharges();
        });
      },
    );
  }

  Widget _buildTenantDropdown() {
    return buildTenantFilter(
      label: 'Select Tenant',
      tenants: widget.tenants,
      readings: widget.readings,
      selectedRoomId: _selectedRoomId,
      selectedTenantId: _selectedTenantId,
      showActiveOnly: widget.showActiveOnly,
      onFilterChanged: (tenantId, roomId) {
        setState(() {
          _selectedTenantId = tenantId;
          _selectedRoomId = roomId;
          _updateCharges();
        });
      },
    );
  }

  Widget _buildRoomChargesField() {
    return CustomTextFormField(
      controller: _roomChargesController,
      labelText: 'Room Charges',
      enabled: false,
      prefixIcon: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Text('₱', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
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
        child: Text('₱', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
