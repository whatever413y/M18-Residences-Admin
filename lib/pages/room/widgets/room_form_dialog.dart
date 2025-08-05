import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';

class RoomFormDialog extends StatefulWidget {
  final Room? room;

  const RoomFormDialog({super.key, this.room});

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _rentController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.room?.name ?? '');
    _rentController = TextEditingController(
      text: widget.room?.rent.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;

    final name = _nameController.text.trim();
    final rent = double.parse(_rentController.text.trim());

    Navigator.of(context).pop({'name': name, 'rent': rent});
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextFormField(
              controller: _nameController,
              labelText: 'Room Name',
              textInputAction: TextInputAction.next,
              validator:
                  (val) =>
                      (val == null || val.trim().isEmpty)
                          ? 'Enter room name'
                          : null,
              prefixIcon: Icon(
                Icons.meeting_room,
                color: Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            CustomTextFormField(
              controller: _rentController,
              labelText: 'Rent',
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
              validator: (val) {
                final parsed = double.tryParse(val ?? '');
                if (parsed == null || parsed < 0) {
                  return 'Enter a valid rent amount';
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
              onFieldSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: _submit,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}
