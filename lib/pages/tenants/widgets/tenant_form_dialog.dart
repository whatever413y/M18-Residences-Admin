import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/utils/custom_snackbar.dart';

class TenantFormDialog extends StatefulWidget {
  final Tenant? tenant;
  final List<Room> rooms;
  final Function(String name, int roomId, DateTime joinDate) onSubmit;

  const TenantFormDialog({
    super.key,
    this.tenant,
    required this.rooms,
    required this.onSubmit,
  });

  @override
  State<TenantFormDialog> createState() => _TenantFormDialogState();
}

class _TenantFormDialogState extends State<TenantFormDialog> {
  final _nameController = TextEditingController();
  String? _selectedRoomId;
  DateTime? _selectedJoinDate;
  final _dateFormat = DateFormat('MMMM d, y');

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.tenant?.name ?? '';
    _selectedRoomId = widget.tenant?.roomId.toString();
    _selectedJoinDate = widget.tenant?.joinDate;
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tenant != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Tenant' : 'Add New Tenant'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tenant Name'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedRoomId,
              items:
                  widget.rooms
                      .map(
                        (room) => DropdownMenuItem(
                          value: room.id.toString(),
                          child: Text(room.name),
                        ),
                      )
                      .toList(),
              onChanged: (value) => setState(() => _selectedRoomId = value),
              decoration: const InputDecoration(labelText: 'Room'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedJoinDate == null
                        ? 'Select Join Date'
                        : 'Joined: ${_dateFormat.format(_selectedJoinDate!)}',
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedJoinDate ?? now,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(now.year + 5),
                    );
                    if (picked != null) {
                      setState(() => _selectedJoinDate = picked);
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final name = _nameController.text.trim();
            final roomId = _selectedRoomId;
            final joinDate = _selectedJoinDate;

            if (name.isEmpty || roomId == null || joinDate == null) {
              CustomSnackbar.show(
                context,
                'Please fill all fields',
                type: SnackBarType.error,
              );
              return;
            }

            widget.onSubmit(name, int.parse(roomId), joinDate);
            Navigator.pop(context);
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
