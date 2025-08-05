import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/room.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/utils/custom_dropdown_form.dart';
import 'package:rental_management_system_flutter/utils/custom_form_field.dart';

class TenantFormDialog extends StatefulWidget {
  final Tenant? tenant;
  final List<Room> rooms;

  const TenantFormDialog({super.key, this.tenant, required this.rooms});

  @override
  State<TenantFormDialog> createState() => _TenantFormDialogState();
}

class _TenantFormDialogState extends State<TenantFormDialog> {
  final _formKey = GlobalKey<FormState>();
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
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    final name = _nameController.text.trim();
    final roomId = int.parse(_selectedRoomId!);
    final joinDate = _selectedJoinDate!;

    Navigator.of(
      context,
    ).pop({'name': name, 'roomId': roomId, 'joinDate': joinDate});
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.tenant != null;

    return AlertDialog(
      title: _buildTitle(isEditing),
      content: _buildContent(),
      actions: _buildActions(context, isEditing),
    );
  }

  Widget _buildContent() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildNameField(),
          const SizedBox(height: 12),
          _buildRoomDropdown(),
          const SizedBox(height: 12),
          _buildJoinDatePicker(context),
        ],
      ),
    );
  }

  Widget _buildTitle(bool isEditing) {
    return Text(isEditing ? 'Edit Tenant' : 'Add New Tenant');
  }

  Widget _buildNameField() {
    return CustomTextFormField(
      controller: _nameController,
      labelText: 'Tenant',
      textInputAction: TextInputAction.next,
      validator:
          (value) =>
              (value == null || value.trim().isEmpty) ? 'Enter tenant' : null,
      prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
    );
  }

  Widget _buildRoomDropdown() {
    return CustomDropdownForm<String>(
      label: 'Room',
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
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please select a room' : null,
    );
  }

  Widget _buildJoinDatePicker(BuildContext context) {
    return FormField<DateTime>(
      validator:
          (value) =>
              _selectedJoinDate == null ? 'Please pick a join date' : null,
      builder: (formFieldState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                      setState(() {
                        _selectedJoinDate = picked;
                        formFieldState.didChange(picked);
                      });
                    }
                  },
                  child: const Text('Pick Date'),
                ),
              ],
            ),
            if (formFieldState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 6, left: 10),
                child: Text(
                  formFieldState.errorText!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 12,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  List<Widget> _buildActions(BuildContext context, bool isEditing) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
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
