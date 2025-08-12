import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/billing.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/billing_service.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';
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
  int? _selectedReadingId;
  PlatformFile? _receiptFile;
  String? _receiptUrl;

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
      _selectedReadingId = bill.readingId;
      _roomChargesController.text = bill.roomCharges.toString();
      _electricChargesController.text = bill.electricCharges.toString();
      _receiptUrl = bill.receiptUrl;
    } else {
      _selectedRoomId = widget.selectedRoomId;
      _selectedTenantId = widget.selectedTenantId;
      final reading = _getLatestReading(_selectedRoomId, _selectedTenantId);
      _selectedReadingId = reading?.id;
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

  Future<void> _pickReceiptFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['png', 'jpg'], withData: true);

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        _receiptFile = result.files.first;
      });
    } else {
      setState(() {
        _receiptFile = null;
      });
    }
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

    final additionalCharges = <Map<String, dynamic>>[];

    for (var i = 0; i < _additionalCharges.length; i++) {
      final amountText = _additionalChargeControllers[i].text.trim();
      final description = _additionalDescControllers[i].text.trim();

      final amount = int.tryParse(amountText) ?? 0;

      if (amount == 0 && description.isEmpty) continue;

      additionalCharges.add({'amount': amount, 'description': description});
    }

    Navigator.of(context).pop({
      'readingId': _selectedReadingId,
      'tenantId': _selectedTenantId,
      'roomCharges': int.tryParse(_roomChargesController.text) ?? 0,
      'electricCharges': int.tryParse(_electricChargesController.text) ?? 0,
      'additionalCharges': additionalCharges,
      'receiptFile': _receiptFile,
      'receiptUrl': _receiptUrl,
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
            const SizedBox(height: 16),
            if (widget.bill != null) _buildUploadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton.icon(
          onPressed: _pickReceiptFile,
          icon: Icon(Icons.attach_file),
          label: Text((_receiptFile == null && (_receiptUrl?.isEmpty ?? true)) ? 'Attach Receipt' : 'Change Receipt'),
        ),
        if (_receiptFile != null || _receiptUrl != null && _receiptUrl!.isNotEmpty) _buildReceipt(context),
      ],
    );
  }

  Widget _buildReceipt(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: InkWell(
        onTap: () {
          if (_receiptUrl != null) {
            showDialog(
              context: context,
              builder:
                  (context) => Dialog(
                    child: InteractiveViewer(
                      child: Image.network(
                        _receiptUrl!,
                        fit: BoxFit.contain,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(width: 200, height: 200, child: Center(child: CircularProgressIndicator()));
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return const Padding(padding: EdgeInsets.all(20), child: Text('Failed to load image'));
                        },
                      ),
                    ),
                  ),
            );
          }
        },
        child: Text(Uri.parse(_receiptUrl!).pathSegments.last, style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline)),
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

                  if (description.isNotEmpty && amount == 0) {
                    return 'Please fill in an amount';
                  }

                  if (amount != 0 && description.isEmpty) {
                    return 'Description is required';
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

                  if (description.isNotEmpty && amount == 0) {
                    return 'Please fill in an amount';
                  }

                  if (amount != 0 && description.isEmpty) {
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
