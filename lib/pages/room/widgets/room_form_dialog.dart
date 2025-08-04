import 'package:flutter/material.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';

class RoomFormDialog extends StatefulWidget {
  final Room? room;
  final void Function(String name, double rent) onSubmit;

  const RoomFormDialog({super.key, this.room, required this.onSubmit});

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _roomNameController = TextEditingController();
  final _rentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _roomNameController.text = widget.room!.name;
      _rentController.text = widget.room!.rent.toString();
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _roomNameController.text.trim();
      final rent = double.parse(_rentController.text.trim());
      widget.onSubmit(name, rent);
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.room != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
      content: _buildContent(),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRoomNameField(),
          const SizedBox(height: 12),
          _buildRentField(),
        ],
      ),
    );
  }

  Widget _buildRoomNameField() {
    return CustomTextFormField(
      controller: _roomNameController,
      labelText: 'Room Name',
      autofocus: true,
      textInputAction: TextInputAction.next,
      validator:
          (value) =>
              (value == null || value.trim().isEmpty)
                  ? 'Enter room name'
                  : null,
      prefixIcon: Icon(
        Icons.meeting_room,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  Widget _buildRentField() {
    return CustomTextFormField(
      controller: _rentController,
      labelText: 'Rent',
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      validator: (value) {
        final parsed = double.tryParse(value ?? '');
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
      onFieldSubmitted: (_) => _submitForm(),
    );
  }

  List<Widget> _buildActions() {
    final isEditing = widget.room != null;

    return [
      TextButton(
        onPressed: () => Navigator.of(context).pop(false),
        child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
      ),
      ElevatedButton(
        onPressed: _submitForm,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(isEditing ? 'Save' : 'Add'),
      ),
    ];
  }
}
