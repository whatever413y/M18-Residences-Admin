import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';
import 'package:rental_management_system_flutter/utils/shared_widgets.dart';

class ReadingFormDialog extends StatefulWidget {
  final Reading? reading;
  final List<Room> rooms;
  final List<Tenant> tenants;
  final List<Reading> readings;
  final ReadingService readingService;
  final int? selectedRoomId;
  final int? selectedTenantId;
  final bool showActiveOnly;

  const ReadingFormDialog({
    super.key,
    required this.reading,
    required this.rooms,
    required this.tenants,
    required this.readings,
    required this.readingService,
    required this.selectedRoomId,
    required this.selectedTenantId,
    required this.showActiveOnly,
  });

  @override
  State<ReadingFormDialog> createState() => _ReadingFormDialogState();
}

class _ReadingFormDialogState extends State<ReadingFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController prevController = TextEditingController();
  final TextEditingController currController = TextEditingController();
  late int? _selectedRoomId;
  late int? _selectedTenantId;

  @override
  void initState() {
    super.initState();

    if (widget.reading != null) {
      _selectedRoomId = widget.reading!.roomId;
      _selectedTenantId = widget.reading!.tenantId;
      prevController.text = widget.reading!.prevReading.toString();
      currController.text = widget.reading!.currReading.toString();
    } else {
      _selectedRoomId = widget.selectedRoomId;
      _selectedTenantId = widget.selectedTenantId;
      prevController.text = _getLatestReading(_selectedRoomId ?? 0, _selectedTenantId ?? 0)?.currReading.toString() ?? '0';
      currController.clear();
    }
  }

  @override
  void dispose() {
    prevController.dispose();
    currController.dispose();
    super.dispose();
  }

  Reading? _getLatestReading(int roomId, int tenantId) {
    final filtered =
        widget.readings.where((r) => r.roomId == roomId && r.tenantId == tenantId).toList()..sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return filtered.isNotEmpty ? filtered.first : null;
  }

  void _updatePreviousReading() {
    if (widget.reading != null || _selectedRoomId == null || _selectedTenantId == null) {
      return;
    }
    final latest = _getLatestReading(_selectedRoomId!, _selectedTenantId!);
    prevController.text = latest?.currReading.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.6;
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      title: Text(widget.reading == null ? 'Add New Reading' : 'Edit Reading'),
      content: SizedBox(width: screenWidth, child: _buildContent()),
      actions: _buildActions(context, widget.reading != null),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoomDropdown(),
          const SizedBox(height: 12),
          _buildTenantDropdown(),
          const SizedBox(height: 12),
          _buildPrevReadingField(),
          const SizedBox(height: 12),
          _buildCurrReadingField(),
        ],
      ),
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
        child: Text(widget.reading == null ? 'Add' : 'Save'),
      ),
    ];
  }

  Widget _buildRoomDropdown() {
    return buildRoomFilter(
      label: 'Select Room',
      rooms: widget.rooms,
      tenants: widget.tenants,
      selectedRoomId: _selectedRoomId,
      selectedTenantId: _selectedTenantId,
      onFilterChanged: (roomId, tenantId) {
        setState(() {
          _selectedRoomId = roomId;
          _selectedTenantId = tenantId;
          _updatePreviousReading();
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
          _updatePreviousReading();
        });
      },
    );
  }

  Widget _buildPrevReadingField() {
    return CustomTextFormField(
      controller: prevController,
      labelText: 'Previous Reading (kWh)',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.next,
      validator: (value) {
        final prev = int.tryParse(value ?? '');
        final curr = int.tryParse(currController.text);
        if (prev == null || prev < 0) {
          return 'Enter a valid previous reading';
        }
        if (curr != null && prev > curr) {
          return 'Previous reading must be ≤ current reading';
        }
        return null;
      },
    );
  }

  Widget _buildCurrReadingField() {
    return CustomTextFormField(
      controller: currController,
      labelText: 'Current Reading (kWh)',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      validator: (value) {
        final curr = int.tryParse(value ?? '');
        final prev = int.tryParse(prevController.text);
        if (curr == null || curr < 0) {
          return 'Enter a valid current reading';
        }
        if (prev != null && curr < prev) {
          return 'Current reading must be ≥ previous reading';
        }
        return null;
      },
    );
  }

  void _submit() async {
    if (_formKey.currentState?.validate() != true) return;
    final prev = int.tryParse(prevController.text);
    final curr = int.tryParse(currController.text);
    Navigator.of(context).pop({'roomId': _selectedRoomId, 'tenantId': _selectedTenantId, 'prevReading': prev, 'currReading': curr});
  }
}
