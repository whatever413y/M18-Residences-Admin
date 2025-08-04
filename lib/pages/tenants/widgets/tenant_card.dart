import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:rental_management_system_flutter/models/tenant.dart';
import 'package:rental_management_system_flutter/models/room.dart';

class TenantCard extends StatelessWidget {
  final Tenant tenant;
  final Room room;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const TenantCard({
    super.key,
    required this.tenant,
    required this.room,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMMM d, y');

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: _buildTitle(),
        subtitle: _buildSubtitle(dateFormat),
        isThreeLine: true,
        trailing: _buildActions(),
      ),
    );
  }

  Widget _buildTitle() {
    return Text(
      tenant.name,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
    );
  }

  Widget _buildSubtitle(DateFormat dateFormat) {
    return Text(
      'Room: ${room.name}\nJoined: ${dateFormat.format(tenant.joinDate)}',
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: onEdit,
        ),
        IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: onDelete,
        ),
      ],
    );
  }
}
