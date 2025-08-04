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

  const ReadingFormDialog({
    super.key,
    required this.reading,
    required this.rooms,
    required this.tenants,
    required this.readings,
    required this.readingService,
    required this.onSubmit,
  });

  @override
  State<ReadingFormDialog> createState() => _ReadingFormDialogState();
}

class _ReadingFormDialogState extends State<ReadingFormDialog> {
  late int? selectedRoomId;
  late int? selectedTenantId;
  final TextEditingController prevController = TextEditingController();
  final TextEditingController currController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.reading != null) {
      selectedRoomId = widget.reading!.roomId;
      selectedTenantId = widget.reading!.tenantId;
      prevController.text = widget.reading!.prevReading.toString();
      currController.text = widget.reading!.currReading.toString();
    } else {
      selectedRoomId = null;
      selectedTenantId = null;
      prevController.text = '0';
      currController.clear();
    }
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
        selectedRoomId == null ||
        selectedTenantId == null) {
      return;
    }
    final latest = _getLatestReading(selectedRoomId!, selectedTenantId!);
    prevController.text = latest?.currReading.toString() ?? '0';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.reading == null ? 'Add New Reading' : 'Edit Reading'),
      content: SingleChildScrollView(
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
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _onSubmit,
          child: Text(widget.reading == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }

  Widget _buildRoomDropdown() {
    return CustomDropdownForm<int>(
      label: 'Select Room',
      value: selectedRoomId,
      items: [
        const DropdownMenuItem<int>(value: null, child: Text('All Rooms')),
        ...widget.rooms.map(
          (room) =>
              DropdownMenuItem<int>(value: room.id, child: Text(room.name)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          selectedRoomId = value;

          if (selectedTenantId != null) {
            final tenant = widget.tenants.firstWhereOrNull(
              (t) => t.id == selectedTenantId,
            );
            if (tenant == null || tenant.roomId != selectedRoomId) {
              selectedTenantId = null;
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
      value: selectedTenantId,
      items: [
        const DropdownMenuItem<int>(
          value: null,
          enabled: false,
          child: Text('Choose a tenant'),
        ),
        ...widget.tenants
            .where((t) => selectedRoomId == null || t.roomId == selectedRoomId)
            .map(
              (tenant) => DropdownMenuItem<int>(
                value: tenant.id,
                child: Text(tenant.name),
              ),
            ),
      ],
      onChanged: (value) {
        setState(() {
          selectedTenantId = value;

          if (selectedTenantId != null) {
            final tenantRoomId =
                widget.tenants
                    .firstWhere((t) => t.id == selectedTenantId)
                    .roomId;
            if (selectedRoomId != tenantRoomId) {
              selectedRoomId = tenantRoomId;
            }
          }
          _updatePreviousReading();
        });
      },
    );
  }

  Widget _buildPrevReadingField() {
    return CustomTextFormField(
      controller: prevController,
      labelText: 'Previous Reading',
      enabled: widget.reading != null,
    );
  }

  Widget _buildCurrReadingField() {
    return CustomTextFormField(
      controller: currController,
      labelText: 'Current Reading',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      validator: (value) {
        final parsed = double.tryParse(value ?? '');
        if (parsed == null || parsed < 0) {
          return 'Enter a valid rent amount';
        }
        return null;
      },
    );
  }

  void _onSubmit() async {
    final prev = int.tryParse(prevController.text);
    final curr = int.tryParse(currController.text);

    if (selectedRoomId == null ||
        selectedTenantId == null ||
        prev == null ||
        curr == null ||
        curr < prev) {
      if (context.mounted) {
        CustomSnackbar.show(
          context,
          'Invalid input: current must be ≥ previous.',
          type: SnackBarType.error,
        );
      }
      return;
    }

    try {
      final reading =
          widget.reading == null
              ? await widget.readingService.createReading(
                roomId: selectedRoomId!,
                tenantId: selectedTenantId!,
                prevReading: prev,
                currReading: curr,
              )
              : await widget.readingService.updateReading(
                id: widget.reading!.id,
                roomId: selectedRoomId!,
                tenantId: selectedTenantId!,
                prevReading: prev,
                currReading: curr,
              );

      if (context.mounted) {
        widget.onSubmit(reading);
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        CustomSnackbar.show(context, 'Error: $e', type: SnackBarType.error);
      }
    }
  }
}
