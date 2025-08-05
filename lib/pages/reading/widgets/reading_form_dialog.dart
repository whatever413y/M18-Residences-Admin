import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/reading.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/services/reading_service.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

class ReadingFormDialog extends StatefulWidget {
  final Reading? reading;
  final List<Room> rooms;
  final List<Tenant> tenants;
  final List<Reading> readings;
  final ReadingService readingService;
  final void Function(Reading) onSubmit;
  final int? selectedRoomId;
  final int? selectedTenantId;

  const ReadingFormDialog({
    super.key,
    required this.reading,
    required this.rooms,
    required this.tenants,
    required this.readings,
    required this.readingService,
    required this.onSubmit,
    required this.selectedRoomId,
    required this.selectedTenantId,
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
      prevController.text =
          _getLatestReading(
            _selectedRoomId ?? 0,
            _selectedTenantId ?? 0,
          )?.currReading.toString() ??
          '0';
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
        widget.readings
            .where((r) => r.roomId == roomId && r.tenantId == tenantId)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return filtered.isNotEmpty ? filtered.first : null;
  }

  void _updatePreviousReading() {
    if (widget.reading != null ||
        _selectedRoomId == null ||
        _selectedTenantId == null) {
      return;
    }
    final latest = _getLatestReading(_selectedRoomId!, _selectedTenantId!);
    prevController.text = latest?.currReading.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reading == null ? 'Add New Reading' : 'Edit Reading'),
      content: _buildContent(),
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
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: _submitForm,
        child: Text(widget.reading == null ? 'Add' : 'Save'),
      ),
    ];
  }

  Widget _buildRoomDropdown() {
    return CustomDropdownForm<int>(
      label: 'Select Room',
      value: _selectedRoomId,
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('All Rooms')),
        ...widget.rooms.map(
          (room) =>
              DropdownMenuItem<int>(value: room.id, child: Text(room.name)),
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
          _updatePreviousReading();
        });
      },
    );
  }

  Widget _buildTenantDropdown() {
    return CustomDropdownForm<int>(
      label: 'Select Tenant',
      hint: 'Choose a tenant',
      value: _selectedTenantId,
      items: [
        const DropdownMenuItem<int>(
          value: null,
          enabled: false,
          child: Text('Choose a tenant'),
        ),
        ...widget.tenants
            .where(
              (t) => _selectedRoomId == null || t.roomId == _selectedRoomId,
            )
            .map(
              (tenant) => DropdownMenuItem<int>(
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
          _updatePreviousReading();
        });
      },
      validator: (value) => value == null ? 'Please choose a tenant' : null,
    );
  }

  Widget _buildPrevReadingField() {
    return CustomTextFormField(
      controller: prevController,
      labelText: 'Previous Reading',
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

  Widget _buildCurrReadingField() {
    return CustomTextFormField(
      controller: currController,
      labelText: 'Current Reading',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      validator: (value) {
        final parsed = int.tryParse(value ?? '');
        final prev = int.tryParse(prevController.text);
        if (parsed == null || parsed < 0) {
          return 'Enter a valid reading';
        }
        if (prev != null && parsed < prev) {
          return 'Current must be ≥ previous';
        }
        return null;
      },
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

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final prev = int.tryParse(prevController.text);
    final curr = int.tryParse(currController.text);

    if (_selectedRoomId == null ||
        _selectedTenantId == null ||
        prev == null ||
        curr == null) {
      if (!mounted) return;
      CustomSnackbar.show(
        context,
        'Invalid input. Please check your entries.',
        type: SnackBarType.error,
      );
      return;
    }

    try {
      final reading =
          widget.reading == null
              ? await widget.readingService.createReading(
                roomId: _selectedRoomId!,
                tenantId: _selectedTenantId!,
                prevReading: prev,
                currReading: curr,
              )
              : await widget.readingService.updateReading(
                id: widget.reading!.id,
                roomId: _selectedRoomId!,
                tenantId: _selectedTenantId!,
                prevReading: prev,
                currReading: curr,
              );

      if (!mounted) return;
      widget.onSubmit(reading);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      CustomSnackbar.show(context, 'Error: $e', type: SnackBarType.error);
    }
  }
}
