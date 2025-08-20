import 'package:flutter/material.dart';
import 'package:m18_residences_admin/models/room.dart';
import 'package:m18_residences_admin/utils/custom_form_field.dart';

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
    _rentController = TextEditingController(text: widget.room != null ? widget.room!.rent.toString() : '');
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final data = {'name': _nameController.text.trim(), 'rent': double.parse(_rentController.text.trim())};
      Navigator.of(context).pop(data);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width * 0.3;
    final isEditing = widget.room != null;
    return AlertDialog(
      insetPadding: EdgeInsets.zero,
      title: Text(isEditing ? 'Edit Room' : 'Add New Room'),
      content: SizedBox(width: screenWidth, child: _buildContent()),
      actions: _buildActions(),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(mainAxisSize: MainAxisSize.min, children: [_buildNameField(), const SizedBox(height: 12), _buildRentField()]),
    );
  }

  Widget _buildNameField() {
    return CustomTextFormField(
      controller: _nameController,
      labelText: 'Room Name',
      textInputAction: TextInputAction.next,
      validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter room name' : null,
      prefixIcon: Icon(Icons.meeting_room, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildRentField() {
    return CustomTextFormField(
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
        child: Text('₱', style: TextStyle(color: Theme.of(context).primaryColor, fontSize: 20, fontWeight: FontWeight.bold)),
      ),
      onFieldSubmitted: (_) => _submit(),
    );
  }

  List<Widget> _buildActions() {
    final isEditing = widget.room != null;

    return [
      TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel', style: TextStyle(color: Colors.grey))),
      ElevatedButton(
        onPressed: _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        ),
        child: Text(isEditing ? 'Save' : 'Add'),
      ),
    ];
  }
}
